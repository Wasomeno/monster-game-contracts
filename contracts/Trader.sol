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

    struct ShopLimit {
        uint256 item;
        uint256 quantity;
    }

    struct Trades {
        uint256 itemTrade;
        uint256 quantityTrade;
        uint256 itemReceived;
        uint256 quantityReceived;
    }

    struct TradeLimit {
        uint256 tradeId;
        uint256 quantity;
    }

    IItems itemInterface;
    IMonsterGame monsterGameInterface;
    IERC1155 public itemNftInterface;
    Shop[] public dailyShop;

    mapping(uint256 => Trades) public traderTrades;
    mapping(address => ShopLimit[]) public shopDailyLimit;
    mapping(address => TradeLimit[]) public tradeDailyLimit;

    constructor() {
        dailyShop.push(Shop(0, 3, (0.0001 * 1 ether)));
        dailyShop.push(Shop(1, 3, (0.0001 * 1 ether)));
        dailyShop.push(Shop(2, 3, (0.0002 * 1 ether)));

        traderTrades[0] = Trades(0, 5, 2, 1);
        traderTrades[1] = Trades(0, 50, 3, 1);
        traderTrades[2] = Trades(1, 5, 0, 30);
    }

    function setInterface(address _items, address _monsterGame) public {
        itemInterface = IItems(_items);
        monsterGameInterface = IMonsterGame(_monsterGame);
        itemNftInterface = IERC1155(_items);
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

    function buyItem(
        uint256[] calldata _item,
        uint256[] calldata _quantity,
        address _user
    ) external payable buyIfBelowLimit(_quantity) {
        ShopLimit[] storage limitStr = shopDailyLimit[_user];
        ShopLimit[] memory limitMem = shopDailyLimit[_user];
        uint256 total = getTotalPrice(_user, _item, _quantity);
        bool dailyLimit = limitMem.length == 0;
        uint256 arrLength = _quantity.length;
        if (dailyLimit) {
            for (uint256 i; i < arrLength; ++i) {
                uint256 item = _item[i];
                uint256 quantity = _quantity[i];
                limitStr.push(ShopLimit(item, quantity));
            }
        } else {
            addUserDailyLimit(_user, _item, _quantity);
        }
        require(msg.value >= total, "Wrong value of ether sent");
        itemInterface.mintForShop(_user, _item, _quantity);
    }

    function balanceOf(address _user, uint256 _tokenId)
        external
        view
        returns (uint256 balance)
    {
        balance = itemNftInterface.balanceOf(_user, 0);
    }

    function isApproved(address _user) external view returns (bool result) {
        result = itemNftInterface.isApprovedForAll(address(this), _user);
    }

    function tradeItem(
        uint256 _trade,
        uint256 _quantity,
        address _user
    ) external {
        require(_quantity <= 5, "There's only 5 stocks per trade everyday");
        tradeDailyLimit[_user].push(TradeLimit(_trade, 0));
        TradeLimit[] storage limit = tradeDailyLimit[_user];
        Trades memory trade = traderTrades[_trade];
        uint256 tradeQuantity = trade.quantityTrade * _quantity;
        uint256 receiveQuantity = trade.quantityReceived * _quantity;
        require(limit[_trade].quantity <= 5, "You hit your limit");
        require(
            itemNftInterface.balanceOf(_user, trade.itemTrade) >
                trade.quantityTrade,
            "Not enough items needed"
        );
        itemNftInterface.safeTransferFrom(
            _user,
            address(this),
            trade.itemTrade,
            tradeQuantity,
            ""
        );
        itemInterface.mintForTrade(_user, trade.itemReceived, receiveQuantity);
        limit[_trade].quantity = limit[_trade].quantity + _quantity;
    }

    function getItemIndex(uint256 _item) internal view returns (uint256 index) {
        uint256 shopLength = dailyShop.length;
        for (uint256 i; i < shopLength; ++i) {
            uint256 shopItem = dailyShop[i].item;
            if (shopItem == _item) {
                index = i;
            }
        }
    }

    function getTradeIndex(uint256 _tradeId, address _user)
        internal
        view
        returns (uint256 index)
    {
        TradeLimit[] memory limit = tradeDailyLimit[_user];
        uint256 tradeLength = limit.length;
        for (uint256 i; i < tradeLength; ++i) {
            uint256 tradeId = limit[i].tradeId;
            if (tradeId == _tradeId) {
                index = i;
            }
        }
    }

    function getTotalPrice(
        address _user,
        uint256[] memory _item,
        uint256[] memory _quantity
    ) internal view returns (uint256 total) {
        uint256 arrLength = _item.length;
        uint256 totalTemp;
        for (uint256 i; i < arrLength; ++i) {
            uint256 index = getItemIndex(_item[i]);
            uint256 quantity = _quantity[i];
            uint256 price = dailyShop[index].price;

            totalTemp += price * quantity;
        }

        total = totalTemp;
    }

    function addUserDailyLimit(
        address _user,
        uint256[] memory _item,
        uint256[] memory _quantity
    ) internal {
        uint256 arrLength = _item.length;
        ShopLimit[] storage limitStr = shopDailyLimit[_user];
        ShopLimit[] memory limitMem = shopDailyLimit[_user];
        for (uint256 i; i < arrLength; ++i) {
            uint256 index = getItemIndex(_item[i]);
            uint256 quantity = limitMem[index].quantity;
            require(_quantity[i] + quantity <= 3, "You hit your limit");
            limitStr[index].quantity = quantity + _quantity[i];
        }
    }

    function getDailyShop() external view returns (Shop[] memory) {
        return dailyShop;
    }

    receive() external payable {}
}
