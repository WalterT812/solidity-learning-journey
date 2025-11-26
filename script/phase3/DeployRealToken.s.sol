// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
// 注意：因为我们在 script/phase3/ 下，所以要往上跳两级才能找到 src
import {RealToken} from "../../src/phase3/RealToken.sol";

contract DeployRealToken is Script {
    function run() external returns (RealToken) {
        // 1. 开始广播
        vm.startBroadcast();

        // 2. 部署合约 (初始供应量 1000)
        RealToken token = new RealToken(1000);

        // 3. 结束广播
        vm.stopBroadcast();

        return token;
    }
}