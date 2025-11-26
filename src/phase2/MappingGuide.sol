// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MappingGuide {
    mapping(address => uint256) public balances;

    // 1. 定义一个自定义错误 (Gas 优化大师)
    // 看起来像 Event，但它是用来报错的
    error InsufficientBalance(uint256 available, uint256 required);

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function transfer(address _to, uint256 _amount) public {
        // 2. 显式检查余额
        // 如果余额 < 转账金额，这就叫“前置条件检查”
        if (balances[msg.sender] < _amount) {
            // Revert 并抛出自定义错误，告诉前端：你有多少，你需要多少
            revert InsufficientBalance(balances[msg.sender], _amount);
        }

        // 3. 只有检查通过，才执行扣款 (Checks-Effects-Interactions 模式)
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
    }
}