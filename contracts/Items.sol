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

    event BeginnerMissionReward(
        uint256 _monster,
        uint256[] _items,
        uint256[] _amount
    );

    event IntermediateMissionReward(
        uint256 _monster,
        uint256[] _items,
        uint256[] _amount
    );

    event BossFightReward(
        uint256 _monster,
        uint256[] _items,
        uint256[] _amount
    );

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

    function beginnerMissionReward(
        uint256 _monster,
        address _user,
        uint256 _odds
    ) external {
        if (_odds <= 60 && 0 <= _odds) {
            uint256[] memory itemsSetOne = itemSet[0];
            uint256[] memory quantitiesSetOne = itemRateSet[0];
            _mintBatch(_user, itemsSetOne, quantitiesSetOne, "");
            emit BeginnerMissionReward(_monster, itemsSetOne, quantitiesSetOne);
        } else if (_odds <= 90 && 70 <= _odds) {
            uint256[] memory itemsSetTwo = itemSet[1];
            uint256[] memory quantitiesSetTwo = itemRateSet[1];
            _mintBatch(_user, itemsSetTwo, quantitiesSetTwo, "");
            emit BeginnerMissionReward(_monster, itemsSetTwo, quantitiesSetTwo);
        } else {
            uint256[] memory itemsSetThree = itemSet[2];
            uint256[] memory quantitiesSetThree = itemRateSet[2];
            _mintBatch(_user, itemsSetThree, quantitiesSetThree, "");
            emit BeginnerMissionReward(
                _monster,
                itemsSetThree,
                quantitiesSetThree
            );
        }
    }

    function intermediateMissionReward(
        uint256 _monster,
        address _user,
        uint256 _odds
    ) external {
        if (_odds <= 60 && 0 <= _odds) {
            uint256[] memory itemsSetFour = itemSet[3];
            uint256[] memory quantitiesSetFour = itemRateSet[3];
            _mintBatch(_user, itemsSetFour, quantitiesSetFour, "");
            emit IntermediateMissionReward(
                _monster,
                itemsSetFour,
                quantitiesSetFour
            );
        } else if (_odds <= 90 && 70 <= _odds) {
            uint256[] memory itemsSetFive = itemSet[4];
            uint256[] memory quantitiesSetFive = itemRateSet[4];
            _mintBatch(_user, itemsSetFive, quantitiesSetFive, "");
            emit IntermediateMissionReward(
                _monster,
                itemsSetFive,
                quantitiesSetFive
            );
        } else {
            uint256[] memory itemsSetSix = itemSet[5];
            uint256[] memory quantitiesSetSix = itemRateSet[5];
            _mintBatch(_user, itemsSetSix, quantitiesSetSix, "");
            emit IntermediateMissionReward(
                _monster,
                itemsSetSix,
                quantitiesSetSix
            );
        }
    }

    function bossFightReward(
        uint256 _monster,
        address _user,
        uint256 _odds,
        uint256 _chance
    ) external {
        if (_odds < _chance) {
            uint256[] memory bossItemsSetOne = bossRewardSet[0];
            uint256[] memory bossQuantitiesSetOne = bossRateSet[0];
            _mintBatch(_user, bossItemsSetOne, bossQuantitiesSetOne, "");
            emit BossFightReward(
                _monster,
                bossItemsSetOne,
                bossQuantitiesSetOne
            );
        } else {
            uint256[] memory bossItemsSetTwo = bossRewardSet[1];
            uint256[] memory bossQuantitiesSetTwo = bossRateSet[1];
            _mintBatch(_user, bossItemsSetTwo, bossQuantitiesSetTwo, "");
            emit BossFightReward(
                _monster,
                bossItemsSetTwo,
                bossQuantitiesSetTwo
            );
        }
    }

    function useHungerPotion(
        address _user,
        uint256 _tokenId,
        uint256 _amount
    ) external {
        uint256 balance = balanceOf(_user, HUNGER_POTION);
        uint256 hunger = monsterInterface.getMonsterHunger(_tokenId);
        uint256 newHunger = hunger + 10;
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
        uint256 newExp = exp + 3;
        require(balance >= _amount, "Not enough items");
        safeTransferFrom(_user, address(this), EXP_BOTTLE, _amount, "");
        monsterInterface.expUp(_tokenId, 3);
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
}
