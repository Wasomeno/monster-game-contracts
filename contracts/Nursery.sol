// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./IMonster.sol";

contract Nursery {
    struct Rest {
        uint256 monster;
        address owner;
        uint256 duration;
        uint256 startTime;
    }

    struct Item {
        uint256 item;
        uint256 quantity;
        uint256 price;
    }

    IMonster monsterInterface;

    mapping(address => uint256[]) public ownerToMonsters;
    mapping(address => mapping(uint256 => Rest)) public monstersOnNursery;
    mapping(address => bool) public isResting;

    function setInterface(address _monsterNFT, address _itemNFT) public {
        monsterInterface = IMonster(_monsterNFT);
    }

    modifier isRestingMonsters(address _user) {
        bool status = isResting[_user];
        require(status, "You're not resting any monsters");
        _;
    }

    function restMonster(
        uint256[] calldata _monsters,
        address _user,
        uint256 _duration
    ) external payable {
        require(_monsters.length <= 6, "Exceed Limit");
        for (uint256 i; i < _monsters.length; ++i) {
            uint256 monster = _monsters[i];
            uint256 energy = monsterInterface.getMonsterEnergy(monster);
            uint256 status = monsterInterface.getMonsterStatus(monster);
            require(status == 0, "Your monster still working on something");
            require(_duration * 10 + energy <= 100, "Reduce the duration");
            require(msg.value >= _duration * 0.0001 ether, "Wrong value sent");
            monsterInterface.setStatus(monster, 2);
            monstersOnNursery[_user][monster] = Rest(
                monster,
                _user,
                _duration,
                block.timestamp
            );
        }
        ownerToMonsters[_user] = _monsters;
    }

    function finishResting(address _user) external isRestingMonsters(_user) {
        uint256[] memory monsters = ownerToMonsters[_user];
        for (uint256 i; i < monsters.length; ++i) {
            uint256 monster = monsters[i];
            Rest memory monsterDetails = monstersOnNursery[_user][monster];
            uint256 startTime = monsterDetails.startTime;
            uint256 energy = monsterInterface.getMonsterEnergy(monster);
            uint256 duration = monsterDetails.duration;
            uint256 newEnergy = duration * 10;
            uint256 timeElapsed = startTime + duration;
            require(
                timeElapsed <= block.timestamp,
                "Your monster still resting"
            );
            monsterInterface.feedMonster(monster, newEnergy);
            monsterInterface.setStatus(monster, 0);
        }
        deleteMonster(_user);
    }

    function deleteMonster(address _user) internal {
        uint256[] memory monsters = ownerToMonsters[_user];
        for (uint256 i; i < monsters.length; ++i) {
            uint256 monster = monsters[i];
            Rest memory monsterDetails = monstersOnNursery[_user][monster];
            delete monsterDetails.monster;
            delete monsterDetails.owner;
            delete monsterDetails.duration;
            delete monsterDetails.startTime;
        }
        delete monsters;
    }

    receive() external payable {}
}
