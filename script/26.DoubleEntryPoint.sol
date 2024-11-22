// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import "../src/26.DoubleEntryPoint.sol";

contract DoubleEntryPointScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        DoubleEntryPoint target = DoubleEntryPoint(0x3192Cc8BC30bd4F6e0D99DCa4659b5C3c1732E2B);

        Forta forta = target.forta();

        FakeDetectionBot fakeDetectionBot = new FakeDetectionBot(address(forta));

        forta.setDetectionBot(address(fakeDetectionBot));

        vm.stopBroadcast();
    }
}
