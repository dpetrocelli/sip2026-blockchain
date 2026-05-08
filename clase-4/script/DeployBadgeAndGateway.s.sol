// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {BadgeNFT} from "../src/BadgeNFT.sol";
import {PaymentGatewayWithBadge} from "../src/PaymentGatewayWithBadge.sol";

contract DeployBadgeAndGateway is Script {
    function run() external returns (BadgeNFT badge, PaymentGatewayWithBadge gateway) {
        IERC20 usdc = IERC20(vm.envAddress("USDC_SEPOLIA"));
        address treasury = vm.envAddress("TREASURY");
        address deployer = vm.envOr("DEPLOYER", msg.sender);
        string memory name_ = vm.envOr("BADGE_NAME", string("VibeCheck Pieces"));
        string memory symbol_ = vm.envOr("BADGE_SYMBOL", string("VIBE-P"));

        vm.startBroadcast();
        badge = new BadgeNFT(name_, symbol_, deployer);
        gateway = new PaymentGatewayWithBadge(usdc, treasury, badge);
        badge.transferOwnership(address(gateway));
        vm.stopBroadcast();

        console.log("BadgeNFT deployed at:                ", address(badge));
        console.log("PaymentGatewayWithBadge deployed at: ", address(gateway));
    }
}
