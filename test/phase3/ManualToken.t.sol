// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ManualToken} from "../../src/phase3/ManualToken.sol";

contract ManualTokenTest is Test {
    ManualToken public token;

    // 定义三个角色
    address public alice = address(0x1); // 用户
    address public bob   = address(0x2); // 模拟 Uniswap / Spender
    address public charlie = address(0x3); // 接收者

    function setUp() public {
        // 部署代币，初始供应量 1000 个
        token = new ManualToken(1000);

        // [修复]：把 100 改成 1000
        // 既然我们在 testAllowances 里假设 initialAllowance 是 1000
        // 那我们就给 Alice 1000 个币，这样她就有足够的钱被转走了
        token.transfer(alice, 1000 ether); 
    }

    // 测试核心流程：Approve + TransferFrom
    function testAllowances() public {
        uint256 initialAllowance = 1000 * 1e18; // 1000 tokens

        // Step 1: Alice 授权给 Bob
        // 切换身份为 Alice
        vm.prank(alice); 
        token.approve(bob, initialAllowance);

        // 验证：Bob 现在有权动用 Alice 的钱吗？
        uint256 allowance = token.allowance(alice, bob);
        assertEq(allowance, initialAllowance);

        // Step 2: Bob 调用 transferFrom 把钱转给 Charlie
        // 切换身份为 Bob (Uniswap)
        vm.prank(bob);
        
        // Bob 说：“把 Alice 的 500 个币转给 Charlie”
        // transferFrom(from, to, amount)
        token.transferFrom(alice, charlie, 500 * 1e18);

        // Step 3: 验证结果
        // 在 testAllowances 函数底部
        // Alice 原有 1000，转走 500，剩 500。
        // 这是一个正整数，编译器开心了，逻辑也通了。
        assertEq(token.balanceOf(alice), 1000 ether - 500 * 1e18);
        // 3.2 Charlie 多了 500
        assertEq(token.balanceOf(charlie), 500 * 1e18);
        
        // 3.3 [关键] Bob 的剩余额度应该减少
        assertEq(token.allowance(alice, bob), initialAllowance - 500 * 1e18);
    }
}