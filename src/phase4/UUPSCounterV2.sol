// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {UUPSCounter} from "./UUPSCounter.sol";

// 继承 V1，这样我们就拥有了 V1 所有的变量和函数
contract UUPSCounterV2 is UUPSCounter {
    
    // [新增功能] 翻倍
    function double() public {
        count = count * 2;
    }
}