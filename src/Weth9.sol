// SPDX-License-Identifier: MIT

pragma solidity =0.8.19;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

interface IWETH9 {
    function deposit() external payable;
    function withdraw(uint256 _amount) external;

    event Deposit(address _from, uint256 _amount);
    event Withdraw(address _from, uint256 _amount);
}

/*
    1. 因為是延續 ERC-20 的操作，透過 mint 和 burn 來直接操作內部的值
*/ 

abstract contract Weth9 is ERC20("Wrapped Ether", "WETH"),IWETH9 {
    
    mapping(address => uint) _balancesOf;

    function deposit() external payable {
        uint value = msg.value;
        require(value > 0, "Deposit amount must be greater than 0");
        address sender = msg.sender;
        // mint 出等值 Ether 數量的 Weth 給 sender
        _mint(sender, value);
        emit Deposit(sender, value);
    }

    function withdraw(uint256 _amount) external {
    require(_amount > 0, "Withdraw amount must be greater than 0");
        address sender = msg.sender;
        require(_balancesOf[sender] >= _amount, "Insufficient balance");
        // 同理，直接燒掉等值 Ether 數量的 Weth，並修改 sender 的餘額
        _burn(sender, _amount);
        payable(sender).transfer(_amount);
        emit Withdraw(sender, _amount);
    }
}