// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// 1. 引入库文件
// @openzeppelin 会自动映射到 lib/openzeppelin-contracts/...
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// 2. 继承 (Inheritance)
// RealToken "是" 一个 ERC20
contract RealToken is ERC20 {
    
    // 3. 构造函数
    // 这里的 "Real Token" 和 "RTK" 是代币的全名和符号
    constructor(uint256 initialSupply) ERC20("Real Token", "RTK") {
        // 4. 铸造 (Mint)
        // _mint 是 OZ 提供的内部函数，它自动处理了 totalSupply 和 balanceOf 的逻辑
        // 注意：decimals() 默认是 18，所以我们要 * 10 ** 18
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }
}