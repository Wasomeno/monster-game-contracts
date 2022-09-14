// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./IMonsterToken.sol";

contract Smelter is ERC1155Holder {
    struct Details {
        uint256 quantity;
        uint256 startTime;
    }

    IERC1155 itemInterface;
    IMonsterToken tokenInterface;

    mapping(address => Details) public smeltDetails;
    mapping(address => bool) public smeltingStatus;

    event Smelt(uint256 _quantity, uint256 _startTime);

    modifier isSmelting(address _user) {
        bool status = smeltingStatus[_user];
        require(status, "You're not smelting any crystals");
        _;
    }

    modifier isNotSmelting(address _user) {
        bool status = smeltingStatus[_user];
        require(!status, "You're still smelting");
        _;
    }

    function setInterface(address _itemNFT, address _monsterToken) public {
        itemInterface = IERC1155(_itemNFT);
        tokenInterface = IMonsterToken(_monsterToken);
    }

    function smelt(address _user, uint256 _quantity)
        external
        isNotSmelting(_user)
    {
        uint256 crystalBalance = itemInterface.balanceOf(_user, 4);
        require(crystalBalance > 0, "You don't have a any crystal to be smelt");
        require(_quantity >= 100, "Max quantity exceed");
        itemInterface.safeTransferFrom(_user, address(this), 4, _quantity, "");
        smeltDetails[_user] = Details(_quantity, block.timestamp);
        emit Smelt(_quantity, block.timestamp);
    }

    function finishSmelting(address _user) external isSmelting(_user) {
        (uint256 quantity, uint256 start) = (
            smeltDetails[_user].quantity,
            smeltDetails[_user].startTime
        );
        uint256 time = start + (quantity * 15 minutes);
        uint256 reward = quantity * 5;

        require(time < block.timestamp, "Your crystal stil being smelted");
        tokenInterface.mint(_user, reward);
    }
}
