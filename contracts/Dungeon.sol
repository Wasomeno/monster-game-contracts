// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./IMonster.sol";
import "./IItems.sol";

contract Dungeon {
    IERC721 monsterInterface;
    IMonster statsInterface;
    IItems itemInterface;

    uint256 nonce;

    mapping(address => uint256[]) public myMonsterOnBoss;

    function setInterface(address monsterNFT, address itemNFT) public {
        monsterInterface = IERC721(monsterNFT);
        statsInterface = IMonster(monsterNFT);
        itemInterface = IItems(itemNFT);
    }

    function bossFight(uint256 _tokenId, address _user) public {
        require(
            monsterInterface.ownerOf(_tokenId) == _user,
            "It's not your monster"
        );

        uint256 monsterLevel = statsInterface.getMonsterLevel(_tokenId);
        uint256 monsterStatus = statsInterface.getMonsterStatus(_tokenId);
        uint256 monsterHunger = statsInterface.getMonsterHunger(_tokenId);
        uint256 monsterCooldown = statsInterface.getMonsterCooldown(_tokenId);

        require(monsterStatus == 0, "Your monster still working on something");
        require(monsterCooldown == 0, " Your monster still on cooldown");
        require(monsterHunger >= 20, "Not enough hunger");

        statsInterface.setStatus(_tokenId, 3);
        myMonsterOnBoss[_user].push(_tokenId);
    }

    function claimBossFight(uint256 _tokenId, address _user) public {
        uint256 hunger = statsInterface.getMonsterHunger(_tokenId);
        uint256 newHunger = hunger - 20;
        uint256 expEarned = 8;
        uint256 level = statsInterface.getMonsterLevel(_tokenId);

        require(
            checkOnBoss(_tokenId, _user),
            "Your monster is not on boss fight"
        );
        statsInterface.setCooldown(_tokenId);
        statsInterface.setHunger(_tokenId, newHunger);
        statsInterface.expUp(_tokenId, expEarned);

        if (level == 1) {
            itemInterface.bossFightReward(
                _user,
                randomNumber(),
                bossFightChance(30)
            );
        } else if (level == 2) {
            itemInterface.bossFightReward(
                _user,
                randomNumber(),
                bossFightChance(60)
            );
        } else {
            itemInterface.bossFightReward(
                _user,
                randomNumber(),
                bossFightChance(90)
            );
        }

        statsInterface.setStatus(_tokenId, 0);
        deleteMonsterOnBoss(_tokenId, _user);
    }

    function checkOnBoss(uint256 _tokenId, address _user)
        internal
        view
        returns (bool result)
    {
        uint256[] memory myMonster = myMonsterOnBoss[_user];
        uint256 length = myMonster.length;
        for (uint256 i; i < length; ++i) {
            uint256 monster = myMonster[i];
            if (monster == _tokenId) {
                result = true;
            }
        }
    }

    function deleteMonsterOnBoss(uint256 _tokenId, address _user) internal {
        uint256[] storage myMonster = myMonsterOnBoss[_user];
        uint256[] memory myMonsterMem = myMonsterOnBoss[_user];
        uint256 arrLength = myMonsterMem.length;
        uint256 index;
        for (uint256 i; i < arrLength; ++i) {
            uint256 monster = myMonsterMem[i];
            if (myMonster[i] == _tokenId) {
                index = i;
            }
        }
        myMonster[index] = myMonster[myMonster.length - 1];
        myMonster.pop();
    }

    function randomNumber() internal returns (uint256) {
        uint256 number = uint256(
            keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))
        ) % 100;
        nonce++;
        return number;
    }

    function bossFightChance(uint256 _limit) internal returns (uint256) {
        uint256 number = uint256(
            keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))
        ) % _limit;
        nonce++;
        return number;
    }
}
