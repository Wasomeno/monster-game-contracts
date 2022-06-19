// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./IMonster.sol";
import "./IItems.sol";

contract Dungeon {

    IERC721 monsterInterface;
    IMonster statsInterface;
    IItems itemInterface;

    uint nonce;

    mapping(address => uint[]) public myMonsterOnBoss;

    function setInterface(address monsterNFT, address itemNFT) public {
        monsterInterface = IERC721(monsterNFT);
        statsInterface = IMonster(monsterNFT);
        itemInterface = IItems(itemNFT);
    }

    function bossFight(uint _tokenId, address _user) public {
        require(monsterInterface.ownerOf(_tokenId) == _user, "It's not your monster");

        uint monsterLevel = statsInterface.getMonsterLevel(_tokenId);
        uint monsterStatus = statsInterface.getMonsterStatus(_tokenId);
        uint monsterHunger = statsInterface.getMonsterHunger(_tokenId);
        uint monsterCooldown = statsInterface.getMonsterCooldown(_tokenId);

        // require(monsterStatus == 0, "Your monster still working on something");
        // require(monsterCooldown == 0, " Your monster still on cooldown");
        // require(monsterHunger >= 20, "Not enough hunger");

        statsInterface.setStatus(_tokenId, 3);
        myMonsterOnBoss[_user].push(_tokenId);
    }

    function claimBossFight(uint _tokenId, address _user) public {
        uint hunger = statsInterface.getMonsterHunger(_tokenId);
        uint newHunger = hunger  - 20;
        uint expEarned = 8;
        uint level = statsInterface.getMonsterLevel(_tokenId);

        require(checkOnBoss(_tokenId, _user) == true, "Your monster is not on boss fight");
        statsInterface.setCooldown(_tokenId);
        statsInterface.setHunger(_tokenId, newHunger);
        statsInterface.expUp(_tokenId, expEarned);

        if(level == 1) {
            itemInterface.bossFightReward(_user, randomNumber(), bossFightChance(30));
        } else if (level == 2) {
            itemInterface.bossFightReward(_user, randomNumber(), bossFightChance(60));
        } else {
            itemInterface.bossFightReward(_user, randomNumber(), bossFightChance(90));
        }
        
        statsInterface.setStatus(_tokenId, 0);
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