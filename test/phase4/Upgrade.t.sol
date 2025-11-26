// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {UUPSCounter} from "../../src/phase4/UUPSCounter.sol";
import {UUPSCounterV2} from "../../src/phase4/UUPSCounterV2.sol";
// 引入 ERC1967Proxy (这是标准的代理合约壳子)
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract UpgradeTest is Test {
    UUPSCounter public implV1;
    UUPSCounterV2 public implV2;
    ERC1967Proxy public proxy;
    
    // 这是一个包装器，让我们在代码里能像调用 UUPSCounter 一样调用 Proxy
    UUPSCounter public wrappedProxy; 

    function setUp() public {
        // 1. 部署逻辑合约 V1
        implV1 = new UUPSCounter();

        // 2. 部署代理合约 (Proxy)
        // 并告诉它：
        // A. 你的逻辑在 implV1
        // B. 部署完立马调用 "initialize()" 初始化
        proxy = new ERC1967Proxy(
            address(implV1),
            abi.encodeWithSelector(UUPSCounter.initialize.selector)
        );

        // 3. 包装一下，方便测试调用
        wrappedProxy = UUPSCounter(address(proxy));
    }

    function testUpgrade() public {
        // Step 1: 使用 V1
        // 虽然我们调用的是 proxy，但逻辑是 V1 的
        wrappedProxy.increment();
        assertEq(wrappedProxy.count(), 1);
        
        // 此时，wrappedProxy 没有 double() 函数，调用会报错...

        // Step 2: 部署逻辑合约 V2
        implV2 = new UUPSCounterV2();

        // Step 3: 执行升级！
        // 调用 upgradeToAndCall 切换逻辑指向
        wrappedProxy.upgradeToAndCall(address(implV2), "");

        // Step 4: 验证升级成功
        // 此时 proxy 的逻辑已经变成了 V2
        // 我们需要把 wrappedProxy 强转成 V2 类型才能调用新函数
        UUPSCounterV2 wrappedProxyV2 = UUPSCounterV2(address(proxy));
        
        // 4.1 检查数据是否丢失？(最关键的一步)
        // 升级前是 1，升级后应该还是 1
        assertEq(wrappedProxyV2.count(), 1);

        // 4.2 检查新功能好不好用？
        wrappedProxyV2.double(); // 1 * 2 = 2
        assertEq(wrappedProxyV2.count(), 2);
    }
}