// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/MonadToken.sol";

contract DeployMonad is Script {
    function run() external returns (MonadToken) {
        vm.startBroadcast();

        MonadToken token = new MonadToken();

        vm.stopBroadcast();
        return token;
    }
}
