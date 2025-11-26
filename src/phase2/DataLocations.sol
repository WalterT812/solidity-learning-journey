// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract DataLocations {
    // Slot 0
    uint256 public x = 100;
    // Slot 1: 动态数组，长度存 Slot 1，数据存在 Keccak256(Slot1) 开始的地方
    uint256[] public arr; 

    // 用于初始化测试数据
    function addNumber(uint256 _num) public {
        arr.push(_num);
    }

    // 场景 A: Storage 指针 (引用传递)
    function updateStorage() public {
        // 关键点：这里用了 `storage` 关键字
        uint256[] storage storageArr = arr; 
        storageArr.push(999); 
    }

    // 场景 B: Memory 拷贝 (值传递)
    function updateMemory() public view {
        // 关键点：这里用了 `memory` 关键字
        uint256[] memory memoryArr = arr; 
        
        // 只有数组不为空才能修改，防止越界报错
        if (memoryArr.length > 0) {
            memoryArr[0] = 888; 
        }
    }
    
    // 辅助函数：获取数组当前内容
    function getArr() public view returns (uint256[] memory) {
        return arr;
    }
}