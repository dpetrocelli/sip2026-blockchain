// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {MockUSDC, TestnetOnramp} from "../src/TestnetOnramp.sol";

contract DeployOnramp is Script {
    function run() external returns (MockUSDC usdc, TestnetOnramp onramp) {
        vm.startBroadcast();
        usdc = new MockUSDC();
        onramp = new TestnetOnramp(usdc);
        usdc.transferOwnership(address(onramp));
        vm.stopBroadcast();

        console.log("MockUSDC deployed at:    ", address(usdc));
        console.log("TestnetOnramp deployed at:", address(onramp));
    }
}
