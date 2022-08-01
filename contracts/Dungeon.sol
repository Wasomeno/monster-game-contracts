// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./IMonster.sol";
import "./IItems.sol";

contract Dungeon {
    struct Details {
        uint256 tokenId;
        uint256 startTime;
        address owner;
    }

    IERC721 monsterInterface;
    IMonster statsInterface;
    IItems itemInterface;

    uint256 nonce;

    mapping(address => uint256[]) public monstersOnBoss;
    mapping(address => mapping(uint256 => Details))
        public monstersOnBossDetails;

    function setInterface(address monsterNFT, address itemNFT) public {
        monsterInterface = IERC721(monsterNFT);
        statsInterface = IMonster(monsterNFT);
        itemInterface = IItems(itemNFT);
    }

    function bossFight(uint256 _tokenId, address _user) external {
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
        monstersOnBoss[_user].push(_tokenId);
        monstersOnBossDetails[_user][_tokenId] = Details(
            _tokenId,
            block.timestamp,
            msg.sender
        );
    }

    function claimBossFight(uint256 _tokenId, address _user)
        external
        isOnBoss(_tokenId, _user)
    {
        uint256 hunger = statsInterface.getMonsterHunger(_tokenId);
        uint256 newHunger = hunger - 20;
        uint256 expEarned = 8;
        uint256 level = statsInterface.getMonsterLevel(_tokenId);
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

    modifier isOnBoss(uint256 _tokenId, address _user) {
        bool result;
        uint256[] memory monsters = monstersOnBoss[_user];
        for (uint256 i; i < monsters.length; ++i) {
            uint256 monster = monsters[i];
            if (_tokenId == monster) {
                result = true;
            }
        }
        require(result, "Monster Not Found");
        _;
    }

    function deleteMonsterOnBoss(uint256 _tokenId, address _user) internal {
        uint256 index;
        uint256[] storage monsters = monstersOnBoss[_user];
        Details storage details = monstersOnBossDetails[_user][_tokenId];
        uint256 monstersLength = monsters.length;

        delete details.owner;
        delete details.startTime;
        delete details.tokenId;

        for (uint256 i; i < monstersLength; ++i) {
            uint256 monster = monsters[i];
            if (monster == _tokenId) {
                index = i;
            }
        }
        monsters[index] = monsters[monstersLength - 1];
        monsters.pop();
    }

    function getMyMonsters(address _user)
        external
        view
        returns (Details[] memory)
    {
        uint256[] memory monsters = monstersOnBoss[_user];
        Details[] memory monstersDetails = new Details[](monsters.length);
        for (uint256 i; i < monsters.length; ++i) {
            uint256 monsterId = monsters[i];
            monstersDetails[i] = monstersOnBossDetails[_user][monsterId];
        }
        return monstersDetails;
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
