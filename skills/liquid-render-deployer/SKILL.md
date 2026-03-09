---
name: liquid-render-deployer
description: Deploy, register, and verify Liquid Edition render contracts from this starter repo. Use when asked to configure .env values, choose Sepolia or Mainnet, run Foundry deploy scripts, register a renderer on a Liquid token, explain the token-creator constraint, or add a deploy script for a custom render contract.
---

# Liquid Render Deployer

## Overview

Use the repo's Foundry scripts and env conventions as the default deployment path.

Deploy to Ethereum Sepolia first, verify the render contract and registration behavior, then move to Ethereum Mainnet once the output is correct.

## Start Here

Read these files first:

- `README.md`
- `.env.eth.sepolia`
- `.env.eth.mainnet`
- `foundry.toml`
- `script/DeployLiquidLensHTMLExample.s.sol`
- `script/DeployLiquidLensMintable721SVGExample.s.sol`
- `script/RegisterRenderContract.s.sol`
- `src/interfaces/ILiquid.sol`

## Network Assumption

Use these networks by default:

- Ethereum Mainnet for production
- Ethereum Sepolia for testing

Use the chain-specific env templates, and keep the active network in:

- `RPC_URL`

## Required Env Surface

Expect these variables to matter most:

- `DEPLOYER_PRIVATE_KEY`
- `LIQUID_EDITION_ADDRESS`
- `RENDER_CONTRACT_ADDRESS`
- `AUTO_REGISTER_RENDER`

Example-specific variables:

### HTML single-artwork example

- `LENS_NAME`
- `LENS_DESCRIPTION`
- `LENS_EXTERNAL_URL`

### Mintable ERC721 example

- `NFT_NAME`
- `NFT_SYMBOL`
- `NFT_DESCRIPTION`
- `NFT_EXTERNAL_URL`
- `NFT_MAX_SUPPLY`

## Deployment Rules

Keep these rules visible:

- Build and test before broadcasting.
- Deploy to Sepolia before Mainnet unless the user explicitly wants otherwise.
- A Liquid Edition can register only one render contract address.
- Auto-registration only works if the broadcaster is also the Liquid token creator.
- If the deployer is not the token creator, deploy first and register later from the creator account.
- `tokenURI()` returning standard NFT metadata JSON is the minimum render-contract requirement.

## Standard Workflow

Follow this sequence:

1. Copy `.env.eth.sepolia` to `.env` for testing, or `.env.eth.mainnet` to `.env` for production.
2. Run `forge build` and `forge test -vv`.
3. Choose the matching deploy script for the contract pattern.
4. Broadcast on Sepolia first.
5. Check whether auto-registration succeeded or was skipped.
6. If needed, register the render contract manually.
7. Verify the stored render contract address and inspect `tokenURI()` output.
8. Repeat on Mainnet only after the Sepolia result is correct.

## Canonical Commands

Build and test:

```bash
forge build
forge test -vv
```

Deploy the HTML example:

```bash
source .env
forge script script/DeployLiquidLensHTMLExample.s.sol:DeployLiquidLensHTMLExample --rpc-url $RPC_URL --broadcast
```

Deploy the mintable ERC721 example:

```bash
source .env
forge script script/DeployLiquidLensMintable721SVGExample.s.sol:DeployLiquidLensMintable721SVGExample --rpc-url $RPC_URL --broadcast
```

Register an existing render contract:

```bash
source .env
forge script script/RegisterRenderContract.s.sol:RegisterRenderContract --rpc-url $RPC_URL --broadcast
```

Verify the registered address:

```bash
cast call $LIQUID_EDITION_ADDRESS "renderContract()(address)" --rpc-url $RPC_URL
```

## Manual Registration Logic

Use the manual path when:

- `AUTO_REGISTER_RENDER=false`
- the deployer is not the Liquid token creator
- the contract was deployed earlier and only needs to be attached

The key constraint is that only the token creator can call:

- `setRenderContract(address)`

Do not describe registration as a permissionless action.

## Custom Contract Deployments

If the user builds a custom render contract, add a dedicated deploy script instead of overloading the existing example scripts.

Follow the example scripts closely:

- read constructor args from env vars
- log the deployer, Liquid Edition, and deployed address
- attempt auto-registration only when the deployer matches `tokenCreator()`
- keep the script simple and explicit

Do not hide too much behavior behind generic script abstractions. This repo is meant to stay legible for artists.

## Verification Checklist

Verify these things after deployment:

- the contract deployed at the expected address
- the correct render contract address is stored on the Liquid token
- `tokenURI()` returns a JSON data URI or other expected metadata URI
- the HTML example returns both `image` and `animation_url`
- the ERC721 example returns valid `tokenURI(uint256)` output for minted tokens

If possible, also verify the registration behavior in tests before mainnet deployment.

## UI And Product Constraints

Keep product support expectations accurate:

- standard buying and selling flows for the Liquid Edition are supported
- standard marketplace flows for ERC721 tokens are supported
- custom mechanics can exist onchain but are not automatically supported in the platform UI

Examples of mechanics that may need an external interface:

- burn Liquid to mint an NFT
- custom claim flows
- special admin-triggered transitions
- nonstandard transfer or redemption logic

If the deployment depends on one of those mechanics, say clearly that the artist will need their own site, script, app, or contract entrypoint to expose it.
