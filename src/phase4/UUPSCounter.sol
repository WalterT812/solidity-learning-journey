// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// 引入可升级版本的库
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

// 这是我们的逻辑合约 V1
contract UUPSCounter is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    uint256 public count;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        // 锁定逻辑合约，防止被直接初始化（安全最佳实践）
        _disableInitializers();
    }

    // 1. 替代 constructor 的初始化函数
    function initialize() public initializer {
        // 初始化父合约
        __Ownable_init(msg.sender);
    }
    
    // 简单的业务逻辑
    function increment() public {
        count += 1;
    }

    // 2. 授权升级必须重写这个函数
    // 只有 Owner 才能升级合约！否则黑客可以把逻辑换成“偷钱”逻辑
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}