// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract TodoList {
    // 1. 定义结构体
    struct Task {
        string name;     // 任务名称
        bool isCompleted; // 是否完成
    }

    // 2. 任务列表 (动态数组)
    Task[] public tasks;

    // 创建任务
    function createTask(string memory _name) public {
        tasks.push(Task(_name, false));
    }

    // ✅ 正确写法: 使用 storage 指针
    // 修改会直接同步到区块链状态
    function updateStatusCorrect(uint256 _index) public {
        Task storage todo = tasks[_index]; 
        todo.isCompleted = !todo.isCompleted; // 取反
    }

    // ❌ 错误写法: 使用 memory 副本
    // 这只是把数据拷贝到了内存，修改内存不会影响 storage
    function updateStatusWrong(uint256 _index) public view {
        Task memory todo = tasks[_index]; 
        todo.isCompleted = !todo.isCompleted; // 取反
        // 函数结束，todo 变量销毁，区块链状态没变，Gas 白花了
    }

    // 获取任务详情 (辅助函数)
    function getTask(uint256 _index) public view returns (string memory, bool) {
        Task storage todo = tasks[_index];
        return (todo.name, todo.isCompleted);
    }
}