// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IMonster.sol";
import "./IUsersData.sol";

contract Nursery is Ownable {
    struct Details {
        address owner;
        uint8 monstersAmount;
        mapping(uint256 => uint8) monsters;
        uint32 duration;
        uint64 startTime;
    }

    IMonster public monstersInterface;
    IUsersData public usersDataInterface;
    uint256 public RESTING_FEE = 0.001 ether;

    mapping(address => Details) public monstersOnNursery;
    mapping(address => bool) public restingStatus;

    receive() external payable {}

    error FeeNotValid(uint256 _sent);
    error NotResting(bool _status);
    error IsResting(bool _status);
    error NotValidToRest(uint256 _monster, uint256 _duration, uint256 _status);
    error NotValidToFinishRest(uint256 _timeElapsed, uint256 _timeNow);
    error MonstersAmountNotValid(uint256 _amount, uint256 _limit);

    modifier isResting() {
        bool status = restingStatus[msg.sender];
        if (!status) {
            revert NotResting(status);
        }
        _;
    }

    modifier isNotResting() {
        bool status = restingStatus[msg.sender];
        if (status) {
            revert IsResting(status);
        }
        _;
    }

    modifier isRegistered() {
        usersDataInterface.checkRegister(msg.sender);
        _;
    }

    function setInterface(address _monsterContract, address _usersDataContract)
        external
        onlyOwner
    {
        monstersInterface = IMonster(_monsterContract);
        usersDataInterface = IUsersData(_usersDataContract);
    }

    function restMonsters(uint256[] calldata _monsters, uint256 _duration)
        external
        payable
        isRegistered
        isNotResting
    {
        if (_monsters.length > 6) {
            revert MonstersAmountNotValid(_monsters.length, 6);
        }
        Details storage details = monstersOnNursery[msg.sender];
        uint256 totalFee = _duration * RESTING_FEE * _monsters.length;
        if (msg.value != totalFee) {
            revert FeeNotValid(msg.value);
        }
        for (uint256 i; i < _monsters.length; ++i) {
            uint256 monster = _monsters[i];
            uint256 energy = monstersInterface.getMonsterEnergy(monster);
            uint256 status = monstersInterface.getMonsterStatus(monster);
            uint256 newEnergy = _duration * 10 + energy;
            address owner = monstersInterface.monsterOwner(monster);
            if (status != 0 || owner != msg.sender || newEnergy > 100) {
                revert NotValidToRest(monster, _duration, status);
            }
            monstersInterface.setStatus(monster, 2);
            details.monsters[i] = uint8(monster);
        }
        details.duration = uint32(_duration * 1 hours);
        details.monstersAmount = uint8(_monsters.length);
        details.owner = msg.sender;
        details.startTime = uint64(block.timestamp);
        restingStatus[msg.sender] = true;
    }

    function finishResting() external isResting {
        Details storage details = monstersOnNursery[msg.sender];
        uint256[] memory monsters = getRestingMonsters(msg.sender);
        uint256 startTime = details.startTime;
        uint256 duration = details.duration;
        uint256 timeElapsed = startTime + duration;
        if (timeElapsed > block.timestamp) {
            revert NotValidToFinishRest(timeElapsed, block.timestamp);
        }
        for (uint256 i; i < monsters.length; ++i) {
            uint256 monster = monsters[i];
            uint256 energy = monstersInterface.getMonsterEnergy(monster);
            uint256 newEnergy = ((duration / 1 hours) * 10) + energy;
            monstersInterface.setEnergy(monster, newEnergy);
            monstersInterface.setStatus(monster, 0);
        }
        deleteDetails(msg.sender);
        restingStatus[msg.sender] = false;
    }

    function getRestingMonsters(address _user)
        public
        view
        returns (uint256[] memory monsters)
    {
        Details storage details = monstersOnNursery[_user];
        uint256 amount = details.monstersAmount;
        monsters = new uint256[](amount);
        for (uint256 i; i < amount; ++i) {
            monsters[i] = details.monsters[i];
        }
    }

    function deleteDetails(address _user) internal {
        Details storage details = monstersOnNursery[_user];
        uint256[] memory monsters = getRestingMonsters(_user);
        for (uint256 i; i < monsters.length; ++i) {
            delete details.monsters[i];
        }
        delete details.owner;
        delete details.duration;
        delete details.startTime;
        delete details.monstersAmount;
    }
}
