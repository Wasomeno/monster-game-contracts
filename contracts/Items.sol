// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./IMonsterGame.sol";
import "./IMonster.sol";

contract Items is ERC1155 {
    IMonsterGame gameInterface;
    IMonster monsterInterface;

    uint256 internal constant M_COINS = 0;
    uint256 internal constant BERRY = 1;
    uint256 internal constant HUNGER_POTION = 2;
    uint256 internal constant EXP_BOTTLE = 3;
    uint256 internal constant TOKEN_CRYSTAL = 4;

    uint256[] internal items;
    mapping(uint256 => uint256[]) public itemRateSet;
    mapping(uint256 => uint256[]) public itemSet;
    mapping(uint256 => uint256[]) public bossRewardSet;
    mapping(uint256 => uint256[]) public bossRateSet;

    constructor() ERC1155("") {
        itemSet[0].push(0);
        itemSet[0].push(1);
        itemRateSet[0].push(3);
        itemRateSet[0].push(5);

        itemSet[1].push(0);
        itemSet[1].push(1);
        itemRateSet[1].push(6);
        itemRateSet[1].push(7);

        itemSet[2].push(0);
        itemSet[2].push(1);
        itemRateSet[2].push(10);
        itemRateSet[2].push(10);

        bossRewardSet[0].push(0);
        bossRewardSet[0].push(2);
        bossRewardSet[0].push(3);
        bossRewardSet[0].push(4);

        bossRewardSet[1].push(0);
        bossRewardSet[1].push(2);
        bossRewardSet[1].push(4);

        bossRateSet[1].push(10);
        bossRateSet[1].push(1);
        bossRateSet[1].push(3);

        bossRateSet[0].push(50);
        bossRateSet[0].push(2);
        bossRateSet[0].push(1);
        bossRateSet[0].push(10);
    }

    function setInterface(address _monsterGame, address _monsterNFT) external {
        gameInterface = IMonsterGame(_monsterGame);
        monsterInterface = IMonster(_monsterNFT);
    }

    function addNewItems(uint256[] memory _items) public {
        for (uint256 i; i < _items.length; ++i) {
            items.push(_items[i]);
        }
    }

    function mintForShop(
        address _user,
        uint256[] calldata _id,
        uint256[] calldata _quantity
    ) external {
        uint256 arrLength = _id.length;
        for (uint256 i; i < arrLength; ++i) {
            _mint(_user, _id[i], _quantity[i], "");
        }
    }

    function mintForTrade(
        address _user,
        uint256 _id,
        uint256 _quantity
    ) external {
        _mint(_user, _id, _quantity, "");
    }

    function newItemRatesSet(uint256 _id, uint256[] memory _rate) external {
        for (uint256 i; i < _rate.length; i++) {
            itemRateSet[_id].push(_rate[i]);
        }
    }

    function newItemsSet(uint256 _id, uint256[] memory _item) external {
        for (uint256 i; i < _item.length; i++) {
            itemSet[_id].push(_item[i]);
        }
    }

    function beginnerMissionReward(address _user, uint256 _odds) external {
        if (_odds <= 60 && 0 <= _odds) {
            _mintBatch(_user, itemSet[0], itemRateSet[0], "");
        } else if (_odds <= 90 && 70 <= _odds) {
            _mintBatch(_user, itemSet[1], itemRateSet[1], "");
        } else {
            _mintBatch(_user, itemSet[2], itemRateSet[2], "");
        }
    }

    function intermediateMissionReward(address _user, uint256 _odds) external {
        if (_odds <= 60 && 0 <= _odds) {
            _mintBatch(_user, itemSet[3], itemRateSet[3], "");
        } else if (_odds <= 90 && 70 <= _odds) {
            _mintBatch(_user, itemSet[4], itemRateSet[4], "");
        } else {
            _mintBatch(_user, itemSet[5], itemRateSet[5], "");
        }
    }

    function bossFightReward(
        address _user,
        uint256 _odds,
        uint256 _chance
    ) external {
        if (_odds < _chance) {
            _mintBatch(_user, bossRewardSet[0], bossRateSet[0], "");
        } else {
            _mintBatch(_user, bossRewardSet[1], bossRateSet[1], "");
        }
    }

    function useHungerPotion(
        address _user,
        uint256 _tokenId,
        uint256 _amount
    ) external {
        uint256 balance = balanceOf(_user, HUNGER_POTION);
        uint256 hunger = monsterInterface.getMonsterHunger(_tokenId);
        uint256 newHunger = hunger + 5;
        require(balance > _amount, "Not enough items");
        require(newHunger <= 100, "Too much hunger");
        safeTransferFrom(_user, address(this), HUNGER_POTION, _amount, "");
        monsterInterface.setHunger(_tokenId, newHunger);
    }

    function useExpBottle(
        address _user,
        uint256 _tokenId,
        uint256 _amount
    ) external {
        uint256 balance = balanceOf(_user, EXP_BOTTLE);
        uint256 exp = monsterInterface.getMonsterExp(_tokenId);
        uint256 newExp = exp + 1;
        require(balance >= _amount, "Not enough items");
        safeTransferFrom(_user, address(this), EXP_BOTTLE, _amount, "");
        monsterInterface.expUp(_tokenId, 1);
    }

    function getInventory(address _user)
        external
        view
        returns (uint256[] memory inventory)
    {
        uint256 length = items.length;
        uint256[] memory inventoryTemp = new uint256[](length);
        for (uint256 i; i < items.length; ++i) {
            uint256 balance = balanceOf(_user, i);
            if (balance > 0) {
                inventoryTemp[i] = (balanceOf(_user, i));
            }
        }

        inventory = inventoryTemp;
    }

    function getItems() external view returns (uint256[] memory _items) {
        _items = items;
    }

    function isItemExists(uint256 _itemId) internal view returns (bool result) {
        uint256 length = items.length;
        for (uint256 i; i < length; ++i) {
            uint256 item = items[i];
            if (_itemId == item) {
                result = true;
            }
        }
    }

    function areItemsExists(uint256[] memory _itemId)
        internal
        view
        returns (bool result)
    {
        uint256 length = items.length;
        for (uint256 i; i < length; ++i) {
            uint256 item = items[i];
            if (_itemId[i] == item) {
                result = true;
            }
        }
    }
}
