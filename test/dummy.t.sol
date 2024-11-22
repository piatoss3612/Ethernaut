// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";

contract DummyTest is Test {
    function setUp() public {}

    function test_Addition() public {
        uint256 a = 1;
        uint256 b = 2;
        uint256 c = a + b;
        assertEq(c, 3);
    }
}
