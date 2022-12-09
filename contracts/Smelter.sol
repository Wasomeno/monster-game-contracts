// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IMonsterToken.sol";
import "./IUsersData.sol";

contract Smelter is ERC1155Holder, Ownable {
    struct Details {
        uint16 quantity;
        uint64 startTime;
    }

    IERC1155 public itemInterface;
    IMonsterToken public tokenInterface;
    IUsersData public usersDataInterface;

    mapping(address => Details) public smeltDetails;
    mapping(address => bool) public smeltingStatus;

    event Smelt(uint256 _quantity, uint256 _startTime);

    error NotSmelting(bool _status);
    error IsSmelting(bool _status);
    error NotValidToSmelt(uint256 _balance, uint256 _quantity);
    error NotValidToFinishSmelt(uint256 _elapsedTime);

    modifier isSmelting() {
        bool status = smeltingStatus[msg.sender];
        if (status) {
            revert NotSmelting(status);
        }
        _;
    }

    modifier isNotSmelting() {
        bool status = smeltingStatus[msg.sender];
        if (!status) {
            revert IsSmelting(status);
        }
        _;
    }

    modifier isRegistered() {
        usersDataInterface.checkRegister(msg.sender);
        _;
    }

    function setInterface(
        address _itemsContract,
        address _monsterTokenContract,
        address _usersDataContract
    ) external onlyOwner {
        itemInterface = IERC1155(_itemsContract);
        tokenInterface = IMonsterToken(_monsterTokenContract);
        usersDataInterface = IUsersData(_usersDataContract);
    }

    function smelt(uint256 _quantity) external isNotSmelting isRegistered {
        uint256 crystalBalance = itemInterface.balanceOf(msg.sender, 4);
        if (crystalBalance == 0 || _quantity > 100) {
            revert NotValidToSmelt(crystalBalance, _quantity);
        }
        itemInterface.safeTransferFrom(
            msg.sender,
            address(this),
            4,
            _quantity,
            ""
        );
        smeltDetails[msg.sender] = Details(
            uint16(_quantity),
            uint64(block.timestamp)
        );
        smeltingStatus[msg.sender] = true;
        emit Smelt(_quantity, block.timestamp);
    }

    function finishSmelting() external isSmelting {
        uint256 quantity = smeltDetails[msg.sender].quantity;
        uint256 startTime = smeltDetails[msg.sender].startTime;
        uint256 time = start + (quantity * 15 minutes);
        uint256 reward = quantity * 5;
        if (time > block.timestamp) {
            revert NotValidToFinishSmelt(time);
        }
        tokenInterface.mint(msg.sender, reward);
    }
}
