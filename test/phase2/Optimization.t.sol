// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Optimization} from "../../src/phase2/Optimization.sol";

contract OptimizationTest is Test {
    Optimization public opt;
    address public user = address(0x123);

    function setUp() public {
        opt = new Optimization();
        vm.deal(address(opt), 10 ether); // 给合约充钱
    }

    // 测试未优化的写入
    function testBadLayout() public {
        opt.setBad(1, 100, 2); // 假设我们在合约里加了这个 setter (见下方说明)
    }

    // 测试优化后的写入
    // 理论上这个应该比上面的便宜，因为少了一次 SSTORE
    function testGoodLayout() public {
        opt.setGood(1, 2, 100);
    }

    // 测试发送 ETH + Event
    function testSendEth() public {
        // 1. 监听事件 (告诉 Foundry 下一步操作应该触发这个 Event)
        // checkTopic1 (index 1), checkTopic2... checkData
        vm.expectEmit(true, false, false, true);
        // 我们预期的事件内容：
        emit Optimization.PaymentSent(user, 1 ether);

        // 2. 执行操作
        opt.sendEth(user, 1 ether);

        // 3. 验证余额
        assertEq(user.balance, 1 ether);
    }
}