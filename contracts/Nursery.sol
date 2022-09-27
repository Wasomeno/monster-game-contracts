// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./IMonster.sol";

contract Nursery {
    struct Details {
        address owner;
        uint256 monstersAmount;
        mapping(uint256 => uint256) monsters;
        uint256 duration;
        uint256 startTime;
    }

    IMonster monsterInterface;
    uint256 public RESTING_FEE = 0.001 ether;

    mapping(address => Details) public monstersOnNursery;
    mapping(address => bool) public restingStatus;

    receive() external payable {}

    error FeeNotValid(uint256 _sent);
    error NotValidToRest(uint256 _monster, uint256 _duration, uint256 _status);
    error NotValidToFinishRest(uint256 _timeElapsed, uint256 _timeNow);

    modifier isRestingMonsters(address _user) {
        bool status = restingStatus[_user];
        require(status, "You're not resting any monsters");
        _;
    }

    function restMonsters(
        uint256[] calldata _monsters,
        address _user,
        uint256 _duration
    ) external payable {
        require(_monsters.length <= 6, "Above Limit");
        Details storage details = monstersOnNursery[_user];
        uint256 totalFee = _duration * RESTING_FEE * _monsters.length;
        if (msg.value != totalFee) {
            revert FeeNotValid(msg.value);
        }
        for (uint256 i; i < _monsters.length; ++i) {
            uint256 monster = _monsters[i];
            uint256 energy = monsterInterface.getMonsterEnergy(monster);
            uint256 status = monsterInterface.getMonsterStatus(monster);
            uint256 newEnergy = _duration * 10 + energy;
            if (status != 0 || newEnergy > 100) {
                revert NotValidToRest(monster, _duration, status);
            }
            monsterInterface.setStatus(monster, 2);
            details.monsters[i] = monster;
        }
        details.duration = _duration;
        details.monstersAmount = _monsters.length;
        details.owner = _user;
        details.startTime = block.timestamp;
        restingStatus[_user] = true;
    }

    function finishResting(address _user) external isRestingMonsters(_user) {
        Details storage details = monstersOnNursery[_user];
        uint256[] memory monsters = getRestingMonsters(_user);
        uint256 startTime = details.startTime;
        uint256 duration = details.duration;
        uint256 timeElapsed = startTime + duration;
        if (timeElapsed > block.timestamp) {
            revert NotValidToFinishRest(timeElapsed, block.timestamp);
        }
        for (uint256 i; i < monsters.length; ++i) {
            uint256 monster = monsters[i];
            uint256 energy = monsterInterface.getMonsterEnergy(monster);
            uint256 newEnergy = (duration * 10) + energy;
            monsterInterface.setEnergy(monster, newEnergy);
            monsterInterface.setStatus(monster, 0);
        }
        deleteDetails(_user);
        (_user);
        restingStatus[_user] = false;
    }

    function setInterface(address _monsterNFT) public {
        monsterInterface = IMonster(_monsterNFT);
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
