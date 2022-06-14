// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;
import "./IMonster.sol";
import "./IItems.sol";

contract Dungeon {

    IMonster monsterInterface;
    IItems itemInterface;

    mapping(address => uint[]) public myMonsterOnBoss;

    function setInterface(address monsterNFT, address itemNFT) public {
        monsterInterface = IMonster(monsterNFT);
        itemsInterface = IItems(itemInterface);
    }

    function bossFight(uint _tokenId, address _user) public {
        require(monsterInterface.ownerOf(_tokenId) == _user, "It's not your monster");

        uint monsterLevel = monsterInterface.getMonsterLevel(_tokenId);
        uint monsterMission = monsterInterface.getMonsterMissionStart(_tokenId);
        uint monsterHunger = monsterInterface.getMonsterHunger(_tokenId);
        uint monsterCooldown = monsterInterface.getMonsterCooldown(_tokenId);

        require(monsterLevel > 3, "Your monster does'nt met the minimum requirement");
        require(monsterMission == 0, "Your monster is still on a mission");
        require(monsterCooldown == 0, " Your monster still on cooldown");
        require(monsterHunger >= 20, "Not enough hunger");

        monsterInterface.setStatus(_tokenId, 3);
        myMonsterOnBoss[_user].push(_tokenId);
    }

    function claimBossFight(uint _tokenId, address _user) public {
        uint hunger = monsterInterface.getMonsterHunger(_tokenId);
        uint newHunger = hunger  - 20;
        uint expEarned = 8;
        uint level = monsterInterface.getMonsterLevel(_tokenId);
        uint monsterMission = monsterInterface.getMonsterMissionStart(_tokenId);

        require(checkOnBoss(_tokenId, _user) == true, "Your monster is not on boss fight");
        monsterInterface.setCooldown(_tokenId);
        monsterInterface.setHunger(_tokenId, newHunger);
        monsterInterface.expUp(_tokenId, expEarned);

        if(level == 1) {
            itemsInterface.bossFightReward(_user, randomNumber(), bossFightChance(30));
        } else if (level == 2) {
            itemsInterface.bossFightReward(_user, randomNumber(), bossFightChance(60));
        } else {
            itemsInterface.bossFightReward(_user, randomNumber(), bossFightChance(90));
        }
        
        monsterInterface.setStatus(_tokenId, 0);
        deleteMonsterOnBoss(_tokenId, _user);
    }

    function checkOnBoss(uint _tokenId, address _user) internal view returns(bool){
        bool result;
        uint[] storage myMonster = myMonsterOnBoss[_user];
        for(uint i; i < myMonster.length; i++) {
            if(myMonster[i] == _tokenId) {
                result = true;
            }
        }
        
        return result;
    }

    function deleteMonsterOnBoss(uint _tokenId, address _user) internal{
        uint[] storage myMonster = myMonsterOnBoss[_user];
        uint index;
        for(uint i; i < myMonster.length; i++) {
            if(myMonster[i] == _tokenId) {
                index = i;
            }
        }
        myMonster[index] = myMonster[myMonster.length - 1];
        myMonster.pop();
    }

    function randomNumber() internal returns(uint){
        uint number = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % 100;
        nonce ++;
        return number;
    }

    function bossFightChance(uint _limit) internal returns(uint) {
        uint number = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % _limit;
        nonce ++;
        return number;
    }
}