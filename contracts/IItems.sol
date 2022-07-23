// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./Items.sol";

interface IItems {
    function beginnerMissionReward(address _user, uint256 _odds) external;

    function intermediateMissionReward(address _user, uint256 _odds) external;

    function bossFightReward(
        address _user,
        uint256 _odds,
        uint256 _chance
    ) external;

    function mintForShop(
        address _user,
        uint256[] calldata _id,
        uint256[] calldata _quantity
    ) external;

    function mintForTrade(
        address _user,
        uint256 _id,
        uint256 _quantity
    ) external;

    function getInventory(address _user)
        external
        view
        returns (uint256[] memory inventory);
}
