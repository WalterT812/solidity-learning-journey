// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract SimpleStorage {
    uint256 private storedNumber;

    // write in storage
    function set(uint256 _newNumber) external {
        storedNumber = _newNumber;
    }

    // read from storage
    function get() external view returns(uint256) {
        return storedNumber;
    }
}