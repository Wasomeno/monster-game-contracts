// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./IMonster.sol";
import "./IItems.sol";

contract MonsterGame is IERC721Receiver {
    IERC721 public monsterInterface;
    IMonster public statsInterface;
    IItems public itemsInterface;

    struct Inventory {
        uint256 itemId;
        uint256 quantity;
    }

    struct Monster {
        uint256 tokenId;
        uint256 missionStart;
        address owner;
    }

    mapping(address => Inventory[]) public playerInventory;
    mapping(address => Monster[]) public myMonsterOnBeg;
    mapping(address => Monster[]) public myMonsterOnInt;

    uint256 nonce;

    function setInterface(address monsterNFT, address itemNFT) public {
        monsterInterface = IERC721(monsterNFT);
        statsInterface = IMonster(monsterNFT);
        itemsInterface = IItems(itemNFT);
    }

    function claimBeginnerMission(uint256 _tokenId, address _user) public {
        Monster[] memory monster = myMonsterOnBeg[_user];
        uint256 index = getMonsterIndexBeg(_tokenId, _user);
        uint256 missionStart = monster[index].missionStart;
        uint256 hunger = statsInterface.getMonsterHunger(_tokenId);
        uint256 newHunger = hunger - 10;
        uint256 expEarned = 4;
        require(
            missionStart + 15 minutes <= block.timestamp,
            "Duration not over yet"
        );
        require(
            checkOnBeg(_tokenId, _user),
            "Your monster is not on beginner mission"
        );
        statsInterface.setCooldown(_tokenId);
        statsInterface.setHunger(_tokenId, newHunger);
        statsInterface.expUp(_tokenId, expEarned);

        itemsInterface.beginnerMissionReward(_user, randomNumber());
        statsInterface.setStatus(_tokenId, 0);
        deleteMonsterOnBeg(_tokenId, _user);
    }

    function claimIntermediateMission(uint256 _tokenId, address _user) public {
        Monster[] memory monster = myMonsterOnInt[_user];
        uint256 index = getMonsterIndexInt(_tokenId, _user);
        uint256 missionStart = monster[index].missionStart;
        uint256 hunger = statsInterface.getMonsterHunger(_tokenId);
        uint256 newHunger = hunger - 10;
        uint256 expEarned = 8;
        // require(missionStart + 30 minutes <= block.timestamp, "Duration not over yet");
        require(
            checkOnInt(_tokenId, _user),
            "Your monster is not on intermediate mission"
        );
        statsInterface.setCooldown(_tokenId);
        statsInterface.setHunger(_tokenId, newHunger);
        statsInterface.expUp(_tokenId, expEarned);

        itemsInterface.intermediateMissionReward(_user, randomNumber());
        statsInterface.setStatus(_tokenId, 0);
        deleteMonsterOnInt(_tokenId);
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

    function beginnerMission(uint256 _tokenId, address _user) public {
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
        myMonsterOnBeg[_user].push(Monster(_tokenId, block.timestamp, _user));
    }

    function intermediateMission(uint256 _tokenId, address _user) public {
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
        myMonsterOnInt[_user].push(Monster(_tokenId, block.timestamp, _user));
    }

    function checkItemOnInventory(
        uint256[] memory _item,
        uint256[] memory _quantity,
        address _user
    ) external {
        Inventory[] storage inventoryStr = playerInventory[_user];
        uint256 length = inventoryStr.length;
        for (uint256 i; i < length; ++i) {
            Inventory[] memory inventoryMem = playerInventory[_user];
            if (inventoryMem[i].itemId == _item[i]) {
                uint256 quantity = inventoryMem[i].quantity;
                inventoryStr[i].quantity = quantity + _quantity[i];
            }
        }
        itemToInventory(_item, _quantity, _user);
    }

    function itemToInventory(
        uint256[] memory _item,
        uint256[] memory _quantity,
        address _user
    ) internal {
        Inventory[] storage inventory = playerInventory[_user];
        for (uint256 i; i < _item.length; ++i) {
            inventory.push(Inventory(_item[i], _quantity[i]));
        }
    }

    function checkSingleItemOnInventory(
        uint256 _item,
        uint256 _quantity,
        address _user
    ) external {
        Inventory[] storage inventoryStr = playerInventory[_user];
        uint256 length = inventoryStr.length;
        for (uint256 i; i < length; ++i) {
            Inventory[] memory inventoryMem = playerInventory[_user];
            if (inventoryMem[i].itemId == _item) {
                uint256 quantity = inventoryMem[i].quantity;
                inventoryStr[i].quantity = quantity + _quantity;
            }
        }
        singleItemToInventory(_item, _quantity, _user);
    }

    function singleItemToInventory(
        uint256 _item,
        uint256 _quantity,
        address _user
    ) internal {
        Inventory[] storage inventory = playerInventory[_user];
        inventory.push(Inventory(_item, _quantity));
    }

    function deleteMonsterOnBeg(uint256 _tokenId, address _user) internal {
        uint256 index;
        Monster[] storage myMonsterStr = myMonsterOnBeg[_user];
        Monster[] memory myMonsterMem = myMonsterOnBeg[_user];
        uint256 length = myMonsterMem.length;
        for (uint256 i; i < length; ++i) {
            if (myMonsterMem[i].tokenId == _tokenId) {
                index = i;
            }
        }
        myMonsterStr[index] = myMonsterMem[length - 1];
        myMonsterStr.pop();
    }

    function deleteMonsterOnInt(uint256 _tokenId) internal {
        uint256 index;
        Monster[] storage myMonsterStr = myMonsterOnInt[msg.sender];
        Monster[] memory myMonsterMem = myMonsterOnInt[msg.sender];
        uint256 length = myMonsterMem.length;
        for (uint256 i; i < length; ++i) {
            uint256 tokenId = myMonsterMem[i].tokenId;
            if (tokenId == _tokenId) {
                index = i;
            }
        }
        myMonsterStr[index] = myMonsterMem[length - 1];
        myMonsterStr.pop();
    }

    function checkOnBeg(uint256 _tokenId, address _user)
        internal
        view
        returns (bool result)
    {
        Monster[] memory myMonster = myMonsterOnBeg[_user];
        uint256 length = myMonster.length;
        for (uint256 i; i < length; ++i) {
            uint256 tokenId = myMonster[i].tokenId;
            if (tokenId == _tokenId) {
                result = true;
            }
        }
    }

    function checkOnInt(uint256 _tokenId, address _user)
        internal
        view
        returns (bool result)
    {
        Monster[] memory myMonster = myMonsterOnInt[_user];
        uint256 length = myMonster.length;
        for (uint256 i; i < length; ++i) {
            uint256 tokenId = myMonster[i].tokenId;
            if (tokenId == _tokenId) {
                result = true;
            }
        }
    }

    function getMonsterIndexInt(uint256 _tokenId, address _user)
        internal
        view
        returns (uint256 index)
    {
        Monster[] memory myMonster = myMonsterOnInt[_user];
        uint256 length = myMonster.length;
        for (uint256 i; i < length; ++i) {
            uint256 tokenId = myMonster[i].tokenId;
            if (tokenId == _tokenId) {
                index = i;
            }
        }
    }

    function getMonsterIndexBeg(uint256 _tokenId, address _user)
        internal
        view
        returns (uint256 index)
    {
        Monster[] memory myMonster = myMonsterOnBeg[_user];
        uint256 length = myMonster.length;
        for (uint256 i; i < length; ++i) {
            uint256 tokenId = myMonster[i].tokenId;
            if (tokenId == _tokenId) {
                index = i;
            }
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
