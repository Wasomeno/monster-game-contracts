// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract Trader is ERC1155Receiver{

    struct Shop {
        uint item;
        uint quantity;
        uint price;
    }

    struct Trades {
        uint itemTrade;
        uint quantityTrade;
        uint itemReceived;
        uint quantityReceived;
    }

    IERC1155 itemInterface;

    mapping(uint => Trades) public traderTrades;
    mapping(address => Shop[]) public dailyShop;

    constructor() {

    }

     function setInteface(address _items) public {
        itemInterface = IERC1155(_items);
    }

    function buyItem(uint _item, uint _quantity, address _user) public payable{
        require(_quantity <= 3, "There's only 3 stocks per item everyday");
        uint index = getItemIndex(_item, _user);
        Shop[] storage items = dailyShop[_user];
        
        require(items[index].quantity > 0, "No stock left");
        require(msg.value == items[index].price * _quantity, "Wrong value of ether sent");
        itemInterface.safeTransferFrom(address (this), _user, items[index].item, _quantity, "");
        items[index].quantity = items[index].quantity - _quantity;

    }

    function tradeItem(uint _trade, uint _quantity, address _user) public payable{
        Trades memory trade = traderTrades[_trade];
        require(itemInterface.balanceOf(_user, trade.itemTrade) < trade.quantityTrade, "You don't have enough items needed or the trade");
        itemInterface.safeTransferFrom(_user, address (this), trade.itemTrade, trade.quantityTrade, "");
        itemInterface.safeTransferFrom(address (this), _user, trade.itemReceived, trade.quantityReceived, "");
    }

    function getItemIndex(uint _item, address _user) internal view returns(uint){
        uint index;
        Shop[] storage items = dailyShop[_user];
        for(uint i; i < items.length; i++) {
            if(items[i].item == _item) {
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