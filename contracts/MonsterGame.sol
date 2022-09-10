// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./IMonster.sol";
import "./IItems.sol";

contract MonsterGame is IERC721Receiver {
    IERC721 public monsterInterface;
    IMonster public statsInterface;
    IItems public itemsInterface;

    struct UserDetails {
        uint256 mission;
        uint256[] monsters;
        uint256 startTime;
        address owner;
    }

    struct MissionDetails {
        uint256 hunger;
        uint256 exp;
    }

    uint256 nonce;
    uint256 BEGINNER_MISSION_ID = 1;
    uint256 INTERMEDIATE_MISSION_ID = 2;

    mapping(address => UserDetails) public monstersOnMissions;
    mapping(address => bool) public missioningStatus;
    mapping(uint256 => MissionDetails) public missionDetails;

    function setInterface(address monsterNFT, address itemNFT) public {
        monsterInterface = IERC721(monsterNFT);
        statsInterface = IMonster(monsterNFT);
        itemsInterface = IItems(itemNFT);
    }

    function addMissionUserDetails(
        uint256 _mission,
        uint256 _hunger,
        uint256 _exp
    ) external {
        missionDetails[_mission] = MissionDetails(_hunger, _exp);
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
            uint256 hunger = statsInterface.getMonsterHunger(monster);
            uint256 hungerUsed = missionDetails[_mission].hunger;
            uint256 newHunger = hunger - hungerUsed;
            uint256 expEarned = missionDetails[_mission].exp;
            statsInterface.setCooldown(monster);
            statsInterface.setHunger(monster, newHunger);
            statsInterface.expUp(monster, expEarned);
            statsInterface.setStatus(monster, 0);
            itemsInterface.missionsReward(
                _mission,
                monster,
                _user,
                randomNumber()
            );
        }
        deleteUserDetails(_user);
    }

    function feedIfPassed(
        uint256 _monsterLevel,
        uint256 _monsterHunger,
        uint256 _amount
    ) internal view returns (bool result) {
        uint256 feedingFee = 0.0001 ether;
        require(
            msg.value == feedingFee * _monsterLevel * _amount,
            "Not enough ether"
        );
        require(_monsterHunger < 100, "Your monster hunger is full");
        require(
            _amount + _monsterHunger <= 100,
            "Too much food for your monster"
        );
        result = true;
    }

    function monsterCheck(
        uint256 _mission,
        uint256 _monsterHunger,
        uint256 _monsterCooldown,
        uint256 _monsterStatus
    ) internal view returns (bool result) {
        uint256 hungerUsed = missionDetails[_mission].hunger;
        require(_monsterStatus == 0, "Your monster still working on something");
        require(
            _monsterCooldown <= block.timestamp,
            " Your monster still on cooldown"
        );
        require(_monsterHunger >= hungerUsed, "Not enough hunger");
        result = true;
    }

    function feedMonster(uint256 _tokenId, uint256 _amount) public payable {
        uint256 monsterLevel = statsInterface.getMonsterLevel(_tokenId);
        uint256 monsterHunger = statsInterface.getMonsterHunger(_tokenId);
        require(feedIfPassed(monsterLevel, monsterHunger, _amount));
        statsInterface.feedMonster(_tokenId, _amount);
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
            uint256 level = statsInterface.getMonsterLevel(monster);
            uint256 hunger = statsInterface.getMonsterHunger(monster);
            uint256 cooldown = statsInterface.getMonsterCooldown(monster);
            uint256 status = statsInterface.getMonsterStatus(monster);
            address owner = monsterInterface.ownerOf(monster);
            bool passed = monsterCheck(_mission, hunger, cooldown, status);
            if (isIntermediate) {
                require(level > 2, "Monster level not enough");
            }
            require(owner == _user, "It's not your monster");
            require(passed, "Monster not passed");
            statsInterface.setStatus(monster, 1);
        }
        monstersOnMissions[_user] = UserDetails(
            _mission,
            _monsters,
            block.timestamp,
            _user
        );
    }

    function deleteUserDetails(address _user) internal {
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
