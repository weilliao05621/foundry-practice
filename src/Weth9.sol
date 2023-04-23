// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

interface IWETH9 {
    function deposit() external payable;
    function withdraw(uint256 _amount) external;

    event Deposit(address indexed _sender, uint256 _amount);
    event Withdraw(address indexed _owner, uint256 _amount);
}

contract Weth9 is ERC20,IWETH9 { 
    constructor(string memory _name,string memory _symbol) ERC20(_name,_symbol){}

    function deposit() external payable {
        uint amount =  msg.value;
        require(amount > 0,"Can not deposit less than 0");
        address sender = _msgSender();
        _mint(sender, amount);
        emit Deposit(sender, amount);
    }

    function withdraw(uint256 amount) external {
        address sender = _msgSender();
        _burn(sender, amount);
        payable(sender).transfer(amount);
        emit Withdraw(sender,amount);
    }
}