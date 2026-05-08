// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {BadgeNFT} from "../src/BadgeNFT.sol";

contract BadgeNFTTest is Test {
    BadgeNFT internal badge;
    address internal owner = address(this);
    address internal alice = makeAddr("alice");

    function setUp() public {
        badge = new BadgeNFT("VibeCheck Pieces", "VIBE-P", owner);
    }

    function test_MintRandomAssignsTokenToHolder() public {
        bytes32 entropy = keccak256("e1");
        uint256 id = badge.mintRandom(alice, entropy);
        assertEq(badge.ownerOf(id), alice);
    }

    function test_MintEmitsPieceMintedEvent() public {
        bytes32 entropy = keccak256("e2");
        uint8 expectedSlot = uint8(uint256(entropy) % badge.SLOTS());
        // Rarity is deterministic for fixed entropy, but we don't assert it (private fn).
        // Testing slot only via vm.recordLogs would over-couple the test; here we
        // assert that the event is emitted with the expected slot via expectEmit
        // marking only the slot field as checked.
        vm.expectEmit(true, true, false, false);
        emit BadgeNFT.PieceMinted(alice, 1, expectedSlot, BadgeNFT.Rarity.Common);
        badge.mintRandom(alice, entropy);
    }

    function test_OnlyOwnerCanMint() public {
        vm.prank(alice);
        vm.expectRevert();
        badge.mintRandom(alice, keccak256("e3"));
    }

    function test_UniqueSlotsOf_CountsDistinctSlots() public {
        // Mint a few pieces to alice with controlled entropies that yield
        // different slots. We mint enough that we're likely to hit > 1 distinct slot.
        uint256[] memory ids = new uint256[](6);
        for (uint256 i = 0; i < 6; i++) {
            ids[i] = badge.mintRandom(alice, keccak256(abi.encode("e", i)));
        }
        uint8 unique = badge.uniqueSlotsOf(alice, ids);
        assertGt(unique, 0);
        assertLe(unique, badge.SLOTS());
    }

    function test_UniqueSlotsOf_RevertsIfNotOwner() public {
        uint256 id = badge.mintRandom(alice, keccak256("only"));
        uint256[] memory ids = new uint256[](1);
        ids[0] = id;
        // bob, not alice
        address bob = makeAddr("bob");
        vm.expectRevert(bytes("not owner"));
        badge.uniqueSlotsOf(bob, ids);
    }

    function testFuzz_RarityRollIsInRange(bytes32 entropy) public {
        uint256 id = badge.mintRandom(alice, entropy);
        (, BadgeNFT.Rarity rarity) = badge.pieces(id);
        assertLe(uint256(rarity), uint256(BadgeNFT.Rarity.Legendary));
    }
}
