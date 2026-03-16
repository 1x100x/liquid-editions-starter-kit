// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IHooks} from "../interfaces/IHooks.sol";
import {Currency} from "./Currency.sol";

/// @notice Minimal local copy of the Uniswap V4 pool key ABI shape.
struct PoolKey {
    Currency currency0;
    Currency currency1;
    uint24 fee;
    int24 tickSpacing;
    IHooks hooks;
}
