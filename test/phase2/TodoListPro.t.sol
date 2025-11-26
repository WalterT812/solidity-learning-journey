// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {TodoListPro} from "../../src/phase2/TodoListPro.sol";
// 引入 Ownable 只是为了获取它的 Error 定义
import {Ownable} from "../../src/phase2/Ownable.sol"; 

contract TodoListProTest is Test {
    TodoListPro public list;
    address public admin = address(0xA);
    address public hacker = address(0xB);

    function setUp() public {
        // 模拟 admin 部署合约
        vm.startPrank(admin);
        list = new TodoListPro();
        vm.stopPrank();
    }

    // 测试 1: Admin 可以创建任务
    function testAdminCanCreate() public {
        vm.startPrank(admin);
        list.createTask("Admin Task");
        vm.stopPrank();
        
        // 验证长度为 1
        // [修复] 不能直接用 .name，必须先解构
        // list.tasks(0) 返回两个值：(string name, bool isCompleted)
        // 我们只关心第一个值，所以用 (name, ) 接收
        (string memory name, ) = list.tasks(0);
        
        assertEq(name, "Admin Task");// 注意 Struct 数组的自动 getter 写法
    }

    // 测试 2: Hacker 不能创建任务 (预期 Revert)
    function testHackerCannotCreate() public {
        vm.startPrank(hacker);
        
        // 预期报错：NotOwner(hacker)
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.NotOwner.selector, 
                hacker
            )
        );

        list.createTask("Hacker Task");
        
        vm.stopPrank();
    }
}