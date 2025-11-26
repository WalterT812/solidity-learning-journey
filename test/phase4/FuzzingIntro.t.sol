// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {FuzzingIntro} from "../../src/phase4/FuzzingIntro.sol";

contract FuzzingIntroTest is Test {
    FuzzingIntro public fuzz;

    function setUp() public {
        fuzz = new FuzzingIntro();
    }

    // 1. 普通单元测试 (Unit Test)
    // 我们只能测我们想到的数字
    function testDoSomethingManual() public view {
        assertEq(fuzz.doSomething(1), true);
        assertEq(fuzz.doSomething(100), true);
        assertEq(fuzz.doSomething(999999), true);
        // 如果我没猜到 12345，这个测试就永远是通过的，Bug 就漏掉了！
    }

    // 2. 模糊测试 (Fuzz Test)
    // 注意：这里有了参数 `uint256 x`
    // Foundry 会自动生成几千个 x 来跑这个函数
    function testFuzzDoSomething(uint256 x) public view {
        // [新增] 限制范围
        // 告诉 Foundry：虽然参数是 uint256，但请把随机数限制在 0 到 20000 之间
        // bound 是 forge-std 提供的工具函数
        x = bound(x, 12300, 12400);

        // 现在只有 20000 个可能的数字，跑 256 次，
        // 命中 12345 的概率就非常大了！
        bool result = fuzz.doSomething(x);
        assertEq(result, true);
    }

    // 3. Fuzzing 溢出测试
    // 参数是 uint8，Foundry 会尝试所有 uint8 的边界（0, 255, etc.）
    function testFuzzSafeAdd(uint8 a, uint8 b) public view {
        // 我们如果不加限制，a + b 可能会超过 255 (revert)
        // vm.assume 是 Fuzzing 的过滤器
        // 意思是：Foundry 你生成的随机数，必须满足 a + b <= 255，否则重随
        vm.assume(uint16(a) + uint16(b) <= 255);
        
        fuzz.safeAdd(a, b);
    }
}