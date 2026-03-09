// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

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
