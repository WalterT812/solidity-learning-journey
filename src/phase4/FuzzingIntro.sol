// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract FuzzingIntro {
    // 这是一个简单的测试函数
    // 目标：只要输入的数据不是 12345，就应该返回 true
    // 现实中，这可能是一个复杂的数学公式或权限检查
    function doSomething(uint256 _input) public pure returns (bool) {
        // 假设这里有一行极其隐蔽的 Bug 逻辑
        if (_input == 12345) {
            return false; // Bug 触发！
        }
        return true;
    }

    // 另一个例子：溢出测试 (虽然 0.8 有检查，但逻辑溢出依然存在)
    // 假设我们不想让 result 超过 255
    function safeAdd(uint8 a, uint8 b) public pure returns (uint8) {
        return a + b;
    }
}