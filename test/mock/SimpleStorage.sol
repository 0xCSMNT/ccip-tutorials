// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Simple storage contract
contract SimpleStorage {
    uint256 private storedData;

    // Event to indicate that value has been stored
    event ValueStored(uint256 newValue);

    // Function to store a new value in the contract
    function store(uint256 x) public {
        storedData = x;
        emit ValueStored(x);
    }

    // Function to retrieve the stored value
    function retrieve() public view returns (uint256) {
        return storedData;
    }
}
