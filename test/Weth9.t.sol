// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.19;

import "forge-std/Test.sol";
import "../src/Weth9.sol";

contract TestWeth9 is Test {
    Weth9 public weth9;
    address public owner;

    uint256 public constant AMOUNT = 1 ether;
    uint256 public constant DEPOSIT_AMOUNT = 10 ether;
    uint256 public constant WITHDRAW_AMOUNT = 5 ether;
    uint256 public constant SUB_AMOUNT = DEPOSIT_AMOUNT - WITHDRAW_AMOUNT;

    event Deposit(address indexed _sender, uint256 _amount);
    event Withdraw(address indexed _owner, uint256 _amount);

    receive() external payable {}

    function setUp() public {
        weth9 = new Weth9("Weth9","WETH");
        owner = address(this);
    }

    function test_Name() public {
        assertEq(weth9.name(),"Weth9");
    }

    // | 1 | deposit 應該將與 msg.value 相等的 ERC20 token mint 給 user |
    // | 2 | deposit 應該將 msg.value 的 ether 轉入合約 |
    function test_Deposit() public {
        weth9.deposit{value:AMOUNT}();
        assertEq(address(weth9).balance,AMOUNT,"Weth9 doesn't have 1 Ether");
        assertEq(weth9.balanceOf(owner),AMOUNT,"Token balance is not equal to 1 Ether");
    }

    // | 3 | deposit 應該要 emit Deposit event |
    function test_Deposit_Event() public {
        vm.expectEmit();
        emit Deposit(owner, AMOUNT);
        weth9.deposit{value:AMOUNT}();
    }

    function test_Cannot_Deposit_0() public {
        vm.expectRevert("Can not deposit less than 0");
        weth9.deposit{value:0}();
    }

    // | 4 | withdraw 應該要 burn 掉與 input parameters 一樣的 erc20 token |
    // | 5 | withdraw 應該將 burn 掉的 erc20 換成 ether 轉給 user |
    function test_Withdraw() public {
        weth9.deposit{value: DEPOSIT_AMOUNT}();
        uint balanceBeforeWithdraw = weth9.balanceOf(owner);
        uint weth9EtherBeforeWithdraw = address(weth9).balance;
        uint totalSupplyBeforeWithdraw = weth9.totalSupply();

        weth9.withdraw(WITHDRAW_AMOUNT);
        uint balanceAfterWithdraw = weth9.balanceOf(owner);
        uint weth9EtherAfterWithdraw = address(weth9).balance;
        uint totalSupplyAfterWithdraw = weth9.totalSupply();

        bool checkAllBalances = 
            balanceBeforeWithdraw - balanceAfterWithdraw == SUB_AMOUNT && 
            weth9EtherBeforeWithdraw - weth9EtherAfterWithdraw == SUB_AMOUNT && 
            totalSupplyBeforeWithdraw - totalSupplyAfterWithdraw == SUB_AMOUNT;
        assertTrue(checkAllBalances);
    }
    
    // | 6 | withdraw 應該要 emit Withdraw event |
    function test_Withdraw_Event() public {
        weth9.deposit{value: DEPOSIT_AMOUNT}();
        vm.expectEmit();
        emit Withdraw(owner, WITHDRAW_AMOUNT);
        weth9.withdraw(WITHDRAW_AMOUNT);
    }
    // | 7 | transfer 應該要將 erc20 token 轉給別人 |
    function test_Transfer() public {
        weth9.deposit{value:AMOUNT}();
        address user = vm.addr(2);

        weth9.transfer(user, AMOUNT);
        assertEq(weth9.balanceOf(user),AMOUNT);   
    }
    // | 8 | approve 應該要給他人 allowance |
    function test_Approve() public {
        weth9.deposit{value:AMOUNT}();
        address user = vm.addr(2);
        bool success = weth9.approve(user, AMOUNT);
        
        assertTrue(success);
        assertEq(weth9.allowance(owner, user),AMOUNT); 
    }

    // | 9 | transferFrom 應該要可以使用他人的 allowance |
    // | 10 | transferFrom 後應該要減除用完的 allowance |
    function test_TransferFrom() public {
        address user = vm.addr(2);
        weth9.deposit{value:AMOUNT}();
  
        weth9.approve(owner, AMOUNT);

        weth9.transferFrom(owner, user, AMOUNT);

        assertEq(weth9.balanceOf(user),AMOUNT);
        assertEq(weth9.allowance(owner, user),0);
    }
}