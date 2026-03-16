// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Shared launch-state interface implemented by Liquid token variants.
interface ILiquidBase {
    enum LaunchType {
        INSTANT,
        GRADUATED,
        MULTICURVE
    }

    function getLaunchState()
        external
        view
        returns (LaunchType launchType, bool poolLive, address auction, address strategy);
}
