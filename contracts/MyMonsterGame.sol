// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./IMonster.sol";
import "./IItems.sol";

contract MonsterGame is IERC721Receiver{

    IERC721 public monsterInterface;
    IMonster public statsInterface;
    IItems public itemsInterface;

    struct Inventory {
        uint itemId;
        uint quantity;
    }

    struct Monster {
        uint tokenId;
        uint missionStart;
        address owner;
    }
    
    uint feedingFee = 0.0001 ether;
    uint nonce = 0;

    mapping(address => Inventory[]) public playerInventory;
    mapping(address => Monster[]) public myMonsterOnBeg;
    mapping(address => Monster[]) public myMonsterOnInt;

    function setInterface(address monsterNFT, address itemNFT) public{
        monsterInterface = IERC721(monsterNFT);
        statsInterface = IMonster(monsterNFT);
        itemsInterface = IItems(itemNFT);
    }

    function claimBeginnerMission(uint _tokenId, address _user) public{
        Monster[] memory monster = myMonsterOnBeg[_user];
        uint index = getMonsterIndexBeg(_tokenId, _user);
        uint missionStart = monster[index].missionStart;
        uint hunger = statsInterface.getMonsterHunger(_tokenId);
        uint newHunger = hunger  - 10;
        uint expEarned = 4;
        // require(missionStart + 15 minutes <= block.timestamp, "Duration not over yet");
        require(checkOnBeg(_tokenId, _user) == true, "Your monster is not on beginner mission");
        statsInterface.setCooldown(_tokenId);
        statsInterface.setHunger(_tokenId, newHunger);
        statsInterface.expUp(_tokenId, expEarned);

        itemsInterface.beginnerMissionReward(_user, randomNumber());
        statsInterface.setStatus(_tokenId, 0);
        deleteMonsterOnBeg(_tokenId, _user);
    }

    function claimIntermediateMission(uint _tokenId, address _user) public{
        Monster[] memory monster = myMonsterOnInt[_user];
        uint index = getMonsterIndexInt(_tokenId, _user);
        uint missionStart = monster[index].missionStart;
        uint hunger = statsInterface.getMonsterHunger(_tokenId);
        uint newHunger = hunger  - 10;
        uint expEarned = 8;
        // require(missionStart + 30 minutes <= block.timestamp, "Duration not over yet");
        require(checkOnInt(_tokenId, _user) == true, "Your monster is not on intermediate mission");
        statsInterface.setCooldown(_tokenId);
        statsInterface.setHunger(_tokenId, newHunger);
        statsInterface.expUp(_tokenId, expEarned);

        itemsInterface.intermediateMissionReward(_user, randomNumber());
        statsInterface.setStatus(_tokenId, 0);
        deleteMonsterOnInt(_tokenId);
    }

    

    // function getInventory() public view returns(Inventory[] memory) {
    //     Inventory[] memory result = new Inventory[](addressToInventory[msg.sender]);
    //     uint counter = 0;
    //     for (uint i = 0; i < inventories.length; i++) {
    //         Inventory memory myInventory = inventories[i];
    //         if (inventoryToAddress[i] == msg.sender) {
    //             result[counter] = myInventory;
    //             counter++;
    //         }
    //     }
    //     return result;
    // }

    function feedMonster (uint _tokenId, uint _amount) public payable {
        uint monsterLevel = statsInterface.getMonsterLevel(_tokenId);
        uint monsterHunger = statsInterface.getMonsterHunger(_tokenId);

        require(msg.value == feedingFee * monsterLevel * _amount, "Not enough ether");
        require (monsterHunger < 100, "Your monster hunger is full");
        require(_amount +  monsterHunger <= 100, "Too much food for your monster");

        statsInterface.feedMonster(_tokenId, _amount);
    }

    function beginnerMission(uint _tokenId, address _user) public {
        uint monsterHunger = statsInterface.getMonsterHunger(_tokenId);
        uint monsterCooldown = statsInterface.getMonsterCooldown(_tokenId);
        uint monsterStatus = statsInterface.getMonsterStatus(_tokenId);
        
        require(monsterInterface.ownerOf(_tokenId) == _user, "It's not your monster");
        require(monsterStatus == 0, "Your monster still working on something");
        require(monsterCooldown == 0, " Your monster still on cooldown");
        require(monsterHunger >= 5, "Not enough hunger");

        statsInterface.setStatus(_tokenId, 1);
        myMonsterOnBeg[_user].push(Monster(_tokenId, block.timestamp, _user));
    }

    function intermediateMission(uint _tokenId, address _user) public {
        uint monsterLevel = statsInterface.getMonsterLevel(_tokenId);
        uint monsterHunger = statsInterface.getMonsterHunger(_tokenId);
        uint monsterCooldown = statsInterface.getMonsterCooldown(_tokenId);
        uint monsterStatus = statsInterface.getMonsterStatus(_tokenId);

        require(monsterInterface.ownerOf(_tokenId) == _user, "It's not your monster");
        require(monsterStatus == 0, "Your monster still working on something");
        require(monsterLevel > 2, "Your monster does'nt met the minimum requirement");
        require(monsterCooldown == 0, " Your monster still on cooldown");
        require(monsterHunger >= 10, "Not enough hunger");

        statsInterface.setStatus(_tokenId, 1);
        myMonsterOnInt[_user].push(Monster(_tokenId, block.timestamp, _user));
    }

    function checkItemOnInventory(uint[] memory _item, uint[] memory _quantity, address _user) public {
        Inventory[] storage inventory = playerInventory[_user];
        for(uint i; i < inventory.length ; i++) {
            if(inventory[i].itemId == _item[i]) {
                 inventory[i].quantity = inventory[i].quantity + _quantity[i];
            }
        }
        itemToInventory(_item, _quantity, _user);
    }

    function itemToInventory(uint[] memory _item, uint[] memory _quantity, address _user) public {
        Inventory[] storage inventory = playerInventory[_user];
        for(uint i; i < _item.length ; i++) {
            inventory.push(Inventory(_item[i], _quantity[i]));
        }
    }
    
    function checkSingleItemOnInventory(uint _item, uint _quantity, address _user) public {
        Inventory[] storage inventory = playerInventory[_user];
        for(uint i; i < inventory.length ; i++) {
            if(inventory[i].itemId == _item) {
                 inventory[i].quantity = inventory[i].quantity + _quantity;
            }
        }
        singleItemToInventory(_item, _quantity, _user);
    }

    function singleItemToInventory(uint _item, uint _quantity, address _user) public {
        Inventory[] storage inventory = playerInventory[_user];
        inventory.push(Inventory(_item, _quantity));
    }

    function deleteMonsterOnBeg(uint _tokenId, address _user) internal{
        Monster[] storage myMonster = myMonsterOnBeg[_user];
        uint index;
        for(uint i; i < myMonster.length; i++) {
            if(myMonster[i].tokenId == _tokenId) {
                index = i;
            }
        }
        myMonster[index] = myMonster[myMonster.length - 1];
        myMonster.pop();
    }

    function deleteMonsterOnInt(uint _tokenId) internal{
        Monster[] storage myMonster = myMonsterOnInt[msg.sender];
        uint index;
        for(uint i; i < myMonster.length; i++) {
            if(myMonster[i].tokenId == _tokenId) {
                index = i;
            }
        }
        myMonster[index] = myMonster[myMonster.length - 1];
        myMonster.pop();
    }

    function checkOnBeg(uint _tokenId, address _user) internal view returns(bool){
        bool result;
        Monster[] storage myMonster = myMonsterOnBeg[_user];
        for(uint i; i < myMonster.length; i++) {
            if(myMonster[i].tokenId == _tokenId) {
                result = true;
            }
        }
        
        return result;
    }

    function checkOnInt(uint _tokenId, address _user) internal view returns(bool){
        bool result;
        Monster[] storage myMonster = myMonsterOnInt[_user];
        for(uint i; i < myMonster.length; i++) {
            if(myMonster[i].tokenId == _tokenId) {
                result = true;
            }
        }
        
        return result;
    }

    function getMonsterIndexInt(uint _tokenId, address _user) internal view returns(uint){
        uint index;
        Monster[] storage myMonster = myMonsterOnInt[_user];
        for(uint i; i < myMonster.length; i++) {
            if(myMonster[i].tokenId == _tokenId) {
                index = i;
            }
        }
        
        return index;
    }

    function getMonsterIndexBeg(uint _tokenId, address _user) internal view returns(uint){
        uint index;
        Monster[] storage myMonster = myMonsterOnBeg[_user];
        for(uint i; i < myMonster.length; i++) {
            if(myMonster[i].tokenId == _tokenId) {
                index = i;
            }
        }
        
        return index;
    }


    function randomNumber() internal returns(uint){
        uint number = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % 100;
        nonce ++;
        return number;
    }

    function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
      return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {

    }
    
    

}