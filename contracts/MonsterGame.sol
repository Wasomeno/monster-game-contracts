// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IMonster.sol";
import "./IItems.sol";
import "./IUsersData.sol";

contract MonsterGame is ERC1155Holder, Ownable {
    struct UserDetails {
        uint8 mission;
        uint8 monstersAmount;
        mapping(uint256 => uint8) monsters;
        uint64 startTime;
        address owner;
    }

    struct MissionDetails {
        uint8 energy;
        uint8 exp;
    }

    IMonster public monstersInterface;
    IItems public itemsInterface;
    IUsersData public usersDataInterface;
    IERC1155 public erc1155Interface;

    uint8 internal constant BEGINNER_MISSION_ID = 1;
    uint8 internal constant INTERMEDIATE_MISSION_ID = 2;
    uint16 internal nonce;
    uint48 public constant FEEDING_FEE = 0.0001 ether;

    mapping(address => UserDetails) public monstersOnMissions;
    mapping(address => bool) public missioningStatus;
    mapping(uint256 => MissionDetails) public missionDetails;

    constructor() {
        missionDetails[1] = MissionDetails(10, 5);
        missionDetails[2] = MissionDetails(20, 10);
    }

    receive() external payable {}

    error NotRegistered(bool _result);
    error NotOnMission(bool _result);
    error IsOnMission(bool _result);
    error IsActive(uint256 _monster, uint256 _status);
    error NotValidToFeed(uint256 _monster, uint256 _energy, uint256 _amount);
    error NotValidToIntermediate(uint256 _monster, uint256 _level);
    error NotValidToMission(uint256 _monster, uint256 _energy, uint256 _status);
    error NotValidToFinishMission(uint256 _elapsedTime);
    error NotValidToUsePotion(uint256 _balance, uint256 _amount);
    error MonstersAmountNotValid(uint256 _amount, uint256 _limit);

    modifier isOnMission() {
        bool status = missioningStatus[msg.sender];
        if (!status) {
            revert NotOnMission(status);
        }
        _;
    }

    modifier isNotOnMission() {
        bool status = missioningStatus[msg.sender];
        if (status) {
            revert IsOnMission(status);
        }
        _;
    }

    modifier isNotActive(uint256 _monster) {
        uint256 status = monstersInterface.getMonsterStatus(_monster);
        if (status != 0) {
            revert IsActive(_monster, status);
        }
        _;
    }

    modifier isRegistered() {
        usersDataInterface.checkRegister(msg.sender);
        _;
    }

    modifier isValidToFeed(uint256 _monster, uint256 _amount) {
        uint256 monsterLevel = monstersInterface.getMonsterLevel(_monster);
        uint256 total = _amount * FEEDING_FEE * monsterLevel;
        uint256 monsterEnergy = monstersInterface.getMonsterEnergy(_monster);
        address owner = monstersInterface.monsterOwner(_monster);
        if (
            msg.value != total ||
            monsterEnergy > 100 ||
            _amount == 0 ||
            _amount + monsterEnergy > 100 ||
            owner != msg.sender
        ) {
            revert NotValidToFeed(_monster, monsterEnergy, _amount);
        }
        _;
    }

    function setInterface(
        address _monstersContract,
        address _itemsContract,
        address _usersDataContract
    ) external onlyOwner {
        monstersInterface = IMonster(_monstersContract);
        itemsInterface = IItems(_itemsContract);
        erc1155Interface = IERC1155(_itemsContract);
        usersDataInterface = IUsersData(_usersDataContract);
    }

    function addMissionDetails(
        uint256 _mission,
        uint256 _energy,
        uint256 _exp
    ) external {
        missionDetails[_mission] = MissionDetails(uint8(_energy), uint8(_exp));
    }

    function startMission(uint256 _mission, uint256[] calldata _monsters)
        external
        isNotOnMission
        isRegistered
    {
        if (_monsters.length > 6) {
            revert MonstersAmountNotValid(_monsters.length, 6);
        }
        UserDetails storage details = monstersOnMissions[msg.sender];
        for (uint256 i; i < _monsters.length; ++i) {
            uint256 monster = _monsters[i];
            monsterCheck(msg.sender, _mission, monster);
            monstersInterface.setStatus(monster, 1);
            details.monsters[i] = uint8(monster);
        }
        details.mission = uint8(_mission);
        details.startTime = uint64(block.timestamp);
        details.owner = msg.sender;
        details.monstersAmount = uint8(_monsters.length);
        missioningStatus[msg.sender] = true;
    }

    function finishMission() external isOnMission {
        UserDetails storage details = monstersOnMissions[msg.sender];
        uint256 mission = details.mission;
        MissionDetails memory detailsMission = missionDetails[mission];
        uint256[] memory monsters = getMonstersOnMission(msg.sender);
        uint256 startTime = details.startTime;
        uint256 elapsedTime = startTime + 15 minutes;
        // if (elapsedTime > block.timestamp) {
        //     revert NotValidToFinishMission(elapsedTime);
        // }
        for (uint256 i; i < monsters.length; ++i) {
            uint256 monster = monsters[i];
            uint256 energy = monstersInterface.getMonsterEnergy(monster);
            uint256 newEnergy = energy - detailsMission.energy;
            monstersInterface.setEnergy(monster, newEnergy);
            monstersInterface.setCooldown(monster);
            monstersInterface.expUp(monster, detailsMission.exp);
            monstersInterface.setStatus(monster, 0);
            itemsInterface.missionsReward(
                mission,
                monster,
                msg.sender,
                randomNumber()
            );
        }
        deleteDetails(msg.sender);
        missioningStatus[msg.sender] = false;
    }

    function feedMonster(uint256 _monster, uint256 _amount)
        external
        payable
        isRegistered
        isValidToFeed(_monster, _amount)
    {
        uint256 monsterEnergy = monstersInterface.getMonsterEnergy(_monster);
        uint256 newMonsterEnergy = monsterEnergy + _amount;
        monstersInterface.setEnergy(_monster, newMonsterEnergy);
    }

    function useEnergyPotion(uint256 _monster, uint256 _amount)
        external
        isNotActive(_monster)
        isRegistered
    {
        address owner = monstersInterface.monsterOwner(_monster);
        uint256 balance = erc1155Interface.balanceOf(msg.sender, 2);
        uint256 energy = monstersInterface.getMonsterEnergy(_monster);
        uint256 energyGained = _amount * 10;
        uint256 newEnergy = energy + energyGained;
        if (balance < _amount || newEnergy > 100 || owner != msg.sender) {
            revert NotValidToUsePotion(balance, _amount);
        }
        erc1155Interface.safeTransferFrom(
            msg.sender,
            address(this),
            2,
            _amount,
            ""
        );
        monstersInterface.setEnergy(_monster, newEnergy);
    }

    function useExpPotion(uint256 _monster, uint256 _amount)
        external
        isNotActive(_monster)
        isRegistered
    {
        address owner = monstersInterface.monsterOwner(_monster);
        uint256 balance = erc1155Interface.balanceOf(msg.sender, 3);
        uint256 expEarned = _amount * 3;
        if (balance < _amount || owner != msg.sender) {
            revert NotValidToUsePotion(balance, _amount);
        }
        erc1155Interface.safeTransferFrom(
            msg.sender,
            address(this),
            3,
            _amount,
            ""
        );
        monstersInterface.expUp(_monster, expEarned);
    }

    function getMonstersOnMission(address _user)
        public
        view
        returns (uint256[] memory _monsters)
    {
        UserDetails storage details = monstersOnMissions[_user];
        uint256 amount = details.monstersAmount;
        _monsters = new uint256[](amount);
        for (uint256 i; i < amount; ++i) {
            uint256 monster = details.monsters[i];
            _monsters[i] = monster;
        }
    }

    function monsterCheck(
        address _user,
        uint256 _mission,
        uint256 _monster
    ) internal view returns (bool result) {
        bool isIntermediate = _mission != BEGINNER_MISSION_ID;
        uint256 energyUsed = missionDetails[_mission].energy;
        uint256 level = monstersInterface.getMonsterLevel(_monster);
        uint256 energy = monstersInterface.getMonsterEnergy(_monster);
        uint256 cooldown = monstersInterface.getMonsterCooldown(_monster);
        uint256 status = monstersInterface.getMonsterStatus(_monster);
        address owner = monstersInterface.monsterOwner(_monster);
        if (isIntermediate && level < 2) {
            revert NotValidToIntermediate(_monster, level);
        } else if (
            owner != _user ||
            status != 0 ||
            cooldown > block.timestamp ||
            energy < energyUsed
        ) {
            revert NotValidToMission(_monster, energy, status);
        }
        result = true;
    }

    function deleteDetails(address _user) internal {
        UserDetails storage details = monstersOnMissions[_user];
        uint256[] memory monsters = getMonstersOnMission(_user);
        for (uint256 i; i < monsters.length; ++i) {
            delete details.monsters[i];
        }
        delete details.mission;
        delete details.owner;
        delete details.startTime;
        delete details.monstersAmount;
    }

    function randomNumber() internal returns (uint256 number) {
        number =
            uint256(
                keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))
            ) %
            100;
        nonce++;
    }
}
