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

    struct Details {
        uint256 tokenId;
        uint256 missionStart;
        address owner;
    }
    mapping(address => uint256[]) public monstersOnBeginner;
    mapping(address => uint256[]) public monstersOnIntermediate;
    mapping(address => mapping(uint256 => Details))
        public monstersOnBeginnerDetails;
    mapping(address => mapping(uint256 => Details))
        public monstersOnIntermediateDetails;

    uint256 nonce;

    function setInterface(address monsterNFT, address itemNFT) public {
        monsterInterface = IERC721(monsterNFT);
        statsInterface = IMonster(monsterNFT);
        itemsInterface = IItems(itemNFT);
    }

    modifier isOnBeginner(address _user, uint256 _tokenId) {
        bool result;
        uint256[] memory monsters = monstersOnBeginner[_user];
        for (uint256 i; i < monsters.length; ++i) {
            uint256 monsterId = monsters[i];
            if (_tokenId == monsterId) {
                result = true;
            }
        }
        require(result, "Monster not found");
        _;
    }

    modifier isOnIntermediate(address _user, uint256 _tokenId) {
        bool result;
        uint256[] memory monsters = monstersOnIntermediate[_user];
        for (uint256 i; i < monsters.length; ++i) {
            uint256 monsterId = monsters[i];
            if (_tokenId == monsterId) {
                result = true;
            }
        }
        require(result, "Monster not found");
        _;
    }

    function claimBeginnerMission(uint256 _tokenId, address _user)
        external
        isOnBeginner(_user, _tokenId)
    {
        Details memory details = monstersOnBeginnerDetails[_user][_tokenId];
        uint256 missionStart = details.missionStart;
        uint256 hunger = statsInterface.getMonsterHunger(_tokenId);
        uint256 newHunger = hunger - 10;
        uint256 expEarned = 4;
        require(
            missionStart + 15 minutes <= block.timestamp,
            "Duration not over yet"
        );
        statsInterface.setCooldown(_tokenId);
        statsInterface.setHunger(_tokenId, newHunger);
        statsInterface.expUp(_tokenId, expEarned);

        itemsInterface.beginnerMissionReward(_user, randomNumber());
        statsInterface.setStatus(_tokenId, 0);
        deleteMonsterOnBeg(_tokenId, _user);
    }

    function claimIntermediateMission(uint256 _tokenId, address _user)
        external
        isOnIntermediate(_user, _tokenId)
    {
        Details memory details = monstersOnIntermediateDetails[_user][_tokenId];
        uint256 missionStart = details.missionStart;
        uint256 hunger = statsInterface.getMonsterHunger(_tokenId);
        uint256 newHunger = hunger - 10;
        uint256 expEarned = 8;
        require(
            missionStart + 30 minutes <= block.timestamp,
            "Duration not over yet"
        );
        statsInterface.setCooldown(_tokenId);
        statsInterface.setHunger(_tokenId, newHunger);
        statsInterface.expUp(_tokenId, expEarned);

        itemsInterface.intermediateMissionReward(_user, randomNumber());
        statsInterface.setStatus(_tokenId, 0);
        deleteMonsterOnInt(_user, _tokenId);
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

    function startBeginnerIfPassed(
        uint256 _monsterHunger,
        uint256 _monsterCooldown,
        uint256 _monsterStatus
    ) internal pure returns (bool result) {
        require(_monsterStatus == 0, "Your monster still working on something");
        require(_monsterCooldown == 0, " Your monster still on cooldown");
        require(_monsterHunger >= 5, "Not enough hunger");
        result = true;
    }

    function startIntermediateIfPassed(
        uint256 _monsterHunger,
        uint256 _monsterCooldown,
        uint256 _monsterStatus,
        uint256 _monsterLevel
    ) internal pure returns (bool result) {
        require(_monsterStatus == 0, "Your monster still working on something");
        require(
            _monsterLevel > 2,
            "Your monster does'nt met the minimum requirement"
        );
        require(_monsterCooldown == 0, " Your monster still on cooldown");
        require(_monsterHunger >= 10, "Not enough hunger");
        result = true;
    }

    function feedMonster(uint256 _tokenId, uint256 _amount) public payable {
        uint256 monsterLevel = statsInterface.getMonsterLevel(_tokenId);
        uint256 monsterHunger = statsInterface.getMonsterHunger(_tokenId);
        require(feedIfPassed(monsterLevel, monsterHunger, _amount));
        statsInterface.feedMonster(_tokenId, _amount);
    }

    function beginnerMission(uint256 _tokenId, address _user) external {
        uint256 monsterHunger = statsInterface.getMonsterHunger(_tokenId);
        uint256 monsterCooldown = statsInterface.getMonsterCooldown(_tokenId);
        uint256 monsterStatus = statsInterface.getMonsterStatus(_tokenId);
        require(
            monsterInterface.ownerOf(_tokenId) == _user,
            "It's not your monster"
        );
        require(
            startBeginnerIfPassed(monsterHunger, monsterCooldown, monsterStatus)
        );
        statsInterface.setStatus(_tokenId, 1);
        monstersOnBeginner[_user].push(_tokenId);
        monstersOnBeginnerDetails[_user][_tokenId] = Details(
            _tokenId,
            block.timestamp,
            _user
        );
    }

    function intermediateMission(uint256 _tokenId, address _user) external {
        uint256 monsterLevel = statsInterface.getMonsterLevel(_tokenId);
        uint256 monsterHunger = statsInterface.getMonsterHunger(_tokenId);
        uint256 monsterCooldown = statsInterface.getMonsterCooldown(_tokenId);
        uint256 monsterStatus = statsInterface.getMonsterStatus(_tokenId);
        require(
            monsterInterface.ownerOf(_tokenId) == _user,
            "It's not your monster"
        );
        require(
            startIntermediateIfPassed(
                monsterHunger,
                monsterCooldown,
                monsterStatus,
                monsterLevel
            )
        );
        statsInterface.setStatus(_tokenId, 1);
        monstersOnIntermediate[_user].push(_tokenId);
        monstersOnIntermediateDetails[_user][_tokenId] = Details(
            _tokenId,
            block.timestamp,
            _user
        );
    }

    function deleteMonsterOnBeg(uint256 _tokenId, address _user) internal {
        Details storage details = monstersOnBeginnerDetails[_user][_tokenId];
        delete details.tokenId;
        delete details.missionStart;
        delete details.owner;
    }

    function deleteMonsterOnInt(address _user, uint256 _tokenId) internal {
        Details storage details = monstersOnIntermediateDetails[_user][
            _tokenId
        ];
        delete details.tokenId;
        delete details.missionStart;
        delete details.owner;
    }

    function getMonstersOnBeginner(address _user)
        external
        view
        returns (Details[] memory)
    {
        uint256[] memory monsters = monstersOnBeginner[_user];
        Details[] memory myMonsters = new Details[](monsters.length);
        for (uint256 i; i < monsters.length; ++i) {
            uint256 monsterId = monsters[i];
            myMonsters[i] = monstersOnBeginnerDetails[_user][monsterId];
        }
        return myMonsters;
    }

    function getMonstersOnIntermediate(address _user)
        external
        view
        returns (Details[] memory)
    {
        uint256[] memory monsters = monstersOnIntermediate[_user];
        Details[] memory myMonsters = new Details[](monsters.length);
        for (uint256 i; i < monsters.length; ++i) {
            uint256 monsterId = monsters[i];
            myMonsters[i] = monstersOnIntermediateDetails[_user][monsterId];
        }
        return myMonsters;
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
