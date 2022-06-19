// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import "./IItems.sol";
import "./IMonsterGame.sol";

contract Trader is ERC1155Receiver{

    struct Shop {
        uint item;
        uint quantity;
        uint price;
    }

    struct ShopLimit {
        uint item;
        uint quantity;
    }

    struct Trades {
        uint itemTrade;
        uint quantityTrade;
        uint itemReceived;
        uint quantityReceived;
    }

    struct TradeLimit {
        uint tradeId;
        uint quantity;
    }

    IItems itemInterface;
    IMonsterGame monsterGameInterface;
    IERC1155 itemNftInterface;
    Shop[] public dailyShop;

    mapping(uint => Trades) public traderTrades;
    mapping(address => ShopLimit[]) public shopDailyLimit;
    mapping(address => TradeLimit[]) public tradeDailyLimit;

    constructor() {
        dailyShop.push(Shop(0, 3, (0.0001 * 1 ether)));
        dailyShop.push(Shop(1, 3, (0.0001 * 1 ether)));
        dailyShop.push(Shop(2, 3, (0.0002 * 1 ether)));

        traderTrades[0] = Trades(0, 30, 2, 1);
        traderTrades[1] = Trades(0, 50, 3, 1);
        traderTrades[2] = Trades(1, 5, 0, 30);
    }

     function setInterface(address _items, address _monsterGame) public {
        itemInterface = IItems(_items);
        monsterGameInterface = IMonsterGame(_monsterGame);
        itemNftInterface = IERC1155(_items);
    }

    function buyItem(uint _item, uint _quantity, address _user) public payable{
        require(_quantity <= 3, "There's only 3 stocks per item everyday");
        uint index = getItemIndex(_item, _user);
        shopDailyLimit[_user].push(ShopLimit(0, 0));
        ShopLimit[] storage limit = shopDailyLimit[_user];
        
        require(limit[index].quantity <= 3, "You hit your limit");
        require(msg.value == dailyShop[index].price * _quantity, "Wrong value of ether sent");
        itemInterface.mintForShop( _user, _item, _quantity);
        monsterGameInterface.checkSingleItemOnInventory(_item, _quantity, _user);
        limit[index].quantity = limit[index].quantity + _quantity;
    }

    function tradeItem(uint _trade, uint _quantity, address _user) public payable{
        require(_quantity <= 5, "There's only 5 stocks per trade everyday");
        uint index = getTradeIndex(_trade, _user);
        tradeDailyLimit[_user].push(TradeLimit(_trade, 0));
        TradeLimit[] storage limit = tradeDailyLimit[_user];
        Trades memory trade = traderTrades[_trade];

        require(limit[index].quantity <= 5, "You hit your limit");
        require(itemNftInterface.balanceOf(_user, trade.itemTrade) > trade.quantityTrade, "You don't have enough items needed or the trade");
        itemNftInterface.safeTransferFrom(_user, address (this), trade.itemTrade, trade.quantityTrade, "");
        itemNftInterface.safeTransferFrom(address (this), _user, trade.itemReceived, trade.quantityReceived, ""); 
    }

    function getItemIndex(uint _item, address _user) internal view returns(uint){
        uint index;
        for(uint i; i < dailyShop.length; i++) {
            if(dailyShop[i].item == _item) {
                index = i;
            }
        }
        return index;
    }

    function getTradeIndex(uint _tradeId, address _user) internal view returns(uint){
        uint index;
        TradeLimit[] memory limit = tradeDailyLimit[_user];

        for(uint i; i < limit.length; i++) {
            if(limit[i].tradeId == _tradeId) {
                index = i;
            }
        }

        return index;
    }


    function onERC1155BatchReceived(
    address _operator,
    address _from,
    uint256[] calldata _ids,
    uint256[] calldata _values,
    bytes calldata _data
    ) external pure override returns(bytes4) {
        bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
    }

    function onERC1155Received (
    address _operator,
    address _from,
    uint256 _id,
    uint256 _value,
    bytes calldata _data
    ) external pure override returns(bytes4) {
        bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }
    
    receive() external payable {

    }


}