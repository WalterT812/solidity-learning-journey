// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {TodoList} from "../src/TodoList.sol";

contract TodoListTest is Test {
    TodoList public list;

    function setUp() public {
        list = new TodoList();
        // 初始化一个任务: Index 0
        list.createTask("Learn Solidity");
    }

    // 测试 1: 验证正确写法 (Storage)
    function testCorrectUpdate() public {
        // 1. 调用正确的更新函数
        list.updateStatusCorrect(0);

        // 2. 检查状态：应该是 true (已完成)
        (, bool isCompleted) = list.getTask(0);
        assertEq(isCompleted, true);
    }

    // 测试 2: 验证错误写法 (Memory) —— 处刑时刻！
    function testWrongUpdate() public view {
        // 1. 调用错误的更新函数
        list.updateStatusWrong(0);

        // 2. 检查状态
        // 关键点：因为是 memory 操作，链上状态应该还是 false (未完成)！
        (, bool isCompleted) = list.getTask(0);
        
        // 如果这里我写 assertEq(isCompleted, true)，测试就会挂掉
        // 所以我断言它仍然是 false，以此证明那个函数是无效的
        assertEq(isCompleted, false);
    }
}