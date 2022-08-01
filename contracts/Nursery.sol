// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./IMonster.sol";

contract Nursery is ERC1155Receiver {
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
    IERC1155 itemInterface;

    mapping(address => uint256[]) public ownerToMonsters;
    mapping(address => mapping(uint256 => Rest)) public monsterOnNursery;

    function setInterface(address _monsterNFT, address _itemNFT) public {
        monsterInterface = IMonster(_monsterNFT);
        itemInterface = IERC1155(_itemNFT);
    }

    modifier isOnNursery(address _user, uint256 _tokenId) {
        bool result;
        uint256[] memory monsters = ownerToMonsters[_user];
        for (uint256 i; i < monsters.length; ++i) {
            uint256 monster = monsters[i];
            if (_tokenId == monster) {
                result = true;
            }
            require(result, "Your monster is not here");
        }
        _;
    }

    function putOnNursery(
        uint256 _tokenId,
        address _user,
        uint256 _duration
    ) external payable {
        uint256 hunger = monsterInterface.getMonsterHunger(_tokenId);
        uint256 status = monsterInterface.getMonsterStatus(_tokenId);
        require(status == 0, "Your monster still working on something");
        require(_duration * 10 + hunger <= 100, "Reduce the duration");
        require(msg.value >= _duration * 0.0001 ether, "Wrong value sent");
        monsterOnNursery[_user][_tokenId] = Rest(
            _tokenId,
            _user,
            _duration,
            block.timestamp
        );
        ownerToMonsters[_user].push(_tokenId);
        monsterInterface.setStatus(_tokenId, 2);
    }

    function goBackHome(uint256 _tokenId, address _user)
        external
        isOnNursery(_user, _tokenId)
    {
        Rest memory monsterDetails = monsterOnNursery[_user][_tokenId];
        uint256 startTime = monsterDetails.startTime;
        uint256 hunger = monsterInterface.getMonsterHunger(_tokenId);
        uint256 duration = monsterDetails.duration;
        uint256 durationToHour = duration * 1 hours;
        uint256 newHunger = duration * 10;
        require(
            startTime + durationToHour < block.timestamp,
            "Your monster still resting"
        );
        monsterInterface.feedMonster(_tokenId, newHunger);
        monsterInterface.setStatus(_tokenId, 0);
        deleteMonster(_tokenId, _user);
    }

    function deleteMonster(uint256 _tokenId, address _user) internal {
        Rest storage monsterDetails = monsterOnNursery[_user][_tokenId];
        delete monsterDetails.monster;
        delete monsterDetails.owner;
        delete monsterDetails.duration;
        delete monsterDetails.startTime;
    }

    function getMyMonsters(address _user)
        external
        view
        returns (Rest[] memory monsters)
    {
        uint256[] memory myMonsters = ownerToMonsters[_user];
        Rest[] memory details = new Rest[](myMonsters.length);
        for (uint256 i; i < myMonsters.length; ++i) {
            uint256 tokenId = myMonsters[i];
            details[i] = monsterOnNursery[_user][tokenId];
        }
        monsters = details;
    }

    receive() external payable {}

    function onERC1155BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external pure override returns (bytes4) {
        bytes4(
            keccak256(
                "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
            )
        );
    }

    function onERC1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external pure override returns (bytes4) {
        bytes4(
            keccak256(
                "onERC1155Received(address,address,uint256,uint256,bytes)"
            )
        );
    }
}
