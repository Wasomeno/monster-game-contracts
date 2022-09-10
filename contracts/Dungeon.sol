// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./IMonster.sol";
import "./IItems.sol";

contract Dungeon {
    struct Details {
        uint256[] monsters;
        uint256 startTime;
        address owner;
    }

    IERC721 monsterInterface;
    IMonster statsInterface;
    IItems itemInterface;

    uint256 nonce;
    mapping(address => Details) public monstersOnDungeon;
    mapping(address => bool) public dungeoningStatus;

    modifier isDungeoning(address _user) {
        bool status = dungeoningStatus[_user];
        require(status, "You're not dungeoning");
        _;
    }

    modifier isNotDungeoning(address _user) {
        bool status = dungeoningStatus[_user];
        require(!status, "You're still dungeoning");
        _;
    }

    function setInterface(address monsterNFT, address itemNFT) public {
        monsterInterface = IERC721(monsterNFT);
        statsInterface = IMonster(monsterNFT);
        itemInterface = IItems(itemNFT);
    }

    function startDungeon(uint256[] calldata _monsters, address _user)
        external
        isNotDungeoning(_user)
    {
        require(_monsters.length <= 6, "Exceed Limit");
        for (uint256 i; i < _monsters.length; ++i) {
            uint256 monster = _monsters[i];
            uint256 level = statsInterface.getMonsterLevel(monster);
            uint256 status = statsInterface.getMonsterStatus(monster);
            uint256 hunger = statsInterface.getMonsterHunger(monster);
            uint256 cooldown = statsInterface.getMonsterCooldown(monster);
            require(
                cooldown <= block.timestamp,
                " Your monster is on cooldown"
            );
            require(status == 0, "Your monster is active");
            require(hunger >= 20, "Not enough hunger");
            statsInterface.setStatus(monster, 3);
        }
        monstersOnDungeon[_user] = Details(_monsters, block.timestamp, _user);
    }

    function finishDungeon(address _user) external isDungeoning(_user) {
        uint256[] memory monsters = monstersOnDungeon[_user].monsters;
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
        deleteUserDetails(_user);
    }

    function deleteUserDetails(address _user) internal {
        Details memory details = monstersOnDungeon[_user];
        delete details;
    }

    function getMonstersOnDungeon(address _user)
        external
        view
        returns (uint256[] memory _monsters)
    {
        _monsters = monstersOnDungeon[_user].monsters;
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
