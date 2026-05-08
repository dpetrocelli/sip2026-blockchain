// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {MockUSDC, TestnetOnramp} from "../src/TestnetOnramp.sol";

contract TestnetOnrampTest is Test {
    MockUSDC internal usdc;
    TestnetOnramp internal onramp;

    address internal alice = makeAddr("alice");

    function setUp() public {
        usdc = new MockUSDC();
        onramp = new TestnetOnramp(usdc);
        usdc.transferOwnership(address(onramp));
        vm.deal(alice, 10 ether);
    }

    function test_BuyWithCardMintsUsdc() public {
        vm.prank(alice);
        onramp.buyWithCard{value: 0.05 ether}();
        // 0.05 * 1000 / 1e12 in 18-dec → 50 mUSDC (6 dec)
        assertEq(usdc.balanceOf(alice), 50 * 10 ** 6);
    }

    function test_BuyEmitsEvent() public {
        uint256 ethIn = 0.1 ether;
        uint256 expected = (ethIn * 1000) / 1e12;

        vm.expectEmit(true, false, false, true);
        emit TestnetOnramp.Onramped(alice, ethIn, expected);

        vm.prank(alice);
        onramp.buyWithCard{value: ethIn}();
    }

    function test_BuyRevertsOnZeroValue() public {
        vm.prank(alice);
        vm.expectRevert(bytes("no eth"));
        onramp.buyWithCard{value: 0}();
    }

    function test_OnlyOwnerCanWithdraw() public {
        vm.prank(alice);
        onramp.buyWithCard{value: 1 ether}();

        // alice no es owner
        vm.prank(alice);
        vm.expectRevert();
        onramp.withdraw();
    }

    function testFuzz_RateIsConsistent(uint96 ethIn) public {
        vm.assume(ethIn > 1e12 && ethIn <= 5 ether);
        vm.deal(alice, ethIn);
        vm.prank(alice);
        onramp.buyWithCard{value: ethIn}();
        assertEq(usdc.balanceOf(alice), (uint256(ethIn) * 1000) / 1e12);
    }
}
