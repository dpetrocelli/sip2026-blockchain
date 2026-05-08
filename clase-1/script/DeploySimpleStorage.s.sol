// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract DeploySimpleStorage is Script {
    function run() external returns (SimpleStorage deployed) {
        vm.startBroadcast();
        deployed = new SimpleStorage();
        vm.stopBroadcast();

        console2.log("SimpleStorage deployed at:", address(deployed));
    }
}
