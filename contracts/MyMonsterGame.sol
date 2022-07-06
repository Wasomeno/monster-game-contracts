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
    
    uint public feedingFee = 0.0001 ether;
    uint private nonce = 0;

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
        require(checkOnBeg(_tokenId, _user), "Your monster is not on beginner mission");
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
        require(checkOnInt(_tokenId, _user), "Your monster is not on intermediate mission");
        statsInterface.setCooldown(_tokenId);
        statsInterface.setHunger(_tokenId, newHunger);
        statsInterface.expUp(_tokenId, expEarned);

        itemsInterface.intermediateMissionReward(_user, randomNumber());
        statsInterface.setStatus(_tokenId, 0);
        deleteMonsterOnInt(_tokenId);
    }

    function feedIfPassed(uint _monsterLevel, uint _monsterHunger, uint _amount) internal view returns(bool result){
        require(msg.value == feedingFee * _monsterLevel * _amount, "Not enough ether");
        require (_monsterHunger < 100, "Your monster hunger is full");
        require(_amount + _monsterHunger <= 100, "Too much food for your monster");
        result = true;
    }

    function startBeginnerIfPassed(uint _monsterHunger, uint _monsterCooldown, uint _monsterStatus) internal pure returns(bool result){
        require(_monsterStatus == 0, "Your monster still working on something");
        require(_monsterCooldown == 0, " Your monster still on cooldown");
        require(_monsterHunger >= 5, "Not enough hunger");
        result = true;
    }

    function startIntermediateIfPassed(uint _monsterHunger, uint _monsterCooldown, uint _monsterStatus, uint _monsterLevel) internal pure returns(bool result){
        require(_monsterStatus == 0, "Your monster still working on something");
        require(_monsterLevel > 2, "Your monster does'nt met the minimum requirement");
        require(_monsterCooldown == 0, " Your monster still on cooldown");
        require(_monsterHunger >= 10, "Not enough hunger");
        result = true;
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

    function feedMonster (uint _tokenId, uint _amount) public payable{
        uint monsterLevel = statsInterface.getMonsterLevel(_tokenId);
        uint monsterHunger = statsInterface.getMonsterHunger(_tokenId);
        require(feedIfPassed(monsterLevel, monsterHunger, _amount));
        statsInterface.feedMonster(_tokenId, _amount);
    }

    function beginnerMission(uint _tokenId, address _user) public {
        uint monsterHunger = statsInterface.getMonsterHunger(_tokenId);
        uint monsterCooldown = statsInterface.getMonsterCooldown(_tokenId);
        uint monsterStatus = statsInterface.getMonsterStatus(_tokenId);
        require(monsterInterface.ownerOf(_tokenId) == _user, "It's not your monster");
        require(startBeginnerIfPassed(monsterHunger, monsterCooldown, monsterStatus));
        statsInterface.setStatus(_tokenId, 1);
        myMonsterOnBeg[_user].push(Monster(_tokenId, block.timestamp, _user));
    }

    function intermediateMission(uint _tokenId, address _user) public {
        uint monsterLevel = statsInterface.getMonsterLevel(_tokenId);
        uint monsterHunger = statsInterface.getMonsterHunger(_tokenId);
        uint monsterCooldown = statsInterface.getMonsterCooldown(_tokenId);
        uint monsterStatus = statsInterface.getMonsterStatus(_tokenId);
        require(monsterInterface.ownerOf(_tokenId) == _user, "It's not your monster");
        require(startIntermediateIfPassed(monsterHunger, monsterCooldown, monsterStatus, monsterLevel));
        statsInterface.setStatus(_tokenId, 1);
        myMonsterOnInt[_user].push(Monster(_tokenId, block.timestamp, _user));
    }

    function checkItemOnInventory(uint[] memory _item, uint[] memory _quantity, address _user) external {
        Inventory[] storage inventoryStr = playerInventory[_user];
        uint length = inventoryStr.length;
        for(uint i; i < length ; ++i){
            Inventory[] memory inventoryMem = playerInventory[_user];
            if(inventoryMem[i].itemId == _item[i]) {
                uint quantity = inventoryMem[i].quantity;
                 inventoryStr[i].quantity =  quantity + _quantity[i];
            }
        }
        itemToInventory(_item, _quantity, _user);
    }

    function itemToInventory(uint[] memory _item, uint[] memory _quantity, address _user) internal {
        Inventory[] storage inventory = playerInventory[_user];
        for(uint i; i < _item.length ; ++i) {
            inventory.push(Inventory(_item[i], _quantity[i]));
        }
    }
    
    function checkSingleItemOnInventory(uint _item, uint _quantity, address _user) external {
        Inventory[] storage inventoryStr = playerInventory[_user];
        uint length = inventoryStr.length;
        for(uint i; i < length ; ++i) {
            Inventory[] memory inventoryMem = playerInventory[_user];
            if(inventoryMem[i].itemId == _item) {
                uint quantity = inventoryMem[i].quantity;
                inventoryStr[i].quantity = quantity + _quantity;
            }
        }
        singleItemToInventory(_item, _quantity, _user);
    }

    function singleItemToInventory(uint _item, uint _quantity, address _user) internal {
        Inventory[] storage inventory = playerInventory[_user];
        inventory.push(Inventory(_item, _quantity));
    }

    function deleteMonsterOnBeg(uint _tokenId, address _user) internal{
        uint index;
        Monster[] storage myMonsterStr = myMonsterOnBeg[_user];
        Monster[] memory myMonsterMem = myMonsterOnBeg[_user];
        uint length = myMonsterMem.length;
        for(uint i; i < length; ++i) {
            if(myMonsterMem[i].tokenId == _tokenId) {
                index = i;
            }
        }
        myMonsterStr[index] = myMonsterMem[length - 1];
        myMonsterStr.pop();
    }

    function deleteMonsterOnInt(uint _tokenId) internal{
        uint index;
        Monster[] storage myMonsterStr = myMonsterOnInt[msg.sender];
        Monster[] memory myMonsterMem = myMonsterOnInt[msg.sender];
        uint length = myMonsterMem.length;
        for(uint i; i <length; ++i) {
            uint tokenId = myMonsterMem[i].tokenId; 
            if(tokenId == _tokenId) {
                index = i;
            }
        }
        myMonsterStr[index] = myMonsterMem[length - 1];
        myMonsterStr.pop();
    }

    function checkOnBeg(uint _tokenId, address _user) internal view returns(bool result){
        Monster[] memory myMonster = myMonsterOnBeg[_user];
        uint length = myMonster.length;
        for(uint i; i < length; ++i) {
            uint tokenId = myMonster[i].tokenId;
            if(tokenId == _tokenId) {
                result = true;
            }
        }
    }

    function checkOnInt(uint _tokenId, address _user) internal view returns(bool result){
        Monster[] memory myMonster = myMonsterOnInt[_user];
        uint length = myMonster.length;
        for(uint i; i < length; ++i) {
             uint tokenId = myMonster[i].tokenId;
            if(tokenId == _tokenId) {
                result = true;
            }
        }
    }

    function getMonsterIndexInt(uint _tokenId, address _user) internal view returns(uint index){
        Monster[] memory myMonster = myMonsterOnInt[_user];
        uint length = myMonster.length;
        for(uint i; i < length; ++i) {
             uint tokenId = myMonster[i].tokenId;
            if(tokenId == _tokenId) {
                index = i;
            }
        }
    }

    function getMonsterIndexBeg(uint _tokenId, address _user) internal view returns(uint index){
        Monster[] memory myMonster = myMonsterOnBeg[_user];
        uint length = myMonster.length;
        for(uint i; i < length; ++i) {
             uint tokenId = myMonster[i].tokenId;
            if(tokenId == _tokenId) {
                index = i;
            }
        }
    }


    function randomNumber() internal returns(uint number){
        number = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % 100;
        nonce ++;
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