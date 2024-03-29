// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

interface IItems {
    function missionsReward(
        uint256 _mission,
        uint256 _monster,
        address _user,
        uint256 _odds
    ) external;

    function bossFightReward(
        uint256 _monster,
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
}
