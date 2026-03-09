// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Artist-facing subset of the Liquid factory interface.
/// @dev Included mainly for scripts, reference, and power users who want to create
/// a Liquid token before attaching a render contract.
interface ILiquidFactory {
    struct Curve {
        int24 tickLower;
        int24 tickUpper;
        uint16 numPositions;
        uint256 shares;
    }

    event LiquidTokenCreated(address indexed token, address indexed creator, string tokenUri);

    function liquidInstantImplementation() external view returns (address);

    function liquidMultiCurveImplementation() external view returns (address);

    function liquidGraduatedImplementation() external view returns (address);

    function poolManager() external view returns (address);

    function poolHooks() external view returns (address);

    function minRareLiquidityWei() external view returns (uint256);

    function maxTotalSupply() external view returns (uint256);

    function creatorLaunchReward() external view returns (uint256);

    function lpTickLower() external view returns (int24);

    function lpTickUpper() external view returns (int24);

    function baseToken() external view returns (address);

    function protocolFeeRecipient() external view returns (address);

    function liquidRegistry() external view returns (address);

    function migrationExecutor() external view returns (address);

    function predictGraduatedTokenAddress(bytes32 salt, address deployer) external view returns (address);

    function createLiquidTokenInstant(
        address creator,
        string memory tokenUri,
        string memory name,
        string memory symbol,
        uint256 initialRareLiquidity
    ) external returns (address token);

    function createLiquidTokenMultiCurve(
        address creator,
        string memory tokenUri,
        string memory name,
        string memory symbol,
        uint256 initialRareLiquidity,
        Curve[] calldata curves
    ) external returns (address token);

    function createLiquidTokenWithAuction(
        address creator,
        string memory tokenUri,
        string memory name,
        string memory symbol,
        uint256 auctionSupply,
        bytes calldata auctionConfigData,
        bytes32 salt
    ) external returns (address token, address auction);
}
