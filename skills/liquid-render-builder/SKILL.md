---
name: liquid-render-builder
description: Build or iterate on Liquid Edition render contracts in this starter repo. Use when asked to design a market-reactive artwork, choose between the single-artwork and ERC721 lens patterns, edit tokenURI metadata output, wire a contract to ILiquid state, add tests, or help an artist vibe code a renderer without over-abstracting the repo.
---

# Liquid Render Builder

## Overview

Use the existing starter contracts as the default path for building Liquid Edition renderers.

Keep the work legible for artists: prefer editing one example contract directly, keep rendering logic local to that contract, and preserve the metadata entrypoints the platform expects.

## Start Here

Open these files first:

- `README.md`
- `AGENTS.md`
- `src/interfaces/ILiquid.sol`
- `src/interfaces/ILiquidBase.sol`
- `src/interfaces/IRender.sol`

Then choose the closer example:

- `src/examples/LiquidLensHTMLExample.sol` for a single artwork attached directly to the Liquid Edition
- `src/examples/LiquidLensMintable721SVGExample.sol` for a combined render-contract-plus-ERC721 pattern

If the user needs ERC721 mechanics, also read:

- `src/token/SimpleERC721.sol`

If the user needs testing context, read:

- `src/mocks/MockLiquid.sol`
- `test/LiquidLensExamples.t.sol`

## Core Product Rules

Apply these rules consistently:

- Treat the market as artistic material, not just as UI data.
- Prefer generative or state-reactive work over static IPFS-style examples unless the user explicitly asks for static output.
- Use RARE-denominated language such as `rarePerToken` and `tokenPerRare`.
- Return standard NFT metadata JSON from `tokenURI()`.
- Keep the Liquid passthrough path centered on `tokenURI()`.
- Remember that a Liquid Edition can register only one render contract address.
- If the artist wants an ERC721 lens collection, the clearest pattern is a single contract that is both the registered renderer and the ERC721.
- Standard buying and selling flows are supported; custom mechanics are allowed but are not automatically surfaced in the platform UI.

## Choose The Pattern

Default to one of these two patterns:

### 1. Render-only contract

Use this when the artwork is only the Liquid Edition surface.

Requirements:

- Implement `tokenURI()`
- Read from `ILiquid` directly
- Return standard NFT metadata JSON

Start from:

- `src/examples/LiquidLensHTMLExample.sol`

### 2. Combined renderer plus ERC721

Use this when the artist wants a companion collection that reads the same Liquid state.

Requirements:

- Implement `tokenURI()` for the Liquid Edition passthrough
- Implement `tokenURI(uint256)` for the ERC721 tokens
- Preserve ERC721 behavior and `supportsInterface` by inheriting `SimpleERC721`

Start from:

- `src/examples/LiquidLensMintable721SVGExample.sol`

## Build Workflow

Follow this sequence:

1. Decide whether the work is ERC20-only or ERC20 plus ERC721.
2. Decide whether HTML or SVG is the better output format for the first version.
3. Choose one example contract and edit it directly instead of inventing a new abstraction layer.
4. Keep the first version simple. Map one or two market inputs to visible changes before adding extra mechanics.
5. Read `getMarketState()` and `getLaunchState()` first. Add more `ILiquid` inputs only when the artwork actually needs them.
6. Preserve the required metadata entrypoints while changing the rendering logic, copy, attributes, and constructor params.
7. Add or update tests with `MockLiquid` so the render changes are exercised by state changes.

## Good Inputs To Reach For

Start with:

- `name()`
- `symbol()`
- `tokenCreator()`
- `maxTotalSupply()`
- `getMarketState()`
- `getLaunchState()`

Reach for these later if the artwork really needs them:

- `balanceOf(address)`
- `quoteBuy()`
- `quoteSell()`
- `lpLiquidity()`
- `totalLiquidity()`
- `lpTickLower()`
- `lpTickUpper()`

Treat `quoteBuy()` and `quoteSell()` as optional quote-at-size tools, not required starting points.

## Metadata Rules

Return standard NFT metadata JSON.

Use fields such as:

- `name`
- `description`
- `image`
- optional `animation_url`
- optional `external_url`
- optional `attributes`

Supported media can include:

- SVG
- HTML
- images
- video
- GIFs

These are still standard NFTs. The distinctive part is that the metadata can be generated from live on-chain Liquid state.

## Implementation Guidance

Keep the contract artist-editable:

- Favor straightforward helper functions over shared inheritance trees.
- Keep rendering logic in the example contract where possible.
- Keep names, descriptions, and external URLs as constructor or storage values the artist can easily change.
- Preserve `tokenURI()` even if the artist heavily changes the internal artwork logic.

Avoid common mistakes:

- Do not describe ETH-denominated pricing when the reserve currency is RARE.
- Do not imply that multiple render contracts can be registered to one Liquid Edition.
- Do not promise UI support for custom mechanics such as burn-to-mint, claim flows, or special admin actions.
- Do not break the metadata JSON envelope while experimenting with visuals.

When string assembly gets large, split it into smaller helpers. This repo uses `via_ir`, and giant `string.concat` chains can hit compiler stack-depth limits.

## Testing Workflow

Run:

```bash
forge test -vv
```

Check at least these behaviors:

- `tokenURI()` returns a JSON data URI
- the output changes when `MockLiquid` market state changes
- the Liquid token can register the renderer and pass through to its `tokenURI()`
- the ERC721 example mints successfully and returns distinct `tokenURI(uint256)` values

## Vibe Coding Prompts

Use prompts like:

- "Start from `LiquidLensHTMLExample.sol`. Keep it as a single self-contained contract. Read `getMarketState()` directly and map RARE price plus supply to composition."
- "Start from `LiquidLensMintable721SVGExample.sol`. Keep `tokenURI()` for the Liquid passthrough and `tokenURI(uint256)` for the collection. Make each token a different lens over the same Liquid market."
- "Do not add custom mechanics until the base render works and tests pass."

## Custom Mechanics

Artists can add custom functions and mechanics.

That can include:

- burn-to-mint
- claim flows
- freezes
- unlocks
- transfer restrictions

But those mechanics will need their own interface or script unless explicit product support exists. Keep that constraint visible when designing the contract.
