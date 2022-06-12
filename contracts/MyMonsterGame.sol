// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./IMonster.sol";

contract Minigame is IERC721Receiver{

    IERC721 public monsterInterface;
    IMonster public statsInterface;

    struct Inventory {
        uint itemId;
        uint quantity;
    }
    
    uint feedingFee = 0.0001 ether;
    uint nonce = 0;

    mapping(address => Inventory[]) public playerInventory;

    function setInterface(address monsterNFT) public{
        monsterInterface = IERC721(monsterNFT);
        statsInterface = IMonster(monsterNFT);
    }

    function claimBeginnerMission(uint _tokenId) public{
        uint expEarned = 4;
        uint monsterMission = statsInterface.getMonsterMissionStart(_tokenId);
        require(monsterMission + 15 minutes <= block.timestamp, "Duration not over yet");
        statsInterface.resetMissionStart(_tokenId);
        statsInterface.setCooldown(_tokenId);
        statsInterface.expUp(_tokenId, expEarned);
    }

    function claimIntermediateMission(uint _tokenId) public{
        uint expEarned = 8;
        uint monsterMission = statsInterface.getMonsterMissionStart(_tokenId);
        require(monsterMission + 30 minutes <= block.timestamp, "Duration not over yet");
        statsInterface.resetMissionStart(_tokenId);
        statsInterface.setCooldown(_tokenId);
        statsInterface.expUp(_tokenId, expEarned);
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

    function beginnerMission(uint _tokenId) public {
        uint monsterMission = statsInterface.getMonsterMissionStart(_tokenId);
        uint monsterHunger = statsInterface.getMonsterHunger(_tokenId);
        uint monsterCooldown = statsInterface.getMonsterCooldown(_tokenId);

        require(monsterInterface.ownerOf(_tokenId) == msg.sender, "It's not your monster");
        require(monsterMission == 0, "Your monster is still on a mission");
        require(monsterCooldown == 0, " Your monster still on cooldown");
        require(monsterHunger >= 5, "Not enough hunger");

        statsInterface.setMissionStart(_tokenId);
    }

    function intermediateMission(uint _tokenId, uint  _duration) public {
        require(monsterInterface.ownerOf(_tokenId) == msg.sender, "It's not your monster");

        uint monsterLevel = statsInterface.getMonsterLevel(_tokenId);
        uint monsterMission = statsInterface.getMonsterMissionStart(_tokenId);
        uint monsterHunger = statsInterface.getMonsterHunger(_tokenId);
        uint monsterCooldown = statsInterface.getMonsterCooldown(_tokenId);

        require(monsterLevel > 3, "Your monster does'nt met the minimum requirement");
        require(monsterMission == 0, "Your monster is still on a mission");
        require(monsterCooldown == 0, " Your monster still on cooldown");
        require(monsterHunger >= 5, "Not enough hunger");
    }


    function randomNumber () internal returns(uint){
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