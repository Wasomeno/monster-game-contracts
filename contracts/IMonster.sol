// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./MonstersNFT.sol";

interface IMonster {

    struct Stats {
        uint level;
        uint hunger;
        uint exp;
        uint expCap;
        uint missionDuration;
        uint cooldown;
    }

    function levelUp(uint _tokenId) external;
    function expUp(uint _tokenId, uint _amount) external;
    function setHunger(uint _tokenId, uint _hunger) external;
    function setCooldown(uint _tokenId) external;
    function setMissionStart(uint _tokenId) external;
    function getMonsterExp(uint _tokenId) external view returns(uint);
    function getMonsterLevel(uint _tokenId) external view returns(uint); 
    function getMonsterExpCap(uint _tokenId) external view returns(uint); 
    function getMonsterHunger(uint _tokenId) external view returns(uint);
    function getMonsterCooldown(uint _tokenId) external view returns(uint);
    function getMonsterMissionStart(uint _tokenId) external view returns(uint);
    function resetMissionStart(uint _tokenId) external;
    function feedMonster(uint _tokenId, uint _amount) external;


}