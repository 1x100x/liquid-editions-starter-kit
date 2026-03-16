// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ILiquid} from "../interfaces/ILiquid.sol";
import {IHooks} from "../interfaces/IHooks.sol";
import {ILiquidBase} from "../interfaces/ILiquidBase.sol";
import {IRender} from "../interfaces/IRender.sol";
import {Currency} from "../types/Currency.sol";
import {PoolId} from "../types/PoolId.sol";

contract MockLiquid is ILiquid, ILiquidBase {
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public initialTokenUri;
    string public storedTokenUri;
    address public override tokenCreator;
    address public override baseToken;
    address public override factory;
    address public override renderContract;
    address public override poolManager;
    uint256 public override maxTotalSupply;
    uint256 public override poolLaunchSupply;
    uint256 public override creatorLaunchReward;
    int24 public override lpTickLower;
    int24 public override lpTickUpper;
    uint128 public override lpLiquidity;
    uint128 public override totalLiquidity;

    uint256 public rarePerToken;
    uint256 public tokenPerRare;
    uint160 public sqrtPriceX96;
    int24 public currentTick;
    ILiquidBase.LaunchType public launchType;
    bool public poolLive;
    address public auction;
    address public strategy;
    Currency private _poolCurrency0;
    Currency private _poolCurrency1;
    uint24 private _poolFee;
    int24 private _poolTickSpacing;
    IHooks private _poolHooks;
    PoolId private _poolId;

    constructor() {
        name = "Mock Liquid";
        symbol = "MLQD";
        tokenCreator = msg.sender;
        baseToken = address(0xBEEF);
        factory = address(0xFACADE);
        poolManager = address(0xCAFE);
        maxTotalSupply = 1_000_000 ether;
        totalSupply = 900_000 ether;
        poolLaunchSupply = 900_000 ether;
        creatorLaunchReward = 100_000 ether;
        rarePerToken = 0.0025 ether;
        tokenPerRare = 400 ether;
        sqrtPriceX96 = 79_228_162_514_264_337_593_543_950_336;
        currentTick = 125;
        totalLiquidity = 42_000;
        lpLiquidity = 42_000;
        launchType = ILiquidBase.LaunchType.INSTANT;
        poolLive = true;
        initialTokenUri = "ipfs://liquid-initial";
        storedTokenUri = initialTokenUri;
        balanceOf[msg.sender] = totalSupply;
        _poolCurrency0 = Currency.wrap(baseToken);
        _poolCurrency1 = Currency.wrap(address(this));
        _poolFee = 3_000;
        _poolTickSpacing = 60;
        _poolId = PoolId.wrap(keccak256("mock-pool"));
    }

    function transfer(address to, uint256 value) external returns (bool) {
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        if (allowed != type(uint256).max) {
            allowance[from][msg.sender] = allowed - value;
        }

        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
        return true;
    }

    function burn(uint256 amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    function tokenURI() external view returns (string memory) {
        if (renderContract == address(0)) {
            return storedTokenUri;
        }

        return IRender(renderContract).tokenURI();
    }

    function setRenderContract(address renderContract_) external {
        if (msg.sender != tokenCreator) revert NotTokenCreator();
        renderContract = renderContract_;
        emit RenderContractSet(renderContract_);
    }

    function poolKey() external view returns (Currency currency0, Currency currency1, uint24 fee, int24 tickSpacing, IHooks hooks) {
        return (_poolCurrency0, _poolCurrency1, _poolFee, _poolTickSpacing, _poolHooks);
    }

    function poolId() external view returns (PoolId) {
        return _poolId;
    }

    function getCurrentPrice() external view returns (uint256, uint256) {
        return (rarePerToken, tokenPerRare);
    }

    function getMarketState() external view returns (uint256, uint256, uint160, int24, uint128, uint256) {
        return (rarePerToken, tokenPerRare, sqrtPriceX96, currentTick, totalLiquidity, totalSupply);
    }

    function getLaunchState() external view returns (ILiquidBase.LaunchType, bool, address, address) {
        return (launchType, poolLive, auction, strategy);
    }

    function quoteBuy(uint256 rareIn) external view returns (uint256 liquidOut, uint160 sqrtPriceX96After) {
        liquidOut = (rareIn * 1e18) / rarePerToken;
        sqrtPriceX96After = sqrtPriceX96;
    }

    function quoteSell(uint256 liquidIn) external view returns (uint256 rareOut, uint160 sqrtPriceX96After) {
        rareOut = (liquidIn * rarePerToken) / 1e18;
        sqrtPriceX96After = sqrtPriceX96;
    }

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function setTokenMetadata(string memory name_, string memory symbol_) external {
        name = name_;
        symbol = symbol_;
    }

    function setCreator(address creator_) external {
        tokenCreator = creator_;
    }

    function setStaticTokenUri(string memory tokenUri_) external {
        storedTokenUri = tokenUri_;
    }

    function setMarketState(
        uint256 rarePerToken_,
        uint256 tokenPerRare_,
        uint160 sqrtPriceX96_,
        int24 currentTick_,
        uint128 totalLiquidity_,
        uint256 totalSupply_
    ) external {
        rarePerToken = rarePerToken_;
        tokenPerRare = tokenPerRare_;
        sqrtPriceX96 = sqrtPriceX96_;
        currentTick = currentTick_;
        totalLiquidity = totalLiquidity_;
        lpLiquidity = totalLiquidity_;
        totalSupply = totalSupply_;
    }

    function setLaunchState(ILiquidBase.LaunchType launchType_, bool poolLive_, address auction_, address strategy_)
        external
    {
        launchType = launchType_;
        poolLive = poolLive_;
        auction = auction_;
        strategy = strategy_;
    }

    function setMaxTotalSupply(uint256 maxTotalSupply_) external {
        maxTotalSupply = maxTotalSupply_;
    }
}
