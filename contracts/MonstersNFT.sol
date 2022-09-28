// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IUsersData.sol";

contract Monsters is ERC721, Ownable {
    struct Stats {
        uint256 id;
        uint256 level;
        uint256 energy;
        uint256 exp;
        uint256 expCap;
        uint256 cooldown;
        uint256 status;
    }

    IUsersData public usersDataInterface;

    uint256 public constant MAX_MONSTER_POPULATION = 10000;
    uint256 public constant SUMMON_PRICE = 0.002 ether;
    uint256 public monsterPopulation;
    uint256 public nonce;
    string private _baseTokenURI;

    mapping(uint256 => Stats) public monsterStats;
    mapping(address => bool) public approvedAddress;

    constructor() ERC721("Monsters", "MTR") {}

    receive() external payable {}

    error NotValidToSummon(
        uint256 _quantity,
        uint256 _sent,
        uint256 _population
    );

    error CallerNotApproved(address _caller);

    modifier isRegistered(address _user) {
        usersDataInterface.checkRegister(_user);
        _;
    }

    modifier isApproved(address _caller) {
        bool result = approvedAddress[_caller];
        if (!result) {
            revert CallerNotApproved(_caller);
        }
        _;
    }

    function summon(uint256 _quantity)
        external
        payable
        isRegistered(msg.sender)
    {
        uint256 total = _quantity * SUMMON_PRICE;
        uint256 _monsterPopulation = monsterPopulation;
        uint256 population = _monsterPopulation + _quantity;
        if (
            _quantity > 5 ||
            msg.value != total ||
            population > MAX_MONSTER_POPULATION
        ) {
            revert NotValidToSummon(_quantity, msg.value, _monsterPopulation);
        }
        for (uint256 i; i < _quantity; ++i) {
            _mint(msg.sender, _monsterPopulation);
            monsterStats[_monsterPopulation] = Stats(
                _monsterPopulation,
                1,
                30,
                0,
                15,
                0,
                0
            );
            _monsterPopulation++;
        }
        monsterPopulation = _monsterPopulation;
    }

    function setApprovedAddress(address _approved) external onlyOwner {
        approvedAddress[_approved] = true;
    }

    function expUp(uint256 _tokenId, uint256 _amount)
        external
        isApproved(msg.sender)
    {
        Stats storage monster = monsterStats[_tokenId];
        monster.exp += _amount;
        if (monster.exp > monster.expCap) {
            levelUp(_tokenId);
        }
    }

    function setEnergy(uint256 _tokenId, uint256 _energy)
        external
        isApproved(msg.sender)
    {
        Stats storage monster = monsterStats[_tokenId];
        monster.energy = _energy;
    }

    function setCooldown(uint256 _tokenId) external {
        Stats storage monster = monsterStats[_tokenId];
        monster.cooldown = block.timestamp + 5 minutes;
    }

    function setStatus(uint256 _tokenId, uint256 _status)
        external
        isApproved(msg.sender)
    {
        Stats storage monster = monsterStats[_tokenId];
        monster.status = _status;
    }

    function getMonstersDetails(address _to)
        external
        view
        returns (Stats[] memory)
    {
        uint256[] memory monsters = getMonsters(_to);
        Stats[] memory monstersDetails = new Stats[](monsters.length);
        for (uint256 i; i < monsters.length; ++i) {
            uint256 monster = monsters[i];
            Stats memory details = monsterStats[monster];
            monstersDetails[i] = details;
        }
        return monstersDetails;
    }

    function getMonsterExp(uint256 _tokenId) external view returns (uint256) {
        uint256 monsterExp = monsterStats[_tokenId].exp;
        return monsterExp;
    }

    function getMonsterLevel(uint256 _tokenId) external view returns (uint256) {
        uint256 monsterLevel = monsterStats[_tokenId].level;
        return monsterLevel;
    }

    function getMonsterExpCap(uint256 _tokenId)
        external
        view
        returns (uint256)
    {
        uint256 monsterExpCap = monsterStats[_tokenId].expCap;
        return monsterExpCap;
    }

    function getMonsterEnergy(uint256 _tokenId)
        external
        view
        returns (uint256)
    {
        uint256 monsterEnergy = monsterStats[_tokenId].energy;
        return monsterEnergy;
    }

    function getMonsterCooldown(uint256 _tokenId)
        external
        view
        returns (uint256)
    {
        uint256 monsterCooldown = monsterStats[_tokenId].cooldown;
        return monsterCooldown;
    }

    function getMonsterStatus(uint256 _tokenId)
        external
        view
        returns (uint256)
    {
        uint256 monsterStatus = monsterStats[_tokenId].status;
        return monsterStatus;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    function getMonsters(address _to) public view returns (uint256[] memory) {
        uint256 index;
        uint256 balance = balanceOf(_to);
        uint256[] memory monsters = new uint256[](balance);
        uint256 _monsterPopulation = monsterPopulation;
        for (uint256 i; i < _monsterPopulation; ++i) {
            address owner = ownerOf(i);
            if (owner == _to) {
                monsters[index] = i;
                index++;
            }
        }
        return monsters;
    }

    function ownerOf(uint256 _monster)
        public
        view
        virtual
        override
        returns (address _owner)
    {
        _owner = ownerOf(_monster);
    }

    function levelUp(uint256 _tokenId) internal {
        Stats storage monster = monsterStats[_tokenId];
        Stats memory monsterMem = monsterStats[_tokenId];
        uint256 monsterExp = monsterMem.exp;
        uint256 monsterExpCap = monsterMem.expCap;
        monster.level++;
        monster.exp = monsterExp - monsterExpCap;
        monster.expCap = monsterMem.level * 15;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }
}
