// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleAMM {
    IERC20 public token0;
    IERC20 public token1;

    // 池子里的储备量 (Reserves)
    // 我们单独记录它，是为了防止有人直接把币转给合约而不调用 swap (导致余额 > 储备)
    uint256 public reserve0;
    uint256 public reserve1;

    // 记录谁提供了流动性 (简化版：不发 LP Token，只记录份额)
    mapping(address => uint256) public shares;
    uint256 public totalShares;

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    // ----------------------------------------------------
    // 1. 添加流动性 (Add Liquidity)
    // ----------------------------------------------------
    function addLiquidity(uint256 _amount0, uint256 _amount1) external returns (uint256) {
        // 把用户的代币拉进来
        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);

        uint256 sharesMinted;

        // 如果是第一个提供流动性的人
        if (totalShares == 0) {
            sharesMinted = _amount0 + _amount1; // 简单粗暴的计算
        } else {
            // 后续进入的人，必须按比例进入，否则会破坏价格
            // 份额 = (存入量 / 当前总量) * 总份额
            uint256 share0 = (_amount0 * totalShares) / reserve0;
            uint256 share1 = (_amount1 * totalShares) / reserve1;
            //以此取小者为准 (为了安全)
            sharesMinted = share0 < share1 ? share0 : share1;
        }

        require(sharesMinted > 0, "Shares = 0");

        shares[msg.sender] += sharesMinted;
        totalShares += sharesMinted;

        // 更新储备量
        _updateReserves(
            token0.balanceOf(address(this)),
            token1.balanceOf(address(this))
        );

        return sharesMinted;
    }

    // ----------------------------------------------------
    // 2. 交易 (Swap)
    // 核心公式：(x + dx) * (y - dy) = x * y
    // ----------------------------------------------------
    function swap(address _tokenIn, uint256 _amountIn) external returns (uint256 amountOut) {
        require(_tokenIn == address(token0) || _tokenIn == address(token1), "Invalid token");

        // 1. 判断方向：是用 0 买 1，还是用 1 买 0
        bool isToken0 = _tokenIn == address(token0);
        
        (IERC20 tokenIn, IERC20 tokenOut, uint256 reserveIn, uint256 reserveOut) = isToken0
            ? (token0, token1, reserve0, reserve1)
            : (token1, token0, reserve1, reserve0);

        // 2. 把用户的钱拿进来
        tokenIn.transferFrom(msg.sender, address(this), _amountIn);

        // 3. 计算扣除 0.3% 手续费后的有效输入
        // 也就是：输入 1000，实际上只有 997 参与计算 k 值
        uint256 amountInWithFee = (_amountIn * 997) / 1000;

        // 4. 计算能换出多少钱 (dy)
        // 公式：dy = (y * dx) / (x + dx)
        // reserveOut * amountInWithFee / (reserveIn + amountInWithFee)
        amountOut = (reserveOut * amountInWithFee) / (reserveIn + amountInWithFee);

        // 5. 把钱转给用户
        tokenOut.transfer(msg.sender, amountOut);

        // 6. 更新储备量
        _updateReserves(
            token0.balanceOf(address(this)),
            token1.balanceOf(address(this))
        );
    }

    // 内部函数：同步储备量
    function _updateReserves(uint256 _reserve0, uint256 _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }
}