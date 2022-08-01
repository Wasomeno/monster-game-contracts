// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./IMonsterToken.sol";

contract Smelter is ERC1155Holder {
    struct Smelt {
        uint256 quantity;
        uint256 startTime;
    }

    IERC1155 itemInterface;
    IMonsterToken tokenInterface;

    mapping(address => Smelt) public smeltDetails;

    function setInterface(address _itemNFT, address _monsterToken) public {
        itemInterface = IERC1155(_itemNFT);
        tokenInterface = IMonsterToken(_monsterToken);
    }

    function smelt(address _user, uint256 _quantity) public {
        require(
            itemInterface.balanceOf(_user, 4) > 0,
            "You don't have a any crystal to be smelt"
        );
        itemInterface.safeTransferFrom(_user, address(this), 4, _quantity, "");
        smeltDetails[_user] = Smelt(_quantity, block.timestamp);
    }

    function claimSmelt(address _user) public {
        (uint256 quantity, uint256 start) = (
            smeltDetails[_user].quantity,
            smeltDetails[_user].startTime
        );
        uint256 time = start + (quantity * 15 minutes);
        uint256 reward = quantity * 4;

        require(time < block.timestamp, "Your crystal stil being smelted");
        tokenInterface.mint(_user, reward);
    }
}
