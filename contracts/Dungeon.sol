// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IMonster.sol";
import "./IUsersData.sol";
import "./IItems.sol";

contract Dungeon is Ownable {
    struct Details {
        uint8 monstersAmount;
        mapping(uint256 => uint8) monsters;
        uint16 startTime;
        address owner;
    }

    IMonster public monstersInterface;
    IItems public itemInterface;
    IUsersData public usersDataInterface;

    uint256 internal nonce;
    mapping(address => Details) public monstersOnDungeon;
    mapping(address => bool) public dungeoningStatus;

    error NotDungeoning(bool _status);
    error IsDungeoning(bool _status);
    error NotValidToFinishDungeon(uint256 _timeElapsed, uint256 _timeNow);
    error MonstersAmountNotValid(uint256 _amount, uint256 _limit);
    error NotValidToDungeon(
        uint256 _status,
        uint256 _cooldown,
        uint256 _energy
    );

    modifier isDungeoning() {
        bool status = dungeoningStatus[msg.sender];
        if (!status) {
            revert NotDungeoning(status);
        }
        _;
    }

    modifier isNotDungeoning() {
        bool status = dungeoningStatus[msg.sender];
        if (status) {
            revert IsDungeoning(status);
        }
        _;
    }

    modifier isRegistered() {
        usersDataInterface.checkRegister(msg.sender);
        _;
    }

    function setInterface(
        address _monstersContract,
        address _itemsContract,
        address _usersDataContract
    ) external onlyOwner {
        monstersInterface = IMonster(_monstersContract);
        itemInterface = IItems(_itemsContract);
        usersDataInterface = IUsersData(_usersDataContract);
    }

    function startDungeon(uint256[] calldata _monsters)
        external
        isNotDungeoning
        isRegistered
    {
        if (_monsters.length > 6) {
            revert MonstersAmountNotValid(_monsters.length, 6);
        }
        Details storage details = monstersOnDungeon[msg.sender];
        for (uint256 i; i < _monsters.length; ++i) {
            uint256 monster = _monsters[i];
            uint256 level = monstersInterface.getMonsterLevel(monster);
            uint256 status = monstersInterface.getMonsterStatus(monster);
            uint256 energy = monstersInterface.getMonsterEnergy(monster);
            uint256 cooldown = monstersInterface.getMonsterCooldown(monster);
            address owner = monstersInterface.monsterOwner(monster);
            if (
                status != 0 ||
                cooldown > block.timestamp ||
                owner != msg.sender ||
                energy < 20
            ) {
                revert NotValidToDungeon(status, cooldown, energy);
            }
            monstersInterface.setStatus(monster, 3);
            details.monsters[i] = uint8(monster);
        }
        details.monstersAmount = uint8(_monsters.length);
        details.owner = msg.sender;
        details.startTime = uint16(block.timestamp);
        dungeoningStatus[msg.sender] = true;
    }

    function finishDungeon() external isDungeoning {
        Details storage details = monstersOnDungeon[msg.sender];
        uint256[] memory monsters = getMonstersOnDungeon(msg.sender);
        uint256 expEarned = 8;
        uint256 elapsedTime = details.startTime + 30 minutes;
        if (elapsedTime > block.timestamp) {
            revert NotValidToFinishDungeon(elapsedTime, block.timestamp);
        }
        for (uint256 i; i < monsters.length; ++i) {
            uint256 monster = monsters[i];
            uint256 energy = monstersInterface.getMonsterEnergy(monster);
            uint256 newEnergy = energy - 20;
            uint256 level = monstersInterface.getMonsterLevel(monster);
            uint256 odds = bossFightChance(level * 30);
            monstersInterface.setCooldown(monster);
            monstersInterface.setEnergy(monster, newEnergy);
            monstersInterface.expUp(monster, expEarned);
            itemInterface.bossFightReward(
                monster,
                msg.sender,
                randomNumber(),
                odds
            );
            monstersInterface.setStatus(monster, 0);
        }
        deleteDetails(msg.sender);
        dungeoningStatus[msg.sender] = false;
    }

    function getMonstersOnDungeon(address _user)
        public
        view
        returns (uint256[] memory _monsters)
    {
        Details storage details = monstersOnDungeon[_user];
        uint256 amount = details.monstersAmount;
        _monsters = new uint256[](amount);
        for (uint256 i; i < amount; ++i) {
            uint256 monster = details.monsters[i];
            _monsters[i] = monster;
        }
    }

    function deleteDetails(address _user) internal {
        Details storage details = monstersOnDungeon[_user];
        delete details.monstersAmount;
        delete details.owner;
        delete details.startTime;
        deleteMonsters(_user);
    }

    function deleteMonsters(address _user) internal {
        Details storage details = monstersOnDungeon[_user];
        uint256 amount = details.monstersAmount;
        for (uint256 i; i < amount; ++i) {
            uint256 monster = details.monsters[i];
            delete monster;
        }
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
