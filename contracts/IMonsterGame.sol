// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./MyMonsterGame.sol";

interface IMonsterGame {

    function checkItemOnInventory(uint[] calldata _item, uint[] calldata _quantity, address _user) external;
    function checkSingleItemOnInventory(uint _item, uint _quantity, address _user) external;
}