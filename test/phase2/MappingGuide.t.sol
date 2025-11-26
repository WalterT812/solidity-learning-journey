// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {MappingGuide} from "../../src/phase2/MappingGuide.sol";

contract MappingTest is Test {
    MappingGuide public bank;
    address public user1 = address(0x1);
    address public user2 = address(0x2);

    function setUp() public {
        bank = new MappingGuide();
        
        // [关键修复] 给 user1 和 user2 发钱！
        // vm.deal(who, amount): 设置某个地址的 ETH 余额
        vm.deal(user1, 10 ether); 
        vm.deal(user2, 10 ether);
    }

    function testDepositAndTransfer() public {
        vm.startPrank(user1);
        
        // 现在 user1 有钱了，这行代码就能跑通了
        bank.deposit{value: 100}();
        assertEq(bank.balances(user1), 100);

        bank.transfer(user2, 50);
        
        assertEq(bank.balances(user1), 50);
        assertEq(bank.balances(user2), 50);
        
        vm.stopPrank();
    }

    function testTransferNotEnough() public {
        vm.startPrank(user1);
        
        // 存 10 wei
        bank.deposit{value: 10}(); 

        // 预期 revert
        vm.expectRevert(
            abi.encodeWithSelector(
                MappingGuide.InsufficientBalance.selector, 
                10, 
                100 
            )
        );

        // 转 100 wei (余额不足)
        bank.transfer(user2, 100); 
        
        vm.stopPrank();
    }
}