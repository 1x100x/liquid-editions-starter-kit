# Liquid Editions Starter Kit

This repo is a forkable Foundry workspace for artists building render contracts for Liquid Editions.

It is meant to help artists get from idea to first render quickly, even if they are mostly vibe coding.

## Liquid Editions: A Market Medium

A Liquid Edition is an ERC20 token with a live on-chain market.

That market state, including things like price, liquidity, supply, balances, and burn progress, can be used as input for generative art.

A Liquid Edition can be presented in two ways:

- as a single artwork attached directly to the ERC20 via `tokenURI()`
- as that same ERC20 plus an optional companion ERC721 collection, where each NFT is a different lens over the same state

The ERC721 is optional. Some Liquid Editions will only exist as the ERC20 artwork. Others may also include an ERC721 collection.

This is still a living prototype. Features may evolve over time.  Reach out to support@superrare.com if you have any questions.

## The Artistic Spirit

Liquid Editions can technically support plain NFT patterns. An artist could point `tokenURI()` at IPFS and ship a static image, animation, or webpage. That is valid.

But the protocol is most interesting when the market is treated as artistic material, not just as commerce around the work.

In Liquid Editions:

- price can be part of the picture
- liquidity can be part of the composition
- supply, burns, transfers, and balances can become inputs, thresholds, rhythms, or narrative beats
- one market object can support multiple visual interpretations without fragmenting the underlying edition

The ambition is not just to attach art to a token and let people trade it. The ambition is to let artists use market behavior itself as a medium.

So while the sky is the limit, or even static metadata is technically allowed, the spirit of the protocol is generative art that reads, interprets, and responds to live on-chain state.

That does not mean every project needs to be hyper-reactive. A strong Liquid Edition can be quiet, sparse, slow-moving, or highly constrained. What matters is that the relationship between the visual surface and the market surface feels intentional.

## Quick Glossary

- `ERC20`: the Liquid Edition token itself
- `ERC721`: an optional companion NFT collection
- `render contract`: a contract that returns metadata from `tokenURI()`
- `tokenURI`: the metadata endpoint clients fetch

## AI Skills

This repo includes reusable AI workflow guides under `skills/`:

- `skills/liquid-render-builder/SKILL.md` for designing and implementing render contracts
- `skills/liquid-render-deployer/SKILL.md` for deploying and registering them

They are written as shared repo guidance, not as a feature tied to any one model provider.

Different agent tools may load or reference them in different ways, but the underlying skill content is intentionally provider-neutral and tuned to this starter kit's examples, interfaces, scripts, and current product constraints.

## Render Contract Patterns

A Liquid Edition can register only one render contract address.

That means there are two main patterns artists should think about:

- a render-only contract that returns `tokenURI()` and has no ERC721 minting features
- a single contract that is both the registered render contract and an ERC721, returning both `tokenURI()` and `tokenURI(uint256)`

This starter kit demonstrates both:

- `LiquidLensHTMLExample.sol` is the render-only pattern
- `LiquidLensMintable721SVGExample.sol` is the combined renderer-plus-ERC721 pattern

## Included Examples

This starter keeps the example surface intentionally small:

- `src/examples/LiquidLensHTMLExample.sol`
- `src/examples/LiquidLensMintable721SVGExample.sol`  

### `LiquidLensHTMLExample`

Single-artwork example.

- exposes `tokenURI()`
- intended to be registered directly on a Liquid token
- returns standard NFT metadata JSON
- uses `animation_url` for HTML output
- includes an SVG preview in `image`

Use this when you want one dynamic artwork attached to the Liquid Edition itself.

### `LiquidLensMintable721SVGExample`

Mintable ERC721 example.

- exposes `tokenURI()` for Liquid Edition passthrough
- exposes `tokenURI(uint256 tokenId)` for the companion collection
- supportsInterface for ERC721
- returns standard NFT metadata JSON
- outputs SVG
- supports minting NFTs from the same contract

Use this when you want the Liquid token plus a companion collectible lens collection.

## What Artists Can Ship

### ERC20-only

Your Liquid token's `tokenURI()` can point at a render contract you control.

That render contract can be a simple render-only contract. It can return standard NFT metadata JSON with:

- `image` as `data:image/svg+xml;base64,...`
- `image` as a normal URL
- `animation_url` for HTML artifacts
- optional `attributes`

This is enough for the Liquid token itself to be "the work."

### ERC20 + ERC721

Because only one render contract can be registered, the clearest ERC20 + ERC721 pattern is to make that same registered contract also implement ERC721 and expose `tokenURI(uint256 tokenId)`.

If it does, we can treat that contract as both:

- the Liquid render contract for `tokenURI()`
- the companion ERC721 collection for `tokenURI(uint256 tokenId)`

In that case:

- `tokenURI()` is the Liquid passthrough view
- `tokenURI(tokenId)` is the NFT lens view

Each NFT can be a different lens over the same state:

- different mappings
- different thresholds
- different narratives
- different visual systems
- different mint or access rules

## Metadata + Media Support

The output should be standard NFT metadata JSON.

In practice, that means fields like:

- `name`
- `description`
- `image`
- optional `animation_url`
- optional `external_url`
- optional `attributes`

Supported media, in spirit and in product, include:

- SVG
- HTML
- images
- video
- GIFs

These are still just standard NFTs. The main difference is that the metadata can be generated from on-chain Liquid state at read time.

This starter leans toward HTML and SVG because the project is most interesting when the work is rendered directly from on-chain state.

## Reserve Currency

The reserve currency is RARE. The Liquid Edition will be paired with RARE as its base token in the liquidity pool. 

## Current Deployments

Useful canonical addresses for this starter kit:

### Ethereum Mainnet

- `RARE`: `0xba5BDe662c17e2aDFF1075610382B9B691296350`
- `Liquid Factory`: `0xd3D8Ca76E8c5547694106378B6e471B4AC8EFC63`

### Ethereum Sepolia

- `RARE`: `0x197FaeF3f59eC80113e773Bb6206a17d183F97CB`
- `Liquid Factory`: `0xfD18C0D99e5b6F89F3538806241C2C0d6FD728Ac`

## What Is Guaranteed vs Evolving

Guaranteed:

- the Liquid Edition contracts onchain
- the state exposed by the contracts
- the fact that render contracts are fetched via `tokenURI()`

Evolving:

- UI / UX
- how artwork is surfaced in product
- how balances, collections, and views are presented

The safe assumption for artists is: the blockchain is the durable layer, and the UI is a rapidly evolving interpretation layer.

## Current Data Surface

The example contracts in this repo read directly from `ILiquid`.

Most useful dynamic values:

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

Fixed / identity values:

- `name()`
- `symbol()`
- `tokenCreator()`
- `baseToken()`

The example contracts focus on the simplest current surface:

- `name()`
- `symbol()`
- `tokenCreator()`
- `maxTotalSupply()`
- `getMarketState()`

That is the core state surface artists should design against first.

`quoteBuy()` and `quoteSell()` are optional. They are mainly useful when you want quote-at-size behavior, spread proxies, or slippage-aware render logic.

## Rendering + Refresh Semantics

Updates are pull-based.

- clients fetch metadata via `tokenURI()`
- our systems refresh metadata on every relevant Liquid Edition state change
- metadata is also refreshed if the companion ERC721 emits `MetadataUpdated`
- there is no push-based rendering path from Liquid into the render contract

The easiest dynamic behavior is pure view logic:

- state changes onchain
- metadata is refetched
- the artwork changes because the view logic reads the new state

If you want stateful behavior such as:

- minting
- claiming
- unlocking
- freezing
- revoking
- changing custom ERC721 state

someone still has to submit a transaction. Nothing stateful happens automatically just because the market moved.

## Custom Mechanics and UI Support

We support the normal market actions around the system:

- buying and selling the Liquid Edition
- buying and selling ERC721 tokens through standard marketplace flows

Artists are still free to add custom functions and mechanics to their contracts.

That might include:

- special mint flows
- claims
- burns
- unlocks
- freezes
- transfer restrictions
- other project-specific behaviors

But those custom mechanics are not automatically supported in the SuperRare UI.

For example, if an artist creates a mechanic like "burn your Liquid Edition Tokens to mint an NFT," that can absolutely exist onchain, but it would need to be triggered somewhere outside the current SuperRare UI unless we explicitly build support for it.

