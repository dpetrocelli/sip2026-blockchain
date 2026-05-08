// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {PaymentGateway} from "../src/PaymentGateway.sol";

/// @dev Token ERC-20 fake con 6 decimales (igual que USDC) para tests.
contract MockUSDC is ERC20 {
    constructor() ERC20("Mock USDC", "mUSDC") {
        _mint(msg.sender, 1_000_000 * 10 ** 6); // 1M USDC
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }
}

contract PaymentGatewayTest is Test {
    PaymentGateway internal gateway;
    MockUSDC internal usdc;

    address internal alice = makeAddr("alice");
    address internal treasury = makeAddr("treasury");

    function setUp() public {
        usdc = new MockUSDC();
        gateway = new PaymentGateway(usdc, treasury);

        usdc.transfer(alice, 1000 * 10 ** 6);
    }

    function test_PayMovesUsdcToTreasury() public {
        uint256 amount = 50 * 10 ** 6;

        vm.startPrank(alice);
        usdc.approve(address(gateway), amount);
        gateway.pay(amount, bytes32("test-action"));
        vm.stopPrank();

        assertEq(usdc.balanceOf(treasury), amount);
        assertEq(usdc.balanceOf(alice), (1000 * 10 ** 6) - amount);
    }

    function test_PayEmitsEvent() public {
        uint256 amount = 100 * 10 ** 6;

        vm.startPrank(alice);
        usdc.approve(address(gateway), amount);

        vm.expectEmit(true, true, false, true);
        emit PaymentGateway.Paid(alice, amount, bytes32("ticket-1"));
        gateway.pay(amount, bytes32("ticket-1"));

        vm.stopPrank();
    }

    function test_PayRevertsOnZeroAmount() public {
        vm.startPrank(alice);
        usdc.approve(address(gateway), 0);

        vm.expectRevert(PaymentGateway.AmountZero.selector);
        gateway.pay(0, bytes32("nada"));
    }

    function test_PayRevertsWithoutApprove() public {
        uint256 amount = 50 * 10 ** 6;

        vm.startPrank(alice);
        vm.expectRevert();
        gateway.pay(amount, bytes32("test"));
    }

    function testFuzz_PayAnyValidAmount(uint96 amount) public {
        vm.assume(amount > 0 && amount <= 1000 * 10 ** 6);

        vm.startPrank(alice);
        usdc.approve(address(gateway), amount);
        gateway.pay(amount, bytes32("fuzz"));

        assertEq(usdc.balanceOf(treasury), amount);
    }
}
