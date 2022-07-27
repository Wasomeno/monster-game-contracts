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

    mapping(address => Rest[]) public monsterOnNursery;
    mapping(uint256 => Item) public nurseryShop;

    function setInterface(address _monsterNFT, address _itemNFT) public {
        monsterInterface = IMonster(_monsterNFT);
        itemInterface = IERC1155(_itemNFT);
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
        Rest[] storage rest = monsterOnNursery[_user];
        rest.push(Rest(_tokenId, _user, _duration, block.timestamp));
        monsterInterface.setStatus(_tokenId, 2);
    }

    function goBackHome(uint256 _tokenId, address _user) external {
        Rest[] memory myMonster = monsterOnNursery[_user];
        uint256 index = getMonsterIndex(_tokenId, _user);
        uint256 startTime = myMonster[index].startTime;
        uint256 hunger = monsterInterface.getMonsterHunger(_tokenId);
        uint256 duration = myMonster[index].duration;
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

    function buyItem(
        uint256 _shopId,
        uint256 _quantity,
        address _user
    ) public payable {
        Item storage itemShop = nurseryShop[_shopId];
        Item memory _itemShop = nurseryShop[_shopId];
        require(_quantity <= 3, "There's only 3 stocks per item everyday");
        require(_itemShop.quantity > 0, "No stock left");
        require(
            msg.value == _itemShop.price * _quantity,
            "Wrong value of ether sent"
        );
        itemInterface.safeTransferFrom(
            address(this),
            _user,
            _itemShop.item,
            _quantity,
            ""
        );
        itemShop.quantity = _itemShop.quantity - _quantity;
    }

    function getMonsterIndex(uint256 _tokenId, address _user)
        public
        view
        returns (uint256 index)
    {
        Rest[] memory monsters = monsterOnNursery[_user];
        uint256 length = monsters.length;
        for (uint256 i; i < length; ++i) {
            Rest memory monster = monsters[i];
            if (monster.monster == _tokenId) {
                index = i;
            }
        }
    }

    function deleteMonster(uint256 _tokenId, address _user) public {
        uint256 index;
        Rest[] storage myMonsterStr = monsterOnNursery[_user];
        Rest[] memory myMonsterMem = monsterOnNursery[_user];
        uint256 length = myMonsterMem.length;
        for (uint256 i; i < length; ++i) {
            uint256 monster = myMonsterMem[i].monster;
            if (monster == _tokenId) {
                index = i;
            }
        }
        myMonsterStr[index] = myMonsterMem[length - 1];
        myMonsterStr.pop();
    }

    function getMyMonsters(address _user)
        external
        view
        returns (Rest[] memory monsters)
    {
        monsters = monsterOnNursery[_user];
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