So the practical rule is:

- custom mechanics are welcome
- standard metadata and standard trading flows are what the platform guarantees today
- anything beyond that should be exposed by the artist through their own site, script, app, or contract interface

Strong custom patterns are still useful. If artists develop mechanics that are compelling and legible, they may inform future product support or become standard UI flows later.

## Derived Data Ideas

From the current surface, artists can derive more expressive signals such as:

- market cap
- fully diluted value
- burned supply
- burn rate
- spread proxies
- price impact estimates
- distance to LP bounds
- bonding-curve progress
- holder concentration
- artist holdings value

The examples in this repo are intentionally literal. They are demos, not limits.

## ERC721 Lens Design Space

Artists control their ERC721 lens contracts.

That can include:

- custom mint logic
- distribution pathways
- unlock rules
- transfer restrictions
- decay
- revocation
- finish states
- multiple visual interpretations over the same market state

The main caveat is collector legibility. Surprise is useful; confusion is expensive. Highly nonstandard behavior may also run into UI limitations.

## Finish States

Baseline assumption: the work can continue evolving as state changes.

But artists can encode a terminal condition entirely in render logic, for example:

- stop changing after a burn threshold
- stop changing after a tick threshold
- freeze after supply drops below a line

Nothing breaks if the work stops changing. That is still a valid authored choice.

## Quick Start

### 1. Create your Liquid Edition on Sepolia first

Before you build a render contract in this repo, the easiest path is to create your Liquid Edition in the SuperRare dev UI:

