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

    event Registered(address _user, bytes32 _name);
    error isRegistered();

    modifier isNotRegistered(address _user) {
        bool status = registrationStatus[_user];
        if (status) {
            revert isRegistered();
        }
        _;
    }

    function register(bytes32 _name, bytes32 _profile)
        external
        isNotRegistered(msg.sender)
    {
        userDataDetails[msg.sender] = Details(msg.sender, _profile, _name);
        registrationStatus[msg.sender] = true;
        emit Registered(msg.sender, _name);
    }

    function checkRegister(address _user) external view returns (bool result) {
        bool status = registrationStatus[_user];
        if (status != false) {
            result = true;
        }
    }
}
