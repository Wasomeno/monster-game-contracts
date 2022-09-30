// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

contract UsersData {
    struct Details {
        address user;
        bytes32 profile_image;
        bytes32 name;
    }

    address[] public users;
    mapping(address => Details) public userDataDetails;
    mapping(address => bool) public registrationStatus;

    event Registered(bytes32 _name);
    error isRegistered(bool _status);
    error NotRegistered(bool _status);

    modifier isNotRegistered() {
        bool status = registrationStatus[msg.sender];
        if (status) {
            revert isRegistered(status);
        }
        _;
    }

    function register(bytes32 _name, bytes32 _profile)
        external
        isNotRegistered
    {
        userDataDetails[msg.sender] = Details(msg.sender, _profile, _name);
        registrationStatus[msg.sender] = true;
        emit Registered(_name);
    }

    function checkRegister(address _user) external view {
        bool status = registrationStatus[_user];
        if (!status || _user == address(0)) {
            revert NotRegistered(status);
        }
    }
}
