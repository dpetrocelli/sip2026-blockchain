// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract SimpleStorageTest is Test {
    SimpleStorage internal storage_;

    event ValueChanged(address indexed by, uint256 newValue);

    function setUp() public {
        storage_ = new SimpleStorage();
    }

    function test_DefaultValueIsZero() public view {
        assertEq(storage_.get(), 0);
    }

    function test_SetUpdatesValue() public {
        storage_.set(42);
        assertEq(storage_.get(), 42);
    }

    function test_EmitsEventOnSet() public {
        vm.expectEmit(true, false, false, true);
        emit ValueChanged(address(this), 99);
        storage_.set(99);
    }

    function testFuzz_SetAnyValue(uint256 value) public {
        storage_.set(value);
        assertEq(storage_.get(), value);
    }
}
