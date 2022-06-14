// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract Monsters is ERC721, Ownable {

    struct Stats {
        uint level;
        uint hunger;
        uint exp;
        uint expCap;
        uint missionStartTime;
        uint cooldown;
        uint status;
    }
    
    uint public monsterPopulation = 0;
    uint public monsterPopulationCap = 100;
    uint public nonce = 0;
    uint public price = 0.002 ether;
    string private _baseTokenURI;
    

    mapping(uint => Stats) public monsterStats;

    constructor() ERC721 ("Monsters", "MTR") {

    }

    function summon(uint _quantity) public payable{
        require(_quantity <= 5, "You can't mint more than 5");
        require(msg.value == _quantity * price, "Wrong value of ether sent");
        for(uint i; i < _quantity; i++) {
            _safeMint(msg.sender, monsterPopulation);
            monsterStats[monsterPopulation] = Stats(1, 30, 0, 15, 0, 0, 0);
            monsterPopulation++;
        }
    }

    function getMyMonster(address _to) public view returns(uint[] memory){
        uint[] memory monsters = new uint[](balanceOf(_to));
        uint index = 0;

        for(uint i; i < monsterPopulation; i++) {
            if(ownerOf(i) == _to) {
                monsters[index] = i;
            }
            index++;
        }
        return monsters;
    }

    function levelUp(uint _tokenId) public {
        Stats storage monsterStats = monsterStats[_tokenId];
        monsterStats.level ++;
        monsterStats.exp = monsterStats.exp - monsterStats.expCap;
        monsterStats.expCap = monsterStats.level * 15;
        
    }

    function expUp(uint _tokenId, uint _amount) public {
        Stats storage monsterStats = monsterStats[_tokenId];
        monsterStats.exp += _amount;
        if(monsterStats.exp > monsterStats.expCap) {
            levelUp(_tokenId);
        }
    }

    function setHunger(uint _tokenId, uint _hunger) public {
        Stats storage monsterStats = monsterStats[_tokenId];
        monsterStats.hunger = _hunger;
    }

    function setMissionStart(uint _tokenId) public {
        Stats storage monsterStats = monsterStats[_tokenId];
        monsterStats.missionStartTime = block.timestamp;
    }

    function resetMissionStart(uint _tokenId) public {
        Stats storage monsterStats = monsterStats[_tokenId];
        monsterStats.missionStartTime = 0;   
    }

    function setCooldown(uint _tokenId) public {
        Stats storage monsterStats = monsterStats[_tokenId];
        monsterStats.cooldown = block.timestamp + 5 minutes;
    }

    function setStatus(uint _tokenId, uint _status) public {
        Stats storage monsterStats = monsterStats[_tokenId];
        monsterStats.status = _status;
    }

    function getMonsterExp(uint _tokenId) public view returns(uint) {
        uint monsterExp = monsterStats[_tokenId].exp;
        return monsterExp;
    }

    function getMonsterLevel(uint _tokenId) public view returns(uint) {
        uint monsterLevel = monsterStats[_tokenId].level;
        return monsterLevel;
    }

    function getMonsterExpCap(uint _tokenId) public view returns(uint) {
        uint monsterExpCap = monsterStats[_tokenId].expCap;
        return monsterExpCap;
    }

    function getMonsterHunger(uint _tokenId) public view returns(uint) {
        uint monsterHunger = monsterStats[_tokenId].hunger;
        return monsterHunger;
    }

    function getMonsterCooldown(uint _tokenId) public view returns(uint) {
        uint monsterCooldown = monsterStats[_tokenId].cooldown;
        return monsterCooldown;
    }

    function getMonsterMissionStart(uint _tokenId) public view returns(uint) {
        uint monsterMissionStart = monsterStats[_tokenId].missionStartTime;
        return monsterMissionStart;
    }

    function getMonsterStatus(uint _tokenId) public view returns(uint) {
        uint monsterStatus = monsterStats[_tokenId].status;
        return monsterStatus;
    }

    function feedMonster(uint _tokenId, uint _amount) public {
        require(monsterStats[_tokenId].hunger + _amount < 100, "Too much food for your monster");
        Stats storage monsterStats = monsterStats[_tokenId];
        monsterStats.hunger = monsterStats.hunger + _amount;
    }


    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }


    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    receive() external payable{

    }   


}