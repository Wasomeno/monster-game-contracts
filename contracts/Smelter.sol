// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./IMonsterToken.sol";


contract Smelter is ERC1155Receiver{
    struct Smelt {
        uint quantity;
        uint startTime;
    }

    IERC1155 itemInterface;
    IMonsterToken tokenInterface;

    mapping(address => Smelt) public smeltDetails;

    function setInterface(address _itemNFT, address _monsterToken) public {
        itemInterface = IERC1155(_itemNFT);
        tokenInterface = IMonsterToken(_monsterToken);
    }

    function smelt(address _user, uint _quantity) public{
        require(itemInterface.balanceOf(_user, 4) > 0,"You don't have a any crystal to be smelt");
        itemInterface.safeTransferFrom(_user, address (this), 4, _quantity, "");

        smeltDetails[_user] = Smelt(_quantity, block.timestamp);
    }

    function claimSmelt(address _user) public {
        (uint quantity, uint start) = (smeltDetails[_user].quantity, smeltDetails[_user].startTime);
        uint time = start + (quantity * 15 minutes);
        uint reward = quantity * 4;

        require(time < block.timestamp, "Your crystal stil being smelted");
        tokenInterface.mint(_user, reward);
    }

    function onERC1155BatchReceived(
    address _operator,
    address _from,
    uint256[] calldata _ids,
    uint256[] calldata _values,
    bytes calldata _data
    ) external pure override returns(bytes4) {
        bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
    }

    function onERC1155Received (
    address _operator,
    address _from,
    uint256 _id,
    uint256 _value,
    bytes calldata _data
    ) external pure override returns(bytes4) {
        bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }
}