// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ManualToken} from "../../src/phase3/ManualToken.sol";

contract Handler is Test {
    ManualToken public token;
    address public user1;
    address public user2;

    constructor(ManualToken _token, address _u1, address _u2) {
        token = _token;
        user1 = _u1;
        user2 = _u2;
    }

    // 1. 这是一个“包装”过的转账函数
    // Foundry 会随机调用这个函数，传入随机的 amountIndex 和 amount
    function transfer(uint256 amountIndex, uint256 amount) public {
        // [核心逻辑] 限制随机性！
        
        // 随机选择发送者 (user1 或 user2)
        // amountIndex % 2 结果只能是 0 或 1
        address sender = amountIndex % 2 == 0 ? user1 : user2;
        address recipient = amountIndex % 2 == 0 ? user2 : user1;

        // 限制金额：不能超过由于 sender 的余额
        // bound(随机数, 最小值, 最大值)
        amount = bound(amount, 0, token.balanceOf(sender));

        // 执行转账
        vm.prank(sender);
        token.transfer(recipient, amount);
    }
}