// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
contract clicker {
    struct User {
        uint256 balance;
        uint256 clicks;
        uint256 clickMiltiplier;
        uint256 withdrawableAmount;
        uint256 lastClickTime;
        string name;
        bool registered;
    }
    address public admin;
    mapping(address => User) public users;

    modifier onlyReg() {
        require(users[msg.sender].registered, "user not reg");
        _;
    }
    modifier cooldownCheck() {
        require(block.timestamp >= users[msg.sender].lastClickTime + 10, "CD not ended");
        _;
    }
    mapping(address => address) public ref;
    uint public tClicks;
    uint public tUsers;
    constructor() {
        admin = msg.sender;
    }

    function registerUser(string memory name, address ref) public onlyReg{
        require(users[msg.sender].registered, "user already reg");
        users[msg.sender] = User({
            name: name,
            balance: 0,
            clicks: 0,
            clickMiltiplier: 1,
            withdrawableAmount: 0,
            lastClickTime: block.timestamp,
            registered: true
        });
        tUsers++;
        if (ref == address(0) && users[ref].registered) {
            users[ref].balance += 500;
        }

    }
    function click() public onlyReg cooldownCheck {
        User storage user = users[msg.sender];
        user.clicks++;
        user.balance += user.lastClickTime;
        user.withdrawableAmount++;
        if (block.timestamp < user.lastClickTime + 10) {
            user.balance += user.clickMiltiplier;
        }
        user.lastClickTime = block.timestamp;
    }
    function tranfer(address recipient, uint256 Amount) public onlyReg {
    User storage sender = users[msg.sender];
    require(sender.balance >= Amount, "true balance");
    if (users[recipient].registered) {
        users[recipient].balance += Amount;
        ref[recipient] = msg.sender;
    }
    else {
        users[recipient].balance += Amount;
    }
    sender.balance -= Amount;
    }
}