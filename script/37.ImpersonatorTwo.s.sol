// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {ImpersonatorTwo} from "src/37.ImpersonatorTwo.sol";

contract ImpersonatorTwoScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address playerAddr = msg.sender;
        address instanceAddr = 0x851baA4d1F401fdBB2B8a636E8304122a0caeB48;

        ImpersonatorTwo impersonatorTwo = ImpersonatorTwo(instanceAddr);

        address owner = impersonatorTwo.owner();
        console.log("Owner:", owner);

        address admin = impersonatorTwo.admin();
        console.log("Admin:", admin);

        uint256 nonce = impersonatorTwo.nonce();
        console.log("Nonce:", nonce);

        vm.stopBroadcast();
    }
}
