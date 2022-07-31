// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "./IItems.sol";
import "./IMonsterGame.sol";

contract Trader is ERC1155Holder {
    struct Shop {
        uint256 item;
        uint256 quantity;
        uint256 price;
    }

    struct Trade {
        uint256 itemTrade;
        uint256 quantityTrade;
        uint256 itemReceived;
        uint256 quantityReceived;
        uint256 limit;
    }

    IItems itemInterface;
    IMonsterGame monsterGameInterface;
    IERC1155 public itemNftInterface;

    address OWNER;
    uint256 tradeIds;
    uint256[] public dailyShop;
    uint256[] public dailyTrades;
    mapping(uint256 => Trade) public traderTrades;
    mapping(uint256 => Shop) public shopItems;
    mapping(address => mapping(uint256 => uint256)) public shopDailyLimit;
    mapping(address => mapping(uint256 => uint256)) public tradeDailyLimit;
    mapping(address => uint256) public dailyShopTimeLimit;
    mapping(address => uint256) public dailyTradeTimeLimit;

    constructor() {
        OWNER = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == OWNER);
        _;
    }

    function setInterface(address _items, address _monsterGame)
        public
        onlyOwner
    {
        itemInterface = IItems(_items);
        monsterGameInterface = IMonsterGame(_monsterGame);
        itemNftInterface = IERC1155(_items);
    }

    function addItemsToShop(
        uint256[] calldata _itemId,
        uint256[] calldata _limit,
        uint256[] calldata _price
    ) external onlyOwner {
        for (uint256 i; i < _itemId.length; ++i) {
            dailyShop.push(_itemId[i]);
            shopItems[_itemId[i]] = (Shop(_itemId[i], _limit[i], _price[i]));
        }
    }

    function addTradeToTrader(
        uint256 _itemTrade,
        uint256 _quantityTrade,
        uint256 _itemReceived,
        uint256 _quantityReceived,
        uint256 _limit
    ) external onlyOwner {
        dailyTrades.push(tradeIds);
        traderTrades[tradeIds] = (
            Trade(
                _itemTrade,
                _quantityTrade,
                _itemReceived,
                _quantityReceived,
                _limit
            )
        );
        tradeIds++;
    }

    modifier buyIfBelowLimit(uint256[] calldata _quantity) {
        uint256 arrLength = _quantity.length;
        for (uint256 i; i < arrLength; ++i) {
            require(
                _quantity[i] <= 3,
                "There's only 3 stocks per item everyday"
            );
        }
        _;
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
        uint256[] calldata _item,
        uint256[] calldata _quantity,
        address _user
    ) external payable buyIfBelowLimit(_quantity) {
        uint256 total = getTotalPrice(_item, _quantity);
        uint256 itemLength = _item.length;
        resetShopTimeLimit(_user);
        checkDailyShopLimit(_item, _quantity, _user);
        for (uint256 i; i < itemLength; ++i) {
            uint256 item = _item[i];
            uint256 quantity = _quantity[i];
            uint256 limit = shopDailyLimit[_user][item];
            shopDailyLimit[_user][item] = quantity + limit;
        }
        triggerLimit(_user);
        require(msg.value >= total, "Wrong value of ether sent");
        itemInterface.mintForShop(_user, _item, _quantity);
    }

    function tradeItem(
        uint256 _tradeId,
        uint256 _quantity,
        address _user
    ) external {
        require(_quantity <= 5, "There's only 5 stocks per trade everyday");
        Trade memory tradeDetails = traderTrades[_tradeId];
        uint256 tradeQuantity = tradeDetails.quantityTrade * _quantity;
        uint256 receiveQuantity = tradeDetails.quantityReceived * _quantity;
        uint256 limit = tradeDailyLimit[_user][_tradeId];
        resetShopTimeLimit(_user);
        checkDailyTradeLimit(_tradeId, _quantity, _user);
        tradeDailyLimit[_user][_tradeId] = _quantity + limit;

        require(
            itemNftInterface.balanceOf(_user, tradeDetails.itemTrade) >
                tradeQuantity,
            "Not enough items needed"
        );

        itemNftInterface.safeTransferFrom(
            _user,
            address(this),
            tradeDetails.itemTrade,
            tradeQuantity,
            ""
        );
        itemInterface.mintForTrade(
            _user,
            tradeDetails.itemReceived,
            receiveQuantity
        );
    }

    function getTotalPrice(
        uint256[] calldata _item,
        uint256[] calldata _quantity
    ) internal view returns (uint256 total) {
        uint256 totalTemp;
        uint256 itemLength = _item.length;
        for (uint256 i; i < itemLength; ++i) {
            uint256 quantity = _quantity[i];
            uint256 itemId = _item[i];
            uint256 price = shopItems[itemId].price;
            totalTemp += price * quantity;
        }
        total = totalTemp;
    }

    function resetDailyShop(address _user) internal {
        uint256 timeLimit = dailyShopTimeLimit[_user];
        require(
            timeLimit <= block.timestamp && timeLimit > 0,
            "You hit your limit"
        );
        delete dailyShopTimeLimit[_user];
        for (uint256 i; i < dailyShop.length; ++i) {
            delete shopDailyLimit[_user][i];
        }
    }

    function resetDailyTrade(address _user) internal {
        uint256 timeLimit = dailyTradeTimeLimit[_user];
        require(
            timeLimit <= block.timestamp && timeLimit > 0,
            "You hit your limit"
        );
        delete dailyTradeTimeLimit[_user];
        for (uint256 i; i < dailyShop.length; ++i) {
            delete tradeDailyLimit[_user][i];
        }
    }

    function triggerLimit(address _user) internal {
        uint256 totalLimit;
        uint256 shopLength = dailyShop.length;
        uint256 shopTotalLimit = shopLength * 3;
        for (uint256 i; i < shopLength; ++i) {
            uint256 quantity = shopDailyLimit[_user][i];
            totalLimit += quantity;
        }
        if (totalLimit == shopTotalLimit) {
            dailyShopTimeLimit[_user] = block.timestamp + 1 days;
        }
    }

    function checkDailyShopLimit(
        uint256[] calldata _item,
        uint256[] calldata _quantity,
        address _user
    ) internal view {
        uint256 itemLength = _item.length;
        for (uint256 i; i < itemLength; ++i) {
            uint256 quantity = shopDailyLimit[_user][i] + _quantity[i];
            uint256 itemLimit = shopItems[i].quantity;
            require(quantity <= itemLimit, "You hit your limit");
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
        returns (uint256[] memory shoplimit)
    {
        uint256 shopLength = dailyShop.length;
        uint256[] memory limit = new uint256[](shopLength);
        for (uint256 i; i < shopLength; ++i) {
            limit[i] = (shopDailyLimit[_user][i]);
        }
        shoplimit = limit;
    }

    function getDailyShop() external view returns (Shop[] memory) {
        uint256 shopLength = dailyShop.length;
        Shop[] memory shop = new Shop[](shopLength);
        for (uint256 i; i < shopLength; ++i) {
            uint256 itemId = dailyShop[i];
            shop[i] = shopItems[itemId];
        }
        return shop;
    }

    receive() external payable {}
}
