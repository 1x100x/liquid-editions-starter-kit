// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Interface for render contracts that provide Liquid metadata.
interface IRender {
    function tokenURI() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}
