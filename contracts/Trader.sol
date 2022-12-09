// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IItems.sol";

contract Trader is ERC1155Holder, Ownable {
    struct Shop {
        uint8 item;
        uint8 limit;
        uint64 price;
    }

    struct Trade {
        uint8 itemTrade;
        uint8 quantityTrade;
        uint8 itemReceived;
        uint8 quantityReceived;
        uint8 limit;
    }

    IItems public itemsInterface;
    IERC1155 public erc1155Interface;

    uint8 internal tradesAmount;
    uint8 internal shopItemsAmount;

    mapping(uint256 => Trade) public traderTrades;
    mapping(uint256 => Shop) public shopItems;
    mapping(address => mapping(uint256 => uint256)) public shopDailyLimit;
    mapping(address => mapping(uint256 => uint256)) public tradeDailyLimit;
    mapping(address => uint256) public dailyShopTimeLimit;
    mapping(address => uint256) public dailyTradeTimeLimit;

    function setInterface(address _itemsContract) public onlyOwner {
        itemsInterface = IItems(_itemsContract);
        erc1155Interface = IERC1155(_itemsContract);
    }

    function addItemsToShop(
        uint256[] calldata _items,
        uint256[] calldata _limits,
        uint256[] calldata _prices
    ) external onlyOwner {
        uint256 _shopItemsAmount = shopItemsAmount;
        for (uint256 i; i < _items.length; ++i) {
            Shop storage newShopItems = shopItems[_shopItemsAmount];
            uint256 item = _items[i];
            uint256 limit = _limits[i];
            uint256 price = _prices[i];
            newShopItems.item = uint8(item);
            newShopItems.price = uint64(price);
            newShopItems.limit = uint8(limit);
            _shopItemsAmount++;
        }
        shopItemsAmount = uint8(_shopItemsAmount);
    }

    function addNewTrade(
        uint256 _itemTrade,
        uint256 _quantityTrade,
        uint256 _itemReceived,
        uint256 _quantityReceived,
        uint256 _limit
    ) external onlyOwner {
        uint256 _tradesAmount = uint256(tradesAmount);
        Trade storage newTrades = traderTrades[_tradesAmount];
        newTrades.itemTrade = uint8(_itemTrade);
        newTrades.quantityTrade = uint8(_quantityTrade);
        newTrades.itemReceived = uint8(_itemReceived);
        newTrades.quantityReceived = uint8(_quantityReceived);
        newTrades.limit = uint8(_limit);
        tradesAmount = uint8(_tradesAmount + 1);
    }

    function resetShopTimeLimit(address _user) internal {
        uint256 timeLimit = dailyShopTimeLimit[_user];
        if (timeLimit > 0 && timeLimit <= block.timestamp) {
            require(
                timeLimit > 0 && timeLimit <= block.timestamp,
                "Time limit not done"
            );
            resetDailyShop(_user);
        }
    }

    function resetTradeTimeLimitPassed(address _user) internal {
        uint256 timeLimit = dailyTradeTimeLimit[_user];
        if (timeLimit > 0 && timeLimit <= block.timestamp) {
            require(
                timeLimit > 0 && timeLimit <= block.timestamp,
                "Time limit not done"
            );
            resetDailyShop(_user);
        }
    }

    function buyItems(
        uint256[] calldata _items,
        uint256[] calldata _quantity,
        address _user
    ) external payable {
        uint256 total = getTotalPrice(_items, _quantity);
        uint256 amount = _items.length;
        resetShopTimeLimit(_user);
        checkDailyShopLimit(_items, _quantity, _user);
        for (uint256 i; i < amount; ++i) {
            uint256 item = _items[i];
            uint256 quantity = _quantity[i];
            uint256 limit = shopDailyLimit[_user][item];
            shopDailyLimit[_user][item] = quantity + limit;
        }
        triggerShopLimit(_user);
        require(msg.value >= total, "Wrong value of ether sent");
        itemsInterface.mintForShop(_user, _items, _quantity);
    }

    function tradeItem(
        uint256 _tradeId,
        uint256 _quantity,
        address _user
    ) external {
        Trade memory tradeDetails = traderTrades[_tradeId];
        uint256 tradeQuantity = tradeDetails.quantityTrade * _quantity;
        uint256 receiveQuantity = tradeDetails.quantityReceived * _quantity;
        uint256 limit = tradeDailyLimit[_user][_tradeId];
        require(
            erc1155Interface.balanceOf(_user, tradeDetails.itemTrade) >
                tradeQuantity,
            "Not enough items needed"
        );
        resetShopTimeLimit(_user);
        checkDailyTradeLimit(_tradeId, _quantity, _user);
        tradeDailyLimit[_user][_tradeId] = limit + _quantity;
        triggerTraderLimit(_user);
        erc1155Interface.safeTransferFrom(
            _user,
            address(this),
            tradeDetails.itemTrade,
            tradeQuantity,
            ""
        );
        itemsInterface.mintForTrade(
            _user,
            tradeDetails.itemReceived,
            receiveQuantity
        );
    }

    function getTotalPrice(
        uint256[] calldata _items,
        uint256[] calldata _quantity
    ) internal view returns (uint256 total) {
        uint256 amount = _items.length;
        for (uint256 i; i < amount; ++i) {
            uint256 quantity = _quantity[i];
            uint256 item = _items[i];
            uint256 price = shopItems[item].price;
            total += price * quantity;
        }
    }

    function resetDailyShop(address _user) internal {
        uint256 timeLimit = dailyShopTimeLimit[_user];
        uint256 _shopItemsAmount = shopItemsAmount;
        require(
            timeLimit <= block.timestamp && timeLimit > 0,
            "You hit your limit"
        );
        delete dailyShopTimeLimit[_user];
        for (uint256 i; i < _shopItemsAmount; ++i) {
            delete shopDailyLimit[_user][i];
        }
    }

    function resetDailyTrade(address _user) internal {
        uint256 timeLimit = dailyTradeTimeLimit[_user];
        uint256 _tradesAmount = tradesAmount;
        require(
            timeLimit <= block.timestamp && timeLimit > 0,
            "You hit your limit"
        );
        delete dailyTradeTimeLimit[_user];
        for (uint256 i; i < _tradesAmount; ++i) {
            delete tradeDailyLimit[_user][i];
        }
    }

    function triggerShopLimit(address _user) internal {
        uint256 shopTotalLimit;
        uint256 userTotalLimit;
        uint256 _shopItemsAmount = shopItemsAmount;
        for (uint256 i; i < _shopItemsAmount; ++i) {
            uint256 userLimit = shopDailyLimit[_user][i];
            Shop memory shopItem = shopItems[i];
            userTotalLimit += userLimit;
            shopTotalLimit += shopItem.limit;
        }
        if (userTotalLimit == shopTotalLimit) {
            dailyShopTimeLimit[_user] = block.timestamp + 1 days;
        }
    }

    function triggerTraderLimit(address _user) internal {
        uint256 tradeTotalLimit;
        uint256 userTotalLimit;
        uint256 _tradesAmount = tradesAmount;
        for (uint256 i; i < _tradesAmount; ++i) {
            uint256 userLimit = tradeDailyLimit[_user][i];
            Trade memory trade = traderTrades[i];
            userTotalLimit += userLimit;
            tradeTotalLimit += trade.limit;
        }
        if (userTotalLimit == tradeTotalLimit) {
            dailyTradeTimeLimit[_user] = block.timestamp + 1 days;
        }
    }

    function checkDailyShopLimit(
        uint256[] calldata _items,
        uint256[] calldata _quantity,
        address _user
    ) internal view {
        uint256 amount = _items.length;
        for (uint256 i; i < amount; ++i) {
            uint256 item = _items[i];
            uint256 quantity = _quantity[i];
            uint256 userLimitTotal = shopDailyLimit[_user][item] + quantity;
            uint256 itemLimit = shopItems[item].limit;
            require(userLimitTotal <= itemLimit, "You hit your limit");
        }
    }

    function checkDailyTradeLimit(
        uint256 _tradeId,
        uint256 _quantity,
        address _user
    ) internal view {
        uint256 quantity = tradeDailyLimit[_user][_tradeId] + _quantity;
        uint256 tradeLimit = traderTrades[_tradeId].limit;
        require(quantity <= tradeLimit, "You hit your limit");
    }

    function getShopDailyLimit(address _user)
        external
        view
        returns (uint256[] memory shopLimit)
    {
        uint256 _shopItemsAmount = shopItemsAmount;
        shopLimit = new uint256[](_shopItemsAmount);
        for (uint256 i; i < _shopItemsAmount; ++i) {
            uint256 userLimit = shopDailyLimit[_user][i];
            shopLimit[i] = userLimit;
        }
    }

    function getTradeDailyLimit(address _user)
        external
        view
        returns (uint256[] memory tradeLimit)
    {
        uint256 _tradesAmount = tradesAmount;
        tradeLimit = new uint256[](_tradesAmount);
        for (uint256 i; i < _tradesAmount; ++i) {
            uint256 userLimit = tradeDailyLimit[_user][i];
            tradeLimit[i] = userLimit;
        }
    }

    function getDailyShop() external view returns (Shop[] memory dailyShop) {
        uint256 _shopItemsAmount = shopItemsAmount;
        dailyShop = new Shop[](_shopItemsAmount);
        for (uint256 i; i < _shopItemsAmount; ++i) {
            Shop memory item = shopItems[i];
            dailyShop[i] = item;
        }
    }

    function getDailyTrades()
        external
        view
        returns (Trade[] memory dailyTrades)
    {
        uint256 _tradesAmount = tradesAmount;
        dailyTrades = new Trade[](_tradesAmount);
        for (uint256 i; i < _tradesAmount; ++i) {
            dailyTrades[i] = traderTrades[i];
        }
    }

    receive() external payable {}
}
