.PHONY: build test fmt deploy-lens-html deploy-lens-721-svg register

build:
	forge build

test:
	forge test -vv

fmt:
	forge fmt

deploy-lens-html:
	forge script script/DeployLiquidLensHTMLExample.s.sol:DeployLiquidLensHTMLExample --rpc-url $$RPC_URL --broadcast

deploy-lens-721-svg:
	forge script script/DeployLiquidLensMintable721SVGExample.s.sol:DeployLiquidLensMintable721SVGExample --rpc-url $$RPC_URL --broadcast

register:
	forge script script/RegisterRenderContract.s.sol:RegisterRenderContract --rpc-url $$RPC_URL --broadcast
