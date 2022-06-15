// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./MonsterToken.sol";

interface IMonsterToken {
    function mint(address _to, uint _quantity) external;
}