// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

interface IMonster {
    struct Stats {
        uint256 id;
        uint256 level;
        uint256 energy;
        uint256 exp;
        uint256 expCap;
        uint256 cooldown;
        uint256 status;
    }

    function levelUp(uint256 _tokenId) external;

    function expUp(uint256 _tokenId, uint256 _amount) external;

    function setEnergy(uint256 _tokenId, uint256 _energy) external;

    function setCooldown(uint256 _tokenId) external;

    function setStatus(uint256 _tokenId, uint256 _status) external;

    function getMonsterExp(uint256 _tokenId) external view returns (uint256);

    function getMonsterLevel(uint256 _tokenId) external view returns (uint256);

    function getMonsterExpCap(uint256 _tokenId) external view returns (uint256);

    function getMonsterEnergy(uint256 _tokenId) external view returns (uint256);

    function getMonsterCooldown(uint256 _tokenId)
        external
        view
        returns (uint256);

    function getMonsterStatus(uint256 _tokenId) external view returns (uint256);

    function ownerOf(uint256 _monster) external view returns (address _owner);
}
