// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {BadgeNFT} from "../src/BadgeNFT.sol";
import {PaymentGatewayWithBadge} from "../src/PaymentGatewayWithBadge.sol";

contract MockUSDC is ERC20 {
    constructor() ERC20("Mock USDC", "mUSDC") {
        _mint(msg.sender, 1_000_000 * 10 ** 6);
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }
}

contract PaymentGatewayWithBadgeTest is Test {
    MockUSDC internal usdc;
    BadgeNFT internal badge;
    PaymentGatewayWithBadge internal gateway;

    address internal alice = makeAddr("alice");
    address internal treasury = makeAddr("treasury");

    function setUp() public {
        usdc = new MockUSDC();
        // owner of the badge has to be the gateway, set after deploy.
        badge = new BadgeNFT("VibeCheck Pieces", "VIBE-P", address(this));
        gateway = new PaymentGatewayWithBadge(usdc, treasury, badge);
        badge.transferOwnership(address(gateway));

        usdc.transfer(alice, 1000 * 10 ** 6);
    }

    function test_PayMintsBadgeToPayer() public {
        uint256 amount = 50 * 10 ** 6;

        vm.startPrank(alice);
        usdc.approve(address(gateway), amount);
        gateway.pay(amount, bytes32("VIBE_TICKET_42"));
        vm.stopPrank();

        // Alice debe ser dueña de un NFT (tokenId 1).
        assertEq(badge.ownerOf(1), alice);
    }

    function test_TwoPaymentsMintTwoBadges() public {
        vm.startPrank(alice);
        usdc.approve(address(gateway), 100 * 10 ** 6);
        gateway.pay(20 * 10 ** 6, bytes32("a"));
        gateway.pay(30 * 10 ** 6, bytes32("b"));
        vm.stopPrank();

        assertEq(badge.ownerOf(1), alice);
        assertEq(badge.ownerOf(2), alice);
    }

    function test_TreasuryReceivesUsdc() public {
        vm.startPrank(alice);
        usdc.approve(address(gateway), 75 * 10 ** 6);
        gateway.pay(75 * 10 ** 6, bytes32("vip"));
        vm.stopPrank();

        assertEq(usdc.balanceOf(treasury), 75 * 10 ** 6);
    }
}
