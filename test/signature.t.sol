// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/Script.sol";

contract SignatureMalleabilityTest is Test {
    bytes32 msgHash =
        0xf413212ad6f041d7bf56f97eb34b619bf39a937e1c2647ba2d306351c6d34aae;
    bytes32 n =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;
    uint8 v = 0x1b; // 27
    bytes32 r =
        0x1932cb842d3e27f54f79f7be0289437381ba2410fdefbae36850bee9c41e3b91;
    bytes32 s =
        0x78489c64a0db16c40ef986beccc8f069ad5041e5b992d76fe76bba057d9abff2;

    function setUp() public {}

    function test_SubtractS() public {
        address originalAddr = ecrecover(msgHash, v, r, s);

        uint8 newV = 27 + (1 - (v - 27));
        bytes32 newS = bytes32(uint256(n) - uint256(s));

        address newAddr = ecrecover(msgHash, newV, r, newS);

        assertEq(originalAddr, newAddr);
    }
}
