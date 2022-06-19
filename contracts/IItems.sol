// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./Items.sol";

interface IItems {
    function beginnerMissionReward(address _user, uint _odds) external;
    function intermediateMissionReward(address _user, uint _odds) external;
    function bossFightReward(address _user, uint _odds, uint _chance) external;
    function mintForShop(address _user, uint _id, uint _quantity) external;
}