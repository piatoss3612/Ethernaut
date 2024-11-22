// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Privacy {
    bool public locked = true;
    uint256 public ID = block.timestamp;
    uint8 private flattening = 10;
    uint8 private denomination = 255;
    uint16 private awkwardness = uint16(block.timestamp);
    bytes32[3] private data;

    constructor(bytes32[3] memory _data) {
        data = _data;
    }

    function unlock(bytes16 _key) public {
        require(_key == bytes16(data[2]));
        locked = false;
    }
}

// bytes16(0xc287b24d78ce66166c05636079ae1c7871b805a6100c6cb5f1f2194579554681) =
// 0xc287b24d78ce66166c05636079ae1c78 (뒷부분이 잘려나간다)
