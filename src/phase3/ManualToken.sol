// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ManualToken {
    // 代币元数据
    string public name = "Manual Token";
    string public symbol = "MTK";
    uint8 public decimals = 18; // 标准精度，1个币 = 1 * 10^18 wei
    uint256 public totalSupply;

    // 1. 余额账本: 谁 -> 有多少钱
    mapping(address => uint256) public balanceOf;

    // 2. 授权账本 (DeFi 核心): 
    // 拥有者(Owner) -> 授权给谁(Spender) -> 多少额度(Amount)
    mapping(address => mapping(address => uint256)) public allowance;

    // 标准事件 (方便前端和 Etherscan 记录)
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // 初始化：把所有币都印给部署者
    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    // --------------------------------------------------------
    // 功能 A: 主动转账 (Push)
    // 我直接把钱转给你
    // --------------------------------------------------------
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        // 检查余额 (0.8+ 溢出会自动 revert，但最好手动报错)
        if (balanceOf[msg.sender] < _amount) {
            revert("Not enough balance");
        }
        
        balanceOf[msg.sender] -= _amount;
        balanceOf[_to] += _amount;
        
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    // --------------------------------------------------------
    // 功能 B: 授权 (Approve)
    // 我允许 _spender 动用我 _amount 数量的钱
    // --------------------------------------------------------
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        allowance[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    // --------------------------------------------------------
    // 功能 C: 被动转账 / 代理转账 (Pull)
    // 场景：Uniswap 拿走你的币去交易
    // --------------------------------------------------------
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
        // 1. 检查 `_from` (钱的主人) 钱够不够
        if (balanceOf[_from] < _amount) {
            revert("Not enough balance");
        }
        
        // 2. 检查 `msg.sender` (调用者) 是否有权动这笔钱
        // 这里的 msg.sender 通常是 Uniswap 合约地址
        uint256 currentAllowance = allowance[_from][msg.sender];
        if (currentAllowance < _amount) {
            revert("Allowance exceeded");
        }

        // 3. 扣除额度 (先减额度，再转账)
        allowance[_from][msg.sender] -= _amount;

        // 4. 执行转账
        balanceOf[_from] -= _amount;
        balanceOf[_to] += _amount;

        emit Transfer(_from, _to, _amount);
        return true;
    }
}