// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Items is ERC1155, Ownable {
    struct Details {
        uint8 itemsAmount;
        mapping(uint256 => uint8) items;
        mapping(uint256 => uint8) rates;
    }

    uint8 internal constant M_COINS = 0;
    uint8 internal constant BERRY = 1;
    uint8 internal constant ENERGY_POTION = 2;
    uint8 internal constant EXP_POTION = 3;
    uint8 internal constant TOKEN_CRYSTAL = 4;

    uint8 internal itemsAmount;
    uint8 internal dropsAmount;

    mapping(uint256 => uint8) public items;
    mapping(uint256 => uint8) public drops;
    mapping(address => bool) public approvedAddress;
    mapping(uint256 => Details) public dropsDetails;

    constructor() ERC1155("") {}

    error NotApproved(address _caller);

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

    modifier isApproved(address _caller) {
        bool result = approvedAddress[_caller];
        if (!result) {
            revert NotApproved(_caller);
        }
        _;
    }

    function setApprovedAddress(address _approved) external onlyOwner {
        approvedAddress[_approved] = true;
    }

    function addNewItems(uint256[] memory _items) external onlyOwner {
        uint256 _itemsAmount = uint256(itemsAmount);
        uint8 newAMount = uint8(_itemsAmount + _items.length);
        for (uint256 i = _itemsAmount; i < newAMount; ++i) {
            items[i] = uint8(_items[i]);
        }
        itemsAmount = newAMount;
    }

    function mintForShop(
        address _user,
        uint256[] calldata _id,
        uint256[] calldata _quantity
    ) external isApproved(msg.sender) {
        uint256 arrLength = _id.length;
        for (uint256 i; i < arrLength; ++i) {
            _mint(_user, _id[i], _quantity[i], "");
        }
    }

    function mintForTrade(
        address _user,
        uint256 _id,
        uint256 _quantity
    ) external isApproved(msg.sender) {
        _mint(_user, _id, _quantity, "");
    }

    function missionsReward(
        uint256 _mission,
        uint256 _monster,
        address _user,
        uint256 _odds
    ) external isApproved(msg.sender) {
        if (_mission != 2) {
            beginnerMissionReward(_monster, _user, _odds);
        }

        intermediateMissionReward(_monster, _user, _odds);
    }

    function bossFightReward(
        uint256 _monster,
        address _user,
        uint256 _odds,
        uint256 _chance
    ) external isApproved(msg.sender) {
        if (_odds < _chance) {
            uint256[] memory items = getDropItems(6);
            uint256[] memory rates = getDropRates(6);
            _mintBatch(_user, items, rates, "");
            emit BossFightReward(_monster, items, rates);
        } else {
            uint256[] memory items = getDropItems(7);
            uint256[] memory rates = getDropRates(7);
            _mintBatch(_user, items, rates, "");
            emit BossFightReward(_monster, items, rates);
        }
    }

    function setApprovalAll(address _operator, bool _approved) external {
        setApprovalForAll(_operator, _approved);
    }

    function getInventory(address _user)
        external
        view
        returns (uint256[] memory inventory)
    {
        uint256 _itemsAmount = uint256(itemsAmount);
        uint256[] memory inventoryTemp = new uint256[](_itemsAmount);
        for (uint256 i; i < _itemsAmount; ++i) {
            uint256 balance = balanceOf(_user, i);
            if (balance > 0) {
                inventoryTemp[i] = (balanceOf(_user, i));
            }
        }
        inventory = inventoryTemp;
    }

    function getItems() external view returns (uint256[] memory _items) {
        uint256 _itemsAmount = uint256(itemsAmount);
        _items = new uint256[](_itemsAmount);
        for (uint256 i; i < _itemsAmount; ++i) {
            _items[i] = i;
        }
    }

    function addDrops(
        uint256 _dropsId,
        uint256[] calldata _items,
        uint256[] calldata _rates
    ) external onlyOwner {
        uint256 _dropsAmount = dropsAmount;
        Details storage details = dropsDetails[_dropsAmount];
        for (uint256 i; i < _items.length; ++i) {
            details.itemsAmount = uint8(_items.length);
            details.items[i] = uint8(_items[i]);
            details.rates[i] = uint8(_rates[i]);
        }
        drops[_dropsAmount] = uint8(_dropsId);
        uint256 newAmount = _dropsAmount + 1;
        dropsAmount = uint8(newAmount);
    }

    function beginnerMissionReward(
        uint256 _monster,
        address _user,
        uint256 _odds
    ) internal {
        if (_odds <= 60 && 0 <= _odds) {
            uint256[] memory items = getDropItems(0);
            uint256[] memory rates = getDropRates(0);
            _mintBatch(_user, items, rates, "");
            emit BeginnerMissionReward(_monster, items, rates);
        } else if (_odds <= 90 && 70 <= _odds) {
            uint256[] memory items = getDropItems(1);
            uint256[] memory rates = getDropRates(1);
            _mintBatch(_user, items, rates, "");
            emit BeginnerMissionReward(_monster, items, rates);
        } else {
            uint256[] memory items = getDropItems(2);
            uint256[] memory rates = getDropRates(2);
            _mintBatch(_user, items, rates, "");
            emit BeginnerMissionReward(_monster, items, rates);
        }
    }

    function intermediateMissionReward(
        uint256 _monster,
        address _user,
        uint256 _odds
    ) internal {
        if (_odds <= 60 && 0 <= _odds) {
            uint256[] memory items = getDropItems(3);
            uint256[] memory rates = getDropRates(3);
            _mintBatch(_user, items, rates, "");
            emit IntermediateMissionReward(_monster, items, rates);
        } else if (_odds <= 90 && 70 <= _odds) {
            uint256[] memory items = getDropItems(4);
            uint256[] memory rates = getDropRates(4);
            _mintBatch(_user, items, rates, "");
            emit IntermediateMissionReward(_monster, items, rates);
        } else {
            uint256[] memory items = getDropItems(5);
            uint256[] memory rates = getDropRates(5);
            _mintBatch(_user, items, rates, "");
            emit IntermediateMissionReward(_monster, items, rates);
        }
    }

    function getDropItems(uint256 _dropId)
        internal
        view
        returns (uint256[] memory _items)
    {
        Details storage details = dropsDetails[_dropId];
        uint256 amount = uint256(details.itemsAmount);
        _items = new uint256[](amount);
        for (uint256 i; i < amount; ++i) {
            uint256 item = details.items[i];
            _items[i] = item;
        }
    }

    function getDropRates(uint256 _dropId)
        internal
        view
        returns (uint256[] memory _rates)
    {
        Details storage details = dropsDetails[_dropId];
        uint256 amount = uint256(details.itemsAmount);
        _rates = new uint256[](amount);
        for (uint256 i; i < amount; ++i) {
            uint256 rate = details.rates[i];
            _rates[i] = rate;
        }
    }
}
