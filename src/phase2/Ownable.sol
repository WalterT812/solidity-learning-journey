// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Ownable {
    address public owner;

    // 自定义错误（省 Gas）
    error NotOwner(address caller);

    // 构造函数：部署时自动运行一次
    constructor() {
        // 谁部署合约，谁就是 owner
        owner = msg.sender;
    }

    // [核心] Modifier (修饰符)
    // 它可以像“装饰器”一样套在其他函数外面
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner(msg.sender);
        }
        _; // <--- 这里的下划线代表“被修饰的函数体”会插在这里执行
    }

    // 移交权限
    function transferOwnership(address _newOwner) public onlyOwner {
        // 只有现任 owner 能调用
        owner = _newOwner;
    }
}