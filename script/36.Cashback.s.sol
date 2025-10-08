// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {Cashback} from "src/36.Cashback.sol";

contract CashbackScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address playerAddr = msg.sender;
        address instanceAddr = 0xc6925e10e9FE434629679b8BD7f5f29efEeA7E3f;

        vm.stopBroadcast();
    }
}
