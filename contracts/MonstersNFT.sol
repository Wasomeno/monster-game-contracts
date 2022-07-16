// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Monsters is ERC721, Ownable {
    struct Stats {
        uint256 level;
        uint256 hunger;
        uint256 exp;
        uint256 expCap;
        uint256 cooldown;
        uint256 status;
    }

    uint256 public monsterPopulation = 0;
    uint256 public monsterPopulationCap = 100;
    uint256 public nonce = 0;
    uint256 public price = 0.002 ether;
    string private _baseTokenURI;

    mapping(uint256 => Stats) public monsterStats;

    constructor() ERC721("Monsters", "MTR") {}

    function summon(uint256 _quantity) external payable {
        require(_quantity <= 5, "You can't mint more than 5");
        require(msg.value == _quantity * price, "Wrong value of ether sent");
        for (uint256 i; i < _quantity; ++i) {
            _safeMint(msg.sender, monsterPopulation);
            monsterStats[monsterPopulation] = Stats(1, 30, 0, 15, 0, 0);
            monsterPopulation++;
        }
    }

    function getMyMonster(address _to)
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory monsters = new uint256[](balanceOf(_to));
        uint256 _monsterPopulation = monsterPopulation;
        uint256 index = 0;

        for (uint256 i; i < _monsterPopulation; i++) {
            if (ownerOf(i) == _to) {
                monsters[index] = i;
            }
            index++;
        }
        return monsters;
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

    function expUp(uint256 _tokenId, uint256 _amount) external {
        Stats storage monster = monsterStats[_tokenId];
        monster.exp += _amount;
        if (monster.exp > monster.expCap) {
            levelUp(_tokenId);
        }
    }

    function setHunger(uint256 _tokenId, uint256 _hunger) external {
        Stats storage monster = monsterStats[_tokenId];
        monster.hunger = _hunger;
    }

    function setCooldown(uint256 _tokenId) external {
        Stats storage monster = monsterStats[_tokenId];
        monster.cooldown = block.timestamp + 5 minutes;
    }

    function setStatus(uint256 _tokenId, uint256 _status) external {
        Stats storage monster = monsterStats[_tokenId];
        monster.status = _status;
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

    function getMonsterHunger(uint256 _tokenId)
        external
        view
        returns (uint256)
    {
        uint256 monsterHunger = monsterStats[_tokenId].hunger;
        return monsterHunger;
    }

    function getMonsterCooldown(uint256 _tokenId)
        public
        view
        returns (uint256)
    {
        uint256 monsterCooldown = monsterStats[_tokenId].cooldown;
        return monsterCooldown;
    }

    function getMonsterStatus(uint256 _tokenId) public view returns (uint256) {
        uint256 monsterStatus = monsterStats[_tokenId].status;
        return monsterStatus;
    }

    function feedMonster(uint256 _tokenId, uint256 _amount) external {
        uint256 hunger = monsterStats[_tokenId].hunger;
        require(hunger + _amount < 100, "Too much food");
        Stats storage monster = monsterStats[_tokenId];
        monster.hunger = hunger + _amount;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    receive() external payable {}
}
