// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {Staking} from "../../src/phase5/Staking.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// 创建一个简单的 Mock 代币用于测试
contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000 * 1e18); // 初始发个一百万币
    }
}

contract StakingTest is Test {
    Staking public staking;
    MockERC20 public stakingToken;
    MockERC20 public rewardsToken;

    address public user1 = address(0x1);
    address public user2 = address(0x2);

    function setUp() public {
        // 1. 部署两个代币
        stakingToken = new MockERC20("Stake Token", "STK");
        rewardsToken = new MockERC20("Reward Token", "RWD");

        // 2. 部署 Staking 合约
        staking = new Staking(address(stakingToken), address(rewardsToken));

        // 3. 给 Staking 合约充值奖励代币 (否则发不出奖励)
        rewardsToken.transfer(address(staking), 1000 * 1e18);

        // 4. 给用户发一些 Staking Token
        stakingToken.transfer(user1, 100 * 1e18);
        stakingToken.transfer(user2, 100 * 1e18);

        // 5. 用户必须授权给 Staking 合约，才能存钱
        vm.prank(user1);
        stakingToken.approve(address(staking), 100 * 1e18);
        
        vm.prank(user2);
        stakingToken.approve(address(staking), 100 * 1e18);
    }

    function testStakingAndRewards() public {
        // --- 场景开始 ---
        
        // 1. User1 进场，存入 100
        vm.startPrank(user1);
        staking.stake(100 * 1e18);
        vm.stopPrank();

        // 2. 时间流逝 10 秒
        // vm.warp 是作弊码，直接修改链上时间
        vm.warp(block.timestamp + 10);

        // 此时，User1 应该赚了：10秒 * 100币/秒 = 1000 币
        // 我们不取出来，只是看看 earned 读数对不对
        uint256 earned1 = staking.earned(user1);
        // 允许有一点点误差 (Solidity 精度问题)
        assertApproxEqAbs(earned1, 1000 * 1e18, 1e16);

        // 3. User2 进场，也存入 100
        vm.startPrank(user2);
        staking.stake(100 * 1e18);
        vm.stopPrank();

        // 此时总质押量是 200。
        // 再过 10 秒
        vm.warp(block.timestamp + 10);

        // 4. 计算 User1 的奖励
        // 前 10 秒：独享 1000
        // 后 10 秒：和 User2 对半分 (每人 500)
        // User1 总共应该有 1500
        uint256 earned1_final = staking.earned(user1);
        uint256 earned2_final = staking.earned(user2);

        console.log("User1 Earned:", earned1_final);
        console.log("User2 Earned:", earned2_final);

        assertApproxEqAbs(earned1_final, 1500 * 1e18, 1e16);
        assertApproxEqAbs(earned2_final, 500 * 1e18, 1e16);
    }
}