// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract SimpleStorageTest is Test {
    SimpleStorage simple;

    // setUp runs before each tests everytime
    function setUp() public {
        simple = new SimpleStorage();
    }
    
    function testInitialValueIsZero() public view{
        uint256 value = simple.get();
        assertEq(value, 0);
    }

    function testSetAndGet() public{
        simple.set(42);
        uint256 value = simple.get();
        assertEq(value, 42);
    }
}
