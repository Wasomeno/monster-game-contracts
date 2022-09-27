// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "./IMonster.sol";
import "./IItems.sol";
import "./IUsersData.sol";

contract MonsterGame is ERC1155Holder {
    IMonster public monstersInterface;
    IItems public itemsInterface;
    IUsersData public usersDataInterface;
    IERC1155 public erc1155Interface;

    struct UserDetails {
        uint256 mission;
        uint256 monstersAmount;
        mapping(uint256 => uint256) monsters;
        uint256 startTime;
        address owner;
    }

    struct MissionDetails {
        uint256 energy;
        uint256 exp;
    }

    uint256 internal nonce;
    uint256 constant BEGINNER_MISSION_ID = 1;
    uint256 constant INTERMEDIATE_MISSION_ID = 2;
    uint256 constant FEEDING_FEE = 0.0001 ether;

    mapping(address => UserDetails) public monstersOnMissions;
    mapping(address => bool) public missioningStatus;
    mapping(uint256 => MissionDetails) public missionDetails;

    constructor() {
        missionDetails[1] = MissionDetails(10, 5);
        missionDetails[2] = MissionDetails(20, 10);
    }

    receive() external payable {}

    error NotRegistered(address _user, bool _result);
    error NotOnMission(address _user, bool _result);
    error IsOnMission(address _user, bool _result);
    error IsActive(uint256 _monster, uint256 _status);
    error NotValidToFeed(uint256 _monster, uint256 _energy, uint256 _amount);
    error NotValidToIntermediate(uint256 _monster, uint256 _level);
    error NotValidToMission(uint256 _monster, uint256 _energy, uint256 _status);
    error NotValidToFinishMission(uint256 _elapsedTime);
    error NotValidToUsePotion();

    modifier isOnMission(address _user) {
        bool status = missioningStatus[_user];
        if (!status) {
            revert NotOnMission(_user, status);
        }
        _;
    }

    modifier isNotOnMission(address _user) {
        bool status = missioningStatus[_user];
        if (status) {
            revert IsOnMission(_user, status);
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

    modifier isValid(address _user) {
        bool result = usersDataInterface.checkRegister(_user);
        if (!result) {
            revert NotRegistered(_user, result);
        }
        _;
    }

    modifier isValidToFeed(uint256 _monster, uint256 _amount) {
        uint256 monsterLevel = monstersInterface.getMonsterLevel(_monster);
        uint256 total = _amount * FEEDING_FEE * monsterLevel;
        uint256 monsterEnergy = monstersInterface.getMonsterEnergy(_monster);
        if (
            msg.value != total ||
            monsterEnergy > 100 ||
            _amount + monsterEnergy > 100 ||
            _amount == 0
        ) {
            revert NotValidToFeed(_monster, monsterEnergy, _amount);
        }
        _;
    }

    function addMissionDetails(
        uint256 _mission,
        uint256 _energy,
        uint256 _exp
    ) external {
        missionDetails[_mission] = MissionDetails(_energy, _exp);
    }

    function startMission(uint256 _mission, uint256[] calldata _monsters)
        external
        isNotOnMission(msg.sender)
        isValid(msg.sender)
    {
        require(_monsters.length <= 6, "Above limit");
        UserDetails storage details = monstersOnMissions[msg.sender];
        for (uint256 i; i < _monsters.length; ++i) {
            uint256 monster = _monsters[i];
            monsterCheck(msg.sender, _mission, monster);
            monstersInterface.setStatus(monster, 1);
            details.monsters[i] = monster;
        }
        details.mission = _mission;
        details.startTime = block.timestamp;
        details.owner = msg.sender;
        details.monstersAmount = _monsters.length;
        missioningStatus[msg.sender] = true;
    }

    function finishMission() external isOnMission(msg.sender) {
        UserDetails storage details = monstersOnMissions[msg.sender];
        uint256 mission = details.mission;
        MissionDetails memory detailsMission = missionDetails[mission];
        uint256[] memory monsters = getMonstersOnMission(msg.sender);
        uint256 startTime = details.startTime;
        uint256 elapsedTime = startTime + 15 minutes;
        if (elapsedTime > block.timestamp) {
            revert NotValidToFinishMission(elapsedTime);
        }
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
        isValid(msg.sender)
        isValidToFeed(_monster, _amount)
    {
        uint256 monsterEnergy = monstersInterface.getMonsterEnergy(_monster);
        uint256 newMonsterEnergy = monsterEnergy + _amount;
        monstersInterface.setEnergy(_monster, newMonsterEnergy);
    }

    function useEnergyPotion(uint256 _monster, uint256 _amount)
        external
        isNotActive(_monster)
        isValid(msg.sender)
    {
        uint256 balance = erc1155Interface.balanceOf(msg.sender, 2);
        uint256 energy = monstersInterface.getMonsterEnergy(_monster);
        uint256 energyGained = _amount * 10;
        uint256 newEnergy = energy + energyGained;
        if (balance < _amount || newEnergy > 100) {
            revert NotValidToUsePotion();
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
        isValid(msg.sender)
    {
        uint256 balance = erc1155Interface.balanceOf(msg.sender, 3);
        uint256 expEarned = _amount * 3;
        if (balance < _amount) {
            revert NotValidToUsePotion();
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

    function setInterface(
        address monstersContract,
        address itemsContract,
        address usersDataContract
    ) public {
        monstersInterface = IMonster(monstersContract);
        itemsInterface = IItems(itemsContract);
        erc1155Interface = IERC1155(itemsContract);
        usersDataInterface = IUsersData(usersDataContract);
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
        address owner = monstersInterface.ownerOf(_monster);
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
        delete details.mission;
        delete details.owner;
        delete details.startTime;
        delete details.monstersAmount;
        deleteMonsters(_user);
    }

    function deleteMonsters(address _user) internal {
        UserDetails storage details = monstersOnMissions[_user];
        uint256 amount = details.monstersAmount;
        for (uint256 i; i < amount; ++i) {
            delete details.monsters[i];
        }
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
