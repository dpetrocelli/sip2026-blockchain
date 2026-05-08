// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {PaymentGateway} from "../src/PaymentGateway.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployPaymentGateway is Script {
    function run() external returns (PaymentGateway gateway) {
        IERC20 usdc = IERC20(vm.envAddress("USDC_SEPOLIA"));
        address treasury = vm.envAddress("TREASURY");

        vm.startBroadcast();
        gateway = new PaymentGateway(usdc, treasury);
        vm.stopBroadcast();

        console.log("PaymentGateway deployed at:", address(gateway));
    }
}
