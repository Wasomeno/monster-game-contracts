// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./IMonster.sol";

contract Nursery is ERC1155Receiver{

    struct Rest{
        uint monster;
        address owner;
        uint duration;
    }

    struct Item {
        uint item;
        uint quantity;
        uint price;
    }

    IMonster monsterInterface;
    IERC1155 itemInterface;

    mapping(address => Rest[]) public monsterOnNursery;
    mapping(uint => Item) public nurseryShop;

    function setInterface(address _monsterNFT, address _itemNFT) public {
        monsterInterface = IMonster(_monsterNFT);
        itemInterface = IERC1155(_itemNFT);
    }

    function putOnNursery(uint _tokenId, address _user, uint _duration) public {
        uint hunger = monsterInterface.getMonsterHunger(_tokenId);
        uint status = monsterInterface.getMonsterStatus(_tokenId);
        require(status == 0, "Your monster still working on something");
        require(_duration * 10 + hunger <= 100, "Reduce the duration");
        Rest[] storage rest = monsterOnNursery[_user];
        rest.push(Rest(_tokenId, _user, _duration));
        monsterInterface.setStatus(_tokenId, 2);
    }

    function goBackHome(uint _tokenId, address _user) public {
        Rest[] memory myMonster = monsterOnNursery[_user];
        uint index = getMonsterIndex(_tokenId, _user);
        uint hunger = monsterInterface.getMonsterHunger(_tokenId);
        uint duration = myMonster[index].duration;
        uint newHunger = duration * 10;
        monsterInterface.feedMonster(_tokenId, newHunger);
        monsterInterface.setStatus(_tokenId, 0);
        deleteMonster(_tokenId, _user);
    }

    function buyItem(uint _shopId, uint _quantity, address _user) public payable{
        Item storage itemShop = nurseryShop[_shopId];
        Item memory _itemShop = nurseryShop[_shopId];
        require(_quantity <= 3, "There's only 3 stocks per item everyday");
        require(_itemShop.quantity > 0, "No stock left");
        require(msg.value == _itemShop.price * _quantity, "Wrong value of ether sent");
        itemInterface.safeTransferFrom(address (this), _user, _itemShop.item, _quantity, "");
        itemShop.quantity = _itemShop.quantity - _quantity;
    }

    function getMonsterIndex(uint _tokenId, address _user) public view returns(uint index) {
        Rest[] memory monsters = monsterOnNursery[_user];
        uint length = monsters.length;
        for(uint i; i < length; ++i) {
            Rest memory monster = monsters[i];
            if(monster.monster == _tokenId) {
                index = i;
            }
        }
    }

    function deleteMonster(uint _tokenId, address _user) public {
        uint index;
        Rest[] storage myMonsterStr = monsterOnNursery[_user];
        Rest[] memory myMonsterMem = monsterOnNursery[_user];
        uint length = myMonsterMem.length;
        for(uint i; i < length; ++i) {
            uint monster = myMonsterMem[i].monster; 
            if(monster == _tokenId) {
                index = i;
            }
        }
        myMonsterStr[index] = myMonsterMem[length - 1];
        myMonsterStr.pop();
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
}