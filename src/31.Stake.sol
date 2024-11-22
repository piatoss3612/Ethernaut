// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Stake {
    uint256 public totalStaked;
    mapping(address => uint256) public UserStake;
    mapping(address => bool) public Stakers;
    address public WETH;

    constructor(address _weth) payable {
        totalStaked += msg.value;
        WETH = _weth;
    }

    function StakeETH() public payable {
        require(msg.value > 0.001 ether, "Don't be cheap");
        totalStaked += msg.value;
        UserStake[msg.sender] += msg.value;
        Stakers[msg.sender] = true;
    }

    function StakeWETH(uint256 amount) public returns (bool) {
        require(amount > 0.001 ether, "Don't be cheap");
        (, bytes memory allowance) = WETH.call(abi.encodeWithSelector(0xdd62ed3e, msg.sender, address(this)));
        require(bytesToUint(allowance) >= amount, "How am I moving the funds honey?");
        totalStaked += amount;
        UserStake[msg.sender] += amount;
        (bool transfered,) = WETH.call(abi.encodeWithSelector(0x23b872dd, msg.sender, address(this), amount));
        Stakers[msg.sender] = true;

        // Vulnerability: Do not check the result of low-level call!

        return transfered;
    }

    function Unstake(uint256 amount) public returns (bool) {
        require(UserStake[msg.sender] >= amount, "Don't be greedy");
        UserStake[msg.sender] -= amount;
        totalStaked -= amount;
        (bool success,) = payable(msg.sender).call{value: amount}("");

        // Vulnerability: Do not check the result of low-level call!

        return success;
    }

    function bytesToUint(bytes memory data) internal pure returns (uint256) {
        require(data.length >= 32, "Data length must be at least 32 bytes");
        uint256 result;
        assembly {
            result := mload(add(data, 0x20))
        }
        return result;
    }
}

contract DummyStaker {
    Stake public stakeContract;

    constructor(address _stakeContract) {
        stakeContract = Stake(_stakeContract);
    }

    function stakeETH() external payable {
        uint256 amount = (0.001 ether + 1) + 1;
        if (msg.value != amount) revert();
        stakeContract.StakeETH{value: amount}();
    }
}
