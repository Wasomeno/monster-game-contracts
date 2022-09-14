// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./IMonster.sol";
import "./IItems.sol";
import "./IUsersData.sol";

contract MonsterGame is IERC721Receiver {
    IMonster public monstersInterface;
    IItems public itemsInterface;
    IUsersData public usersDataInterface;
    IERC1155 public erc1155Interface;

    struct UserDetails {
        uint256 mission;
        uint256[] monsters;
        uint256 startTime;
        address owner;
    }

    struct MissionDetails {
        uint256 energy;
        uint256 exp;
    }

    uint256 nonce;
    uint256 BEGINNER_MISSION_ID = 1;
    uint256 INTERMEDIATE_MISSION_ID = 2;

    mapping(address => UserDetails) public monstersOnMissions;
    mapping(address => bool) public missioningStatus;
    mapping(uint256 => MissionDetails) public missionDetails;

    function setInterface(
        address monsterNFT,
        address itemNFT,
        address usersData
    ) public {
        monstersInterface = IMonster(monsterNFT);
        itemsInterface = IItems(itemNFT);
        erc1155Interface = IERC1155(itemNFT);
        usersDataInterface = IUsersData(usersData);
    }

    function addMissionDetails(
        uint256 _mission,
        uint256 _energy,
        uint256 _exp
    ) external {
        missionDetails[_mission] = MissionDetails(_energy, _exp);
    }

    modifier isOnMission(address _user) {
        bool status = missioningStatus[_user];
        require(status, "You're not on a mission");
        _;
    }

    modifier isNotOnMission(address _user) {
        bool status = missioningStatus[_user];
        require(!status, "You're on a mission");
        _;
    }

    modifier isNotActive(uint256 _monster) {
        uint256 status = monstersInterface.getMonsterStatus(_monster);
        require(status == 0, "Your monster is active");
        _;
    }

    modifier isValid(address _user) {
        bool result = usersDataInterface.checkRegister(_user);
        require(_user == msg.sender, "User not valid");
        require(result, "You are not registered");
        _;
    }

    function finishMission(uint256 _mission, address _user)
        external
        isOnMission(_user)
    {
        UserDetails memory details = monstersOnMissions[_user];
        require(_mission == details.mission, "You are not doing this mission");
        uint256[] memory monsters = details.monsters;
        uint256 elapsedTime = details.startTime + 30 minutes;
        require(elapsedTime <= block.timestamp, "Mission is not over");
        for (uint256 i; i < monsters.length; ++i) {
            uint256 monster = monsters[i];
            uint256 energy = monstersInterface.getMonsterEnergy(monster);
            uint256 energyUsed = missionDetails[_mission].energy;
            uint256 newEnergy = energy - energyUsed;
            uint256 expEarned = missionDetails[_mission].exp;
            monstersInterface.setCooldown(monster);
            monstersInterface.setEnergy(monster, newEnergy);
            monstersInterface.expUp(monster, expEarned);
            monstersInterface.setStatus(monster, 0);
            itemsInterface.missionsReward(
                _mission,
                monster,
                _user,
                randomNumber()
            );
        }
        deleteMonstersDetails(_user);
    }

    function feedIfPassed(
        uint256 _monsterLevel,
        uint256 _monsterEnergy,
        uint256 _amount
    ) internal view returns (bool result) {
        uint256 feedingFee = 0.0001 ether;
        require(
            msg.value == feedingFee * _monsterLevel * _amount,
            "Not enough ether"
        );
        require(_monsterEnergy < 100, "Your monster energy is full");
        require(
            _amount + _monsterEnergy <= 100,
            "Too much food for your monster"
        );
        result = true;
    }

    function monsterCheck(
        uint256 _mission,
        uint256 _monsterEnergy,
        uint256 _monsterCooldown,
        uint256 _monsterStatus
    ) internal view returns (bool result) {
        uint256 energyUsed = missionDetails[_mission].energy;
        require(_monsterStatus == 0, "Your monster still working on something");
        require(
            _monsterCooldown <= block.timestamp,
            " Your monster still on cooldown"
        );
        require(_monsterEnergy >= energyUsed, "Not enough energy");
        result = true;
    }

    function feedMonster(
        address _user,
        uint256 _monster,
        uint256 _amount
    ) external payable isValid(_user) {
        uint256 monsterLevel = monstersInterface.getMonsterLevel(_monster);
        uint256 monsterEnergy = monstersInterface.getMonsterEnergy(_monster);
        require(feedIfPassed(monsterLevel, monsterEnergy, _monster));
        monstersInterface.feedMonster(_monster, _amount);
    }

    function startMission(
        uint256 _mission,
        uint256[] calldata _monsters,
        address _user
    ) external isNotOnMission(_user) {
        require(_monsters.length <= 6, "Exceed limit");
        bool isIntermediate = _mission == INTERMEDIATE_MISSION_ID;
        for (uint256 i; i < _monsters.length; ++i) {
            uint256 monster = _monsters[i];
            uint256 level = monstersInterface.getMonsterLevel(monster);
            uint256 energy = monstersInterface.getMonsterEnergy(monster);
            uint256 cooldown = monstersInterface.getMonsterCooldown(monster);
            uint256 status = monstersInterface.getMonsterStatus(monster);
            address owner = monstersInterface.ownerOf(monster);
            bool passed = monsterCheck(_mission, energy, cooldown, status);
            if (isIntermediate) {
                require(level > 2, "Monster level not enough");
            }
            require(owner == _user, "It's not your monster");
            require(passed, "Monster not passed");
            monstersInterface.setStatus(monster, 1);
        }
        monstersOnMissions[_user] = UserDetails(
            _mission,
            _monsters,
            block.timestamp,
            _user
        );
    }

    function useEnergyPotion(
        address _user,
        uint256 _monster,
        uint256 _amount
    ) external isNotActive(_monster) isValid(_user) {
        require(_user == msg.sender, "User not valid");
        uint256 balance = erc1155Interface.balanceOf(_user, 2);
        uint256 energy = monstersInterface.getMonsterEnergy(_monster);
        uint256 energyGained = _amount * 10;
        uint256 newEnergy = energy + energyGained;
        require(balance >= _amount, "Not enough items");
        require(newEnergy <= 100, "Too much energy");
        erc1155Interface.safeTransferFrom(_user, address(this), 2, _amount, "");
        monstersInterface.setEnergy(_monster, newEnergy);
    }

    function useExpPotion(
        address _user,
        uint256 _monster,
        uint256 _amount
    ) external isNotActive(_monster) isValid(_user) {
        require(_user == msg.sender, "User not valid");
        uint256 balance = erc1155Interface.balanceOf(_user, 3);
        uint256 exp = monstersInterface.getMonsterExp(_monster);
        uint256 expEarned = _amount * 3;
        require(balance >= _amount, "Not enough items");
        erc1155Interface.safeTransferFrom(_user, address(this), 3, _amount, "");
        monstersInterface.expUp(_monster, expEarned);
    }

    function deleteMonstersDetails(address _user) internal {
        UserDetails memory details = monstersOnMissions[_user];
        delete details;
    }

    function getMonstersOnMission(address _user)
        external
        view
        returns (uint256[] memory _monsters)
    {
        _monsters = monstersOnMissions[_user].monsters;
    }

    function randomNumber() internal returns (uint256 number) {
        number =
            uint256(
                keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))
            ) %
            100;
        nonce++;
    }

    function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}
