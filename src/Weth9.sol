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
    2. 透過 ERC-20 的介面學習到可以使用 Context 去包起來常用的 global value，像是 ERC-20 有繼承 _msgSender() 能拿到 msg.sender
*/ 

contract Weth9 is ERC20("Wrapped Ether", "WETH"),IWETH9 {
    
    mapping(address => uint) _balancesOf;

    function deposit() external payable {
        uint value = msg.value;
        require(value > 0, "Deposit amount must be greater than 0");
        address owner = _msgSender();
        // mint 出等值 Ether 數量的 Weth 給 owner
        _mint(owner, value);
        emit Deposit(owner, value);
    }

    function withdraw(uint256 _amount) external {
    require(_amount > 0, "Withdraw amount must be greater than 0");
        address owner = _msgSender();
        require(_balancesOf[owner] >= _amount, "Insufficient balance");
        // 同理，直接燒掉等值 Ether 數量的 Weth，並修改 owner 的餘額
        _burn(owner, _amount);
        payable(owner).transfer(_amount);
        emit Withdraw(owner, _amount);
    }
}