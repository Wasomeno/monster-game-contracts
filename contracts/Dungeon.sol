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

    function bossFight(uint256[] calldata _monsters, address _user) external {
        require(_monsters.length <= 6, "Exceed Limit");
        for (uint256 i; i < _monsters.length; ++i) {
            uint256 monster = _monsters[i];
            uint256 monsterLevel = statsInterface.getMonsterLevel(monster);
            uint256 monsterStatus = statsInterface.getMonsterStatus(monster);
            uint256 monsterHunger = statsInterface.getMonsterHunger(monster);
            uint256 monsterCooldown = statsInterface.getMonsterCooldown(
                monster
            );
            require(
                monsterStatus == 0,
                "Your monster still working on something"
            );
            require(
                monsterCooldown <= block.timestamp,
                " Your monster still on cooldown"
            );
            require(monsterHunger >= 20, "Not enough hunger");
            statsInterface.setStatus(monster, 3);
            monstersOnBossDetails[_user][monster] = Details(
                monster,
                block.timestamp,
                msg.sender
            );
        }
        monstersOnBoss[_user] = _monsters;
    }

    function claimBossFight(address _user) external {
        uint256[] memory monsters = monstersOnBoss[_user];
        for (uint256 i; i < monsters.length; ++i) {
            uint256 monster = monsters[i];
            uint256 hunger = statsInterface.getMonsterHunger(monster);
            uint256 newHunger = hunger - 20;
            uint256 expEarned = 8;
            uint256 level = statsInterface.getMonsterLevel(monster);
            uint256 odds = bossFightChance(level * 30);
            statsInterface.setCooldown(monster);
            statsInterface.setHunger(monster, newHunger);
            statsInterface.expUp(monster, expEarned);
            itemInterface.bossFightReward(monster, _user, randomNumber(), odds);
            statsInterface.setStatus(monster, 0);
        }

        deleteMonsterOnBoss(_user);
    }

    function deleteMonsterOnBoss(address _user) internal {
        uint256[] memory monsters = monstersOnBoss[_user];
        for (uint256 i; i < monsters.length; ++i) {
            uint256 monster = monsters[i];
            Details memory details = monstersOnBossDetails[_user][monster];
            delete details.owner;
            delete details.startTime;
            delete details.tokenId;
        }
        delete monsters;
    }

    function getMonstersOnDungeon(address _user)
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