- [dev.superrare.com/create/liquid-edition](https://dev.superrare.com/create/liquid-edition)

This starter kit is primarily for the render contract that you attach afterward. In practice, the easiest flow is:

1. Create the Liquid Edition on Sepolia in the dev UI.
2. Copy the deployed Liquid Edition contract address.
3. Put that address into `LIQUID_EDITION_ADDRESS` in this repo.
4. Build, deploy, and register your render contract from this repo.

Once your render contract is registered, you can immediately inspect how the Liquid Edition renders in the UI at:

- `https://dev.superrare.com/liquid-editions/11155111/<liquidEditionContractAddress>`

Replace `<liquidEditionContractAddress>` with your Sepolia Liquid Edition address. `11155111` is the Sepolia chain ID in the URL.

### 2. Copy env vars

```bash
cp .env.eth.sepolia .env
```

At minimum set:

```bash
DEPLOYER_PRIVATE_KEY=
RPC_URL=
LIQUID_EDITION_ADDRESS=
```

When you are ready for production:

```bash
cp .env.eth.mainnet .env
```

Then set:

```bash
DEPLOYER_PRIVATE_KEY=
RPC_URL=
LIQUID_EDITION_ADDRESS=
```

For `LiquidLensHTMLExample`:

```bash
LENS_NAME="Liquid Lens HTML Example"
LENS_DESCRIPTION="Single artwork Liquid lens example using HTML metadata."
LENS_EXTERNAL_URL=
AUTO_REGISTER_RENDER=true
```

For `LiquidLensMintable721SVGExample`:

```bash
NFT_NAME="Liquid Lens Mintable 721 SVG Example"
NFT_SYMBOL=LL721
NFT_DESCRIPTION="Mintable ERC721 Liquid lens example using SVG metadata."
NFT_EXTERNAL_URL=
NFT_MAX_SUPPLY=128
```

### 3. Build and test

```bash
forge build
forge test -vv
```

### 4. Choose a Path

If you are not sure where to start:

- pick `LiquidLensHTMLExample.sol` if you want one dynamic artwork attached to the Liquid token
- pick `LiquidLensMintable721SVGExample.sol` if you want a companion collectible NFT series

If you are less technical, you can ignore most of the system at first and just focus on:

- `getMarketState()`
- color
- composition
- text
- whether the work changes over time

## Deployment

This repo assumes you already have a Liquid Edition address to target.

For Sepolia, the recommended setup is:

1. Create the Liquid Edition at `dev.superrare.com/create/liquid-edition`.
2. Set `LIQUID_EDITION_ADDRESS` in `.env` to that deployed Liquid Edition address.
3. Deploy your render contract from this repo.
4. Register the render contract on the Liquid Edition.
5. Open `https://dev.superrare.com/liquid-editions/11155111/<liquidEditionContractAddress>` to verify the render in the UI.

If you prefer, you can still create Liquid Editions through lower-level contract workflows, but that is not the easiest starting path for most users of this starter kit.

### Deploy `LiquidLensHTMLExample`

```bash
source .env
forge script script/DeployLiquidLensHTMLExample.s.sol:DeployLiquidLensHTMLExample --rpc-url $RPC_URL --broadcast
```

### Deploy `LiquidLensMintable721SVGExample`

```bash
source .env
forge script script/DeployLiquidLensMintable721SVGExample.s.sol:DeployLiquidLensMintable721SVGExample --rpc-url $RPC_URL --broadcast
```

### Register an already deployed render contract

```bash
source .env
forge script script/RegisterRenderContract.s.sol:RegisterRenderContract --rpc-url $RPC_URL --broadcast
```

If `AUTO_REGISTER_RENDER=true` and the broadcaster is also the Liquid token creator, the deploy scripts will register automatically.

## Manually Setting The Render Contract

Only the token creator can set the render contract.

Minimum requirement:

- `tokenURI()` must return standard NFT metadata JSON

Optional companion collection:

- `tokenURI(uint256 tokenId)` for ERC721 lens metadata if the registered render contract also implements ERC721

Using `cast`:

```bash
cast send $LIQUID_TOKEN_ADDRESS \
  "setRenderContract(address)" \
  $RENDER_CONTRACT_ADDRESS \
  --rpc-url $RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY
```

To verify:

```bash
cast call $LIQUID_TOKEN_ADDRESS \
  "renderContract()(address)" \
  --rpc-url $RPC_URL
```

To clear the render contract and fall back to static metadata:

```bash
cast send $LIQUID_TOKEN_ADDRESS \
  "setRenderContract(address)" \
  0x0000000000000000000000000000000000000000 \
  --rpc-url $RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY
```

## What To Customize

For the HTML example, start inside:

- `tokenURI()`
- `_renderPreviewSvg`
- `_renderHtmlPage`

For the mintable 721 SVG example, start inside:

- `tokenURI()`
- `tokenURI(uint256)`
- `_renderSvg`
- `_bars`
- `_copy`

Because the contracts are intentionally standalone, the simplest workflow is to pick one file and edit it directly.

If you are vibe coding, a good first prompt is:

"Treat the Liquid token as a market-driven art input. Read `getMarketState()` and `getLaunchState()` directly. Return standard NFT metadata JSON. Keep the first version simple and legible."

Another good first prompt is:

"Map one or two market variables to visible changes first. Do not invent extra mechanics until the base artwork already works."

## Local Iteration

Use `MockLiquid` for quick iteration in tests. It lets you:

- change market state
- change launch state
- register a render contract
- verify Liquid passthrough behavior

Starter coverage lives in:

- `test/LiquidLensExamples.t.sol`

## Why `ILiquidFactory` Is Still Included

The examples themselves are focused on `ILiquid`, but `ILiquidFactory` is still useful for:

- reference
- scripts
- creators who want lower-level token creation workflows from the same repo
- local tests that create a Liquid Edition before attaching a renderer
- end-to-end automation where token creation and render deployment happen in one flow

For most users, the easiest way to get a Sepolia Liquid Edition is still:

- create it first in `dev.superrare.com/create/liquid-edition`
- then use this repo to build and register the render contract

## Suggested Fork Workflow

1. Fork the repo.
2. Create your Liquid Edition on Sepolia at `dev.superrare.com/create/liquid-edition`.
3. Copy that Liquid Edition contract address into `LIQUID_EDITION_ADDRESS`.
4. Pick the closer example contract.
5. Rename the contract to your project name.
6. Keep the relevant metadata entrypoints intact.
7. Update or add tests.
8. Deploy the renderer to Sepolia first.
9. Register the renderer on the target Liquid token.
10. Verify the result in `https://dev.superrare.com/liquid-editions/11155111/<liquidEditionContractAddress>`.
11. Move to mainnet after validating output.
