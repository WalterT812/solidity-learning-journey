// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol"; // 引入 Foundry 的标准测试库
import {DataLocations} from "../../src/phase2/DataLocations.sol"; // 引入我们要测的合约

contract DataLocationsTest is Test {
    DataLocations public myContract;

    // setUp() 会在每个测试函数运行前自动运行
    function setUp() public {
        // 部署合约
        myContract = new DataLocations();
        // 先给数组加个初始值 [100]
        myContract.addNumber(100); 
    }

    // 测试 Storage 引用 (对应 Q1)
    function testStorageReference() public {
        // 1. 调用 updateStorage，它会 push(999)
        myContract.updateStorage();
        
        // 2. 检查数组长度是否变成了 2
        // expectEq(实际值, 预期值)
        assertEq(myContract.getArr().length, 2); 
        
        // 3. 检查第二个数是不是 999
        uint256[] memory currentArr = myContract.getArr();
        assertEq(currentArr[1], 999);
    }

    // 测试 Memory 拷贝 (对应 Q2)
    function testMemoryCopy() public view {
        // 1. 调用 updateMemory，它试图把 memoryArr[0] 改成 888
        myContract.updateMemory();

        // 2. 检查原数组的第一个数
        uint256[] memory currentArr = myContract.getArr();
        
        // 关键时刻：它应该是初始值 100，而不是 888
        assertEq(currentArr[0], 100); 
    }
}