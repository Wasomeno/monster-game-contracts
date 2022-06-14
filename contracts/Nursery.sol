// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./IMonster.sol";
import "./IItems.sol";

contract Nursery {

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
    IItems itemInterface;

    mapping(address => Rest[]) public monsterOnNursery;
    mapping(uint => Item) public nurseryShop;


    function setInterface(address _monsterNFT, address _itemNFT) public {
        monsterInterface = IMonster(_monsterNFT);
        itemInterface = IItems(_itemsNFT);
    }

    function putOnNursery(uint _monster, address _user, uint _duration) public {
        uint hunger = monsterInterface.getMonsterHunger(_monster);
        require(_duration * 10 + hunger <= 100, "Reduce the duration");
        Rest[] storage rest = monsterOnNursery[_user];
        rest.push(Rest(_monster, _user, _duration));
    }

    function goBackHome(uint _monster, address _user) public {
        Rest[] memory myMonster = monsterOnNursery[_user];

        uint index = getMonsterIndex(_monster, _user);
        uint hunger = monsterInterface.getMonsterHunger(_monster);
        uint duration = myMonster[index].duration;
        uint newHunger = duration * 10;

        monsterInterface.feedMonster(_monster, newHunger);
        deleteMonster(_monster, _user);

    }

    function buyItem(uint _shopId, uint _quantity, address _user) public payable{
        Item storage itemShop = nurseryShop[_shopId];
        
        require(_quantity <= 3, "There's only 3 stocks per item everyday");
        require(itemShop.quantity > 0, "No stock left");
        require(msg.value == itemShop.price * _quantity, "Wrong value of ether sent");
        
        itemInterface.safeTransferFrom(address (this), _user, itemShop.item, _quantity, "");
        itemShop.quantity = itemShop.quantity - _quantity;
    }

    function getMonsterIndex(uint _monster, address _user) public view returns(uint) {
        uint index;
        Rest[] storage monsters = monsterOnNursery[_user];
        for(uint i; i < monsters.length; i++) {
            if(monsters[i].monster == _monster) {
                index = i;
            }
        }
        return index;
    }

    function deleteMonster(uint _monster, address _user) public {
        Rest[] storage myMonster = monsterOnNursery[_user];
        uint index;
        for(uint i; i < myMonster.length; i++) {
            if(myMonster[i].monster == _monster) {
                index = i;
            }
        }
        myMonster[index] = myMonster[myMonster.length - 1];
        myMonster.pop();
    }
}