// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IUsersData.sol";

contract Monsters is ERC721A, Ownable {
    struct Stats {
        uint8 level;
        uint8 energy;
        uint8 energyCap;
        uint8 exp;
        uint8 expCap;
        uint8 status;
        uint32 cooldown;
    }

    IUsersData public usersDataInterface;
    IERC721A public erc721Interface;

    uint256 public constant MAX_MONSTER_POPULATION = 10000;
    uint256 public constant SUMMON_PRICE = 0.002 ether;
    uint256 public monsterPopulation;
    uint256 public nonce;
    string private _baseTokenURI;

    mapping(uint256 => Stats) public monsterStats;
    mapping(address => bool) public approvedAddress;

    constructor() ERC721A("Monsters", "MTR") {}

    receive() external payable {}

    error NotValidToSummon(
        uint256 _quantity,
        uint256 _sent,
        uint256 _population
    );
    error CallerNotApproved(address _caller);
    error MaxLevelHit(uint256 _monster, uint256 _level);

    modifier isRegistered() {
        usersDataInterface.checkRegister(msg.sender);
        _;
    }

    modifier isApproved() {
        bool result = approvedAddress[msg.sender];
        if (!result) revert CallerNotApproved(msg.sender);
        _;
    }

    function setInterface(address _usersDataContract) external onlyOwner {
        usersDataInterface = IUsersData(_usersDataContract);
    }

    function summon(uint256 _quantity) external payable isRegistered {
        uint256 _monsterPopulation = monsterPopulation;
        uint256 total = _quantity * SUMMON_PRICE;
        uint256 population = _monsterPopulation + _quantity;
        if (
            _quantity > 5 ||
            population > MAX_MONSTER_POPULATION ||
            msg.value != total
        ) revert NotValidToSummon(_quantity, msg.value, _monsterPopulation);

        for (uint256 i; i < _quantity; ++i) {
            Stats storage monsterStatus = monsterStats[_monsterPopulation];
            monsterStatus.level = 1;
            monsterStatus.energy = 30;
            monsterStatus.energyCap = 100;
            monsterStatus.exp = 0;
            monsterStatus.expCap = 15;
            monsterStatus.cooldown = 0;
            monsterStatus.status = 0;
            _monsterPopulation++;
        }
        _mint(msg.sender, _quantity);
        monsterPopulation = uint16(_monsterPopulation);
    }

    function setApprovedAddress(address _approved) external onlyOwner {
        approvedAddress[_approved] = true;
    }

    function expUp(uint256 _monster, uint256 _amount) external isApproved {
        Stats storage monster = monsterStats[_monster];
        monster.exp += uint8(_amount);
        if (monster.exp > monster.expCap) {
            levelUp(_monster);
        }
    }

    function setEnergy(uint256 _monster, uint256 _energy) external isApproved {
        Stats storage monster = monsterStats[_monster];
        monster.energy = uint8(_energy);
    }

    function setCooldown(uint256 _monster) external isApproved {
        Stats storage monster = monsterStats[_monster];
        monster.cooldown = uint32(block.timestamp + 5 minutes);
    }

    function setStatus(uint256 _monster, uint256 _status) external isApproved {
        Stats storage monster = monsterStats[_monster];
        monster.status = uint8(_status);
    }

    function getMonstersDetails(address _user)
        external
        view
        returns (Stats[] memory)
    {
        uint256[] memory monsters = getMonsters(_user);
        Stats[] memory monstersDetails = new Stats[](monsters.length);
        for (uint256 i; i < monsters.length; ++i) {
            uint256 monster = monsters[i];
            Stats memory details = monsterStats[monster];
            monstersDetails[i] = details;
        }
        return monstersDetails;
    }

    function getMonsterExp(uint256 _monster) external view returns (uint256) {
        uint8 monsterExp = monsterStats[_monster].exp;
        return uint256(monsterExp);
    }

    function getMonsterLevel(uint256 _monster) external view returns (uint256) {
        uint8 monsterLevel = monsterStats[_monster].level;
        return uint256(monsterLevel);
    }

    function getMonsterExpCap(uint256 _monster)
        external
        view
        returns (uint256)
    {
        uint8 monsterExpCap = monsterStats[_monster].expCap;
        return uint256(monsterExpCap);
    }

    function getMonsterEnergy(uint256 _monster)
        external
        view
        returns (uint256)
    {
        uint8 monsterEnergy = monsterStats[_monster].energy;
        return uint256(monsterEnergy);
    }

    function getMonsterCooldown(uint256 _monster)
        external
        view
        returns (uint256)
    {
        uint32 monsterCooldown = monsterStats[_monster].cooldown;
        return uint256(monsterCooldown);
    }

    function getMonsterStatus(uint256 _monster)
        external
        view
        returns (uint256)
    {
        uint8 monsterStatus = monsterStats[_monster].status;
        return uint256(monsterStatus);
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    function getMonsters(address _user) public view returns (uint256[] memory) {
        uint256 index;
        uint256 balance = balanceOf(_user);
        uint256[] memory monsters = new uint256[](balance);
        uint256 _monsterPopulation = monsterPopulation;
        for (uint256 i; i < _monsterPopulation; ++i) {
            address owner = ownerOf(i);
            if (owner == _user) {
                monsters[index] = i;
                index++;
            }
        }
        return monsters;
    }

    function levelUp(uint256 _monster) internal {
        Stats storage monster = monsterStats[_monster];
        Stats memory monsterMem = monsterStats[_monster];
        uint256 monsterExp = uint256(monsterMem.exp);
        uint256 monsterExpCap = uint256(monsterMem.expCap);
        monster.level++;
        monster.exp = uint8(monsterExp - monsterExpCap);
        monster.expCap = monsterMem.level * 15;
        monster.energyCap += 5;
    }

    function monsterOwner(uint256 _monster)
        external
        view
        returns (address _owner)
    {
        _owner = ownerOf(_monster);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }
}
