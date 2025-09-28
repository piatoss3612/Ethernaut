// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {EllipticToken} from "src/35.EllipticCoin.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract EllipticCoinScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address playerAddr = msg.sender;
        address instanceAddr = 0x7255b532427cB72259B0BE3edc932ab4A49b0853;
        address aliceAddr = 0xA11CE84AcB91Ac59B0A4E2945C9157eF3Ab17D4e;

        EllipticToken ellipticToken = EllipticToken(instanceAddr);

        uint256 aliceBalance = ellipticToken.balanceOf(aliceAddr);
        uint256 decimals = ellipticToken.decimals();

        console.log("Alice Balance:", aliceBalance / (10 ** decimals));

        uint256 amount = uint256(
            0xd1bc88e43bfd26e57f5585849f856be28ab6e33b918f38c4d44589c4da2c6f3e
        );

        bytes
            memory tokenOwnerSignature = hex"db4e49f74fa7ad845725786bdc8e7c4007739f728c82bb20bcf3fe60097eb14859ce37062271a2156650a0370646e6468ea916b5744c2ada4f5d7ad75638d0eb1c";

        bytes32 permitHash = keccak256(
            abi.encodePacked(aliceAddr, playerAddr, amount)
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(playerAddr, permitHash); // sign the permit hash with spender

        bytes memory spenderSignature = abi.encodePacked(r, s, v);

        ellipticToken.permit(
            amount,
            playerAddr,
            tokenOwnerSignature,
            spenderSignature
        );
        ellipticToken.transferFrom(aliceAddr, playerAddr, aliceBalance);

        uint256 playerBalance = ellipticToken.balanceOf(playerAddr);

        console.log("Player Balance after transfer:", playerBalance);

        vm.stopBroadcast();
    }
}
