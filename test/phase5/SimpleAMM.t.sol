// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {SimpleAMM} from "../../src/phase5/SimpleAMM.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// 简单的 Mock 代币
contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000 * 1e18);
    }
}

contract SimpleAMMTest is Test {
    SimpleAMM public amm;
    MockERC20 public token0; // 比如 ETH
    MockERC20 public token1; // 比如 USDC

    address public lpProvider = address(0x1); // 做市商 (提供流动性的人)
    address public trader = address(0x2);     // 交易员 (来买币的人)

    function setUp() public {
        // 1. 部署代币
        token0 = new MockERC20("Ether", "ETH");
        token1 = new MockERC20("USDCoin", "USDC");

        // 2. 部署 AMM
        amm = new SimpleAMM(address(token0), address(token1));

        // 3. 发钱给 LP 和 Trader
        token0.transfer(lpProvider, 10000 * 1e18);
        token1.transfer(lpProvider, 10000 * 1e18);
        token0.transfer(trader, 100 * 1e18);

        // 4. 所有人都要授权给 AMM (DeFi 铁律)
        vm.prank(lpProvider);
        token0.approve(address(amm), type(uint256).max);
        vm.prank(lpProvider);
        token1.approve(address(amm), type(uint256).max);
        
        vm.prank(trader);
        token0.approve(address(amm), type(uint256).max);
    }

    function testSwap() public {
        // --- Step 1: LP 添加流动性 ---
        vm.startPrank(lpProvider);
        // 添加 1000 ETH 和 2000 USDC
        // 初始价格: 1 ETH = 2 USDC
        amm.addLiquidity(1000 * 1e18, 2000 * 1e18);
        vm.stopPrank();

        // 验证池子储备
        assertEq(amm.reserve0(), 1000 * 1e18);
        assertEq(amm.reserve1(), 2000 * 1e18);

        // --- Step 2: Trader 用 10 ETH 买 USDC ---
        vm.startPrank(trader);
        
        uint256 amountIn = 10 * 1e18;
        
        // 记录交易前 Trader 的 USDC 余额
        uint256 balanceBefore = token1.balanceOf(trader);
        
        // 执行交易: 用 token0 (ETH) 换取输出
        uint256 amountOut = amm.swap(address(token0), amountIn);
        
        // 记录交易后 Trader 的 USDC 余额
        uint256 balanceAfter = token1.balanceOf(trader);
        
        vm.stopPrank();

        // --- Step 3: 验证数学 ---
        console.log("Input ETH:", amountIn);
        console.log("Output USDC:", amountOut);

        // 我们之前算的理论值 (无手续费) 是 19.8019...
        // 现在扣了 0.3% 手续费，应该比这个稍微少一点点
        // 预期结果：大约 19.74...
        
        // 验证 Trader 真的收到了钱
        assertEq(balanceAfter - balanceBefore, amountOut);
    }
}