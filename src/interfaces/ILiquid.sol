// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20Metadata} from "./IERC20Metadata.sol";
import {ILiquidBase} from "./ILiquidBase.sol";

/// @notice Artist-facing subset of the Liquid token interface.
/// @dev This keeps the starter repo lightweight while preserving the read surface
/// needed for render contracts and common registration flows.
interface ILiquid is IERC20Metadata, ILiquidBase {
    error NotTokenCreator();

    event RenderContractSet(address indexed renderContract);

    function burn(uint256 amount) external;

    function initialTokenUri() external view returns (string memory);

    function tokenURI() external view returns (string memory);

    function setRenderContract(address renderContract) external;

    function tokenCreator() external view returns (address);

    function baseToken() external view returns (address);

    function factory() external view returns (address);

    function renderContract() external view returns (address);

    function maxTotalSupply() external view returns (uint256);

    function poolLaunchSupply() external view returns (uint256);

    function creatorLaunchReward() external view returns (uint256);

    function lpTickLower() external view returns (int24);

    function lpTickUpper() external view returns (int24);

    function lpLiquidity() external view returns (uint128);

    function totalLiquidity() external view returns (uint128);

    function getCurrentPrice() external view returns (uint256 rarePerToken, uint256 tokenPerRare);

    function getMarketState()
        external
        view
        returns (
            uint256 rarePerToken,
            uint256 tokenPerRare,
            uint160 sqrtPriceX96,
            int24 currentTick,
            uint128 liquidity,
            uint256 currentSupply
        );

    function quoteBuy(uint256 rareIn) external returns (uint256 liquidOut, uint160 sqrtPriceX96After);

    function quoteSell(uint256 liquidIn) external returns (uint256 rareOut, uint160 sqrtPriceX96After);
}
