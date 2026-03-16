# AGENTS.md

This repo is a forkable artist workspace for Liquid render contracts.

It is meant to help artists get from idea to first render quickly, even if they are mostly vibe coding.

## Shared Skills

Reusable repo-local skills live under `skills/`.

- `skills/liquid-render-builder/SKILL.md`
- `skills/liquid-render-deployer/SKILL.md`

Treat those `SKILL.md` files as shared workflow guidance for this repo, not as provider-specific product features.

## Primary Contracts

- `src/examples/LiquidLensHTMLExample.sol`
- `src/examples/LiquidLensMintable721SVGExample.sol`

## Core Mental Model

- A Liquid Edition is an ERC20 token with a live on-chain market.
- That market state is valid artistic material.
- Static metadata is allowed, but the spirit of the protocol is to treat market behavior as part of the artwork.
- The ERC20 alone can be the artwork via `tokenURI()`.
- An ERC721 collection is optional.
- A Liquid Edition can register only one render contract address.
- If the registered render contract also implements ERC721 and returns `tokenURI(uint256)`, the collection can also be displayed.
- In that setup, the same contract acts as both the Liquid renderer and the ERC721 lens collection.
- The Liquid token only reaches the render contract through `tokenURI()`.
- The render contract is a read-only observer of the current chain state at metadata fetch time.
- Dynamic changes should usually be implemented as pure view logic over on-chain state.
- `tokenURI()` is not a lifecycle hook and cannot persist mutations by itself.
- Stateful changes still require explicit transactions.

## First Questions To Ask An Artist

1. Is the ERC20 alone the work, or do you want a companion ERC721 lens collection?
2. Do you want HTML output or SVG output?
3. Which state inputs matter visually: price, supply, liquidity, tick, balances, quotes, burn progress?
4. Should the work remain perpetual, or should it encode a finish state?

## Repo Intent

- `LiquidLensHTMLExample.sol` is the single-artwork example
- `LiquidLensMintable721SVGExample.sol` is the mintable ERC721 example
- both contracts should read directly from `ILiquid`
- keep `ILiquidFactory` available for creator workflows that need token creation, local testing, or end-to-end deployment automation
- avoid introducing shared render abstractions unless there is a strong reason

## Repo Rules

- Keep the starter kit lean and readable.
- Do not turn this repo into a copy of `liquid-editions-contracts`.
- Optimize for "open one file and edit it."
- Preserve `tokenURI()` on both examples.
- Preserve `tokenURI(uint256)` on the mintable 721 example.
- Keep the contracts centered on the `ILiquid` data surface.
- Return standard NFT metadata JSON.
- Prefer artist-legible mechanics over clever abstractions.

## Current Product Reality

- The on-chain contracts are the durable layer.
- The UI / UX is still evolving.
- The reserve currency is RARE, so prefer `rarePerToken` / `tokenPerRare` language.
- Render contracts should return standard NFT metadata JSON.
- HTML, SVG, images, video, and GIFs are all valid media outputs.
- Standard buying and selling flows for the Liquid Edition and ERC721 tokens are supported.
- Metadata is refreshed on relevant Liquid Edition state changes.
- Metadata is also refreshed if the companion ERC721 emits `MetadataUpdated`.
- Rendering is pull-based through `tokenURI()`.
- There is no push-based rendering path from Liquid into the render contract.
- Custom functions and mechanics are allowed, but they are not automatically supported in the platform UI.

## Artist Quickstart

Good default advice:

- Before building a render contract, the easiest Sepolia path is to create the Liquid Edition at `dev.superrare.com/create/liquid-edition`.
- After that, set `LIQUID_EDITION_ADDRESS` to the deployed Liquid Edition contract address and use this repo for the render contract.
- Start from one example file, not from scratch.
- Read `getMarketState()` and `getLaunchState()` first.
- Keep the first render simple and legible.
- Map one or two market inputs to visible changes before adding extra mechanics.
- If custom behavior needs minting, claiming, freezing, revoking, or mutation, remind the artist that someone must submit a transaction.

## Data Surface

Useful `ILiquid` inputs include:

- `balanceOf(address)`
- `totalSupply()`
- `maxTotalSupply()`
- `getCurrentPrice()`
- `getMarketState()`
- `quoteBuy()`
- `quoteSell()`
- `lpLiquidity()`
- `totalLiquidity()`
- `lpTickLower()`
- `lpTickUpper()`
- `tokenCreator()`

These are enough to derive many higher-level signals:

- market cap
- fully diluted value
- burned supply
- burn rate
- spread proxies
- price impact estimates
- distance to LP bounds
- bonding-curve progress
- holder concentration

`quoteBuy()` and `quoteSell()` are optional inputs. Treat them as quote-at-size tools, not required starting points.

## Editing Guidance

- If the user wants one Liquid render output, start from `LiquidLensHTMLExample.sol`.
- If the user wants a mintable collection, start from `LiquidLensMintable721SVGExample.sol`.
- Keep rendering logic inside the example contract where possible.
- Use `src/token/SimpleERC721.sol` as the only ERC721 base unless there is a clear reason to change.
- Encourage designs that treat market state as artistic input, not just UI stats.
- Do not default to static IPFS-style examples unless the user explicitly wants a static project.
- If the design depends on a custom mechanic like burn-to-mint, claim flows, or special admin functions, make clear that the artist will need their own interface or script unless product support is built later.
- Flag when a design may be too nonstandard for collector comprehension or current UI support.

## Testing Guidance

- Run `forge test -vv` after edits.
- Use `MockLiquid` to drive market-state changes and render registration checks.
- Verify Liquid passthrough behavior for both examples.
- Verify minting and `tokenURI(uint256)` behavior for the 721 example.
- Prefer view-driven dynamics in tests before adding stateful mechanics.

## Deployment Guidance

- For most users, the easiest Sepolia flow is: create the Liquid Edition first at `dev.superrare.com/create/liquid-edition`, then use this repo to build the render contract.
- `script/DeployLiquidLensHTMLExample.s.sol`
- `script/DeployLiquidLensMintable721SVGExample.s.sol`
- `script/RegisterRenderContract.s.sol`

Auto-registration only works when the broadcaster is the Liquid token creator.

After the render contract is registered, the artist can inspect it in the UI at:

- `dev.superrare.com/liquid-editions/11155111/<liquidEditionContractAddress>`

## Render Contract Minimum

Minimum requirement:

- `tokenURI()` must return standard NFT metadata JSON

Optional companion collection:

- `tokenURI(uint256)` for ERC721 lens metadata if the registered render contract also implements ERC721

Keep the Liquid passthrough path centered on `tokenURI()`.

## Network Assumption

- Production: Ethereum Mainnet
- Testing: Ethereum Sepolia

Use:

- the chain-specific env templates
- `RPC_URL` from the copied `.env`
- `dev.superrare.com/create/liquid-edition` as the easiest way to get a Sepolia Liquid Edition before building a renderer here
