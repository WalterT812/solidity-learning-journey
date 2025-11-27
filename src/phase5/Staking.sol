// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Staking is ReentrancyGuard {
    IERC20 public stakingToken; // 存进去的币
    IERC20 public rewardsToken; // 赚出来的币

    // 挖矿速率：每秒发放多少奖励
    uint256 public constant REWARD_RATE = 100 * 1e18; 
    
    // 上次更新时间
    uint256 public lastUpdateTime;
    
    // [核心数学] 每单位代币累积的奖励值 (全局指针)
    // 意思是：如果你从盘古开天辟地就存了 1 个币，到现在你应该拿多少奖励
    uint256 public rewardPerTokenStored;

    // 用户的“已支付”标记
    // userRewardPerTokenPaid[user] = 100 意思是：
    // 这个用户在 rewardPerTokenStored = 100 的时候已经结算过了
    mapping(address => uint256) public userRewardPerTokenPaid;

    // 用户当前待领取的奖励
    mapping(address => uint256) public rewards;

    // 总质押量
    uint256 public totalSupply;
    // 每个用户的质押量
    mapping(address => uint256) public balanceOf;

    constructor(address _stakingToken, address _rewardsToken) {
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
    }

    // ----------------------------------------------------
    // [核心算法] 更新奖励修饰符
    // ----------------------------------------------------
    // 每次用户操作(deposit/withdraw)之前，必须先结算他之前的奖励
    modifier updateReward(address account) {
        // 1. 更新全局指针
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;

        // 2. 结算当前用户的奖励
        if (account != address(0)) {
            // 新奖励 = (全局累积值 - 用户上次结算值) * 用户余额
            rewards[account] = earned(account);
            // 更新用户的结算标记
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    // 计算全局累积值
    function rewardPerToken() public view returns (uint256) {
        if (totalSupply == 0) {
            return rewardPerTokenStored;
        }
        // 公式：旧累积值 + (时间差 * 速率 * 1e18 / 总质押量)
        // * 1e18 是为了防止除法精度丢失
        return rewardPerTokenStored + (
            (block.timestamp - lastUpdateTime) * REWARD_RATE * 1e18 / totalSupply
        );
    }

    // 计算用户赚了多少
    function earned(address account) public view returns (uint256) {
        return (
            (balanceOf[account] * (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18
        ) + rewards[account];
    }

    // ----------------------------------------------------
    // 用户操作函数
    // ----------------------------------------------------

    // 存款
    function stake(uint256 amount) external nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        totalSupply += amount;
        balanceOf[msg.sender] += amount;
        // 真正的转账：把用户的钱拿进合约
        stakingToken.transferFrom(msg.sender, address(this), amount);
    }

    // 取款
    function withdraw(uint256 amount) external nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        totalSupply -= amount;
        balanceOf[msg.sender] -= amount;
        stakingToken.transfer(msg.sender, amount);
    }

    // 领奖
    function getReward() external nonReentrant updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
        }
    }
}