pragma solidity ^0.4.18;

contract Play {

    struct User{
        uint256 startTime;
        uint256 duration;
    }

    mapping(address => User) public ledger;

    
}
