// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ManualToken} from "../../src/phase3/ManualToken.sol";
import {Handler} from "./Handler.sol"; // 引入 Handler

contract InvariantTokenTest is Test {
    ManualToken public token;
    Handler public handler; // 声明 Handler
    address public user1 = address(0x1);
    address public user2 = address(0x2);

    function setUp() public {
        token = new ManualToken(1000);
        
        // 发钱给 user1 和 user2
        token.transfer(user1, 500 ether);
        token.transfer(user2, 500 ether);

        // 1. 部署 Handler
        handler = new Handler(token, user1, user2);

        // 2. [关键改变] 告诉 Foundry：去攻击 Handler，别直接攻击 Token
        targetContract(address(handler));
    }

    function invariant_totalSupplyBalance() public view {
        // 现在的逻辑是完美的：
        // Handler 保证了钱只能在 user1 和 user2 之间流转
        // 所以总和永远不会变
        uint256 total = token.totalSupply();
        uint256 sum = token.balanceOf(user1) + token.balanceOf(user2);
        
        // 注意：因为初始分配时我们把所有钱都分给了 u1 和 u2 (500+500=1000)
        // 所以这里甚至不需要算 address(this)
        assertEq(total, sum, "Total supply mismatch!");
    }
}