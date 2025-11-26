// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Optimization {
    // ----------------------------------------------------
    // 1. Storage Packing (存储打包)
    // ----------------------------------------------------
    
    // [Bad Layout] 
    // 这里的 c 夹在 a 和 b 中间，阻断了打包
    // 消耗: 3 个 Slots
    uint128 public bad_a;
    uint256 public bad_b; 
    uint128 public bad_c;

    // [Good Layout]
    // 调整顺序，让两个小的挨在一起
    // 消耗: 2 个 Slots (a 和 c 会挤在 Slot 0, b 在 Slot 1)
    uint128 public good_a;
    uint128 public good_c; // <--- 移到这里
    uint256 public good_b;

    // ----------------------------------------------------
    // 2. Events (事件)
    // ----------------------------------------------------
    
    // 定义事件：当 ETH 发送成功时触发
    // indexed 允许前端通过 `to` 地址快速过滤日志
    event PaymentSent(address indexed to, uint256 amount);

    // ----------------------------------------------------
    // 3. Low-level Call (发送 ETH)
    // ----------------------------------------------------
    
    // 让合约可以接收 ETH (必须有 receive 或 fallback)
    receive() external payable {}

    // 这是一个非常危险但也非常强大的功能
    function sendEth(address _to, uint256 _amount) public {
        // 检查合约里钱够不够
        if (address(this).balance < _amount) {
            revert("Not enough ETH");
        }

        // [核心代码] 掌握这一行！
        // 1. _to.call: 对目标地址发起底层调用
        // 2. {value: _amount}: 附带发送 ETH
        // 3. (""): 发送空数据 (Payload)，仅仅转账
        // 4. 返回值: (bool success, bytes memory data)
        (bool success, ) = _to.call{value: _amount}("");

        // 必须检查 success，因为底层调用失败不会自动 Revert
        if (!success) {
            revert("ETH transfer failed");
        }

        // 触发事件 (就像 console.log，但是是给链下看的)
        emit PaymentSent(_to, _amount);
    }

    function setBad(uint128 _a, uint256 _b, uint128 _c) public {
        bad_a = _a;
        bad_b = _b;
        bad_c = _c;
    }

    function setGood(uint128 _a, uint128 _c, uint256 _b) public {
        good_a = _a;
        good_c = _c;
        good_b = _b;
    }
}