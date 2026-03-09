// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {console2} from "forge-std/console2.sol";
import {Script} from "forge-std/Script.sol";

import {LiquidLensMintable721SVGExample} from "../src/examples/LiquidLensMintable721SVGExample.sol";
import {ILiquid} from "../src/interfaces/ILiquid.sol";

contract DeployLiquidLensMintable721SVGExample is Script {
    function run()
        external
        returns (LiquidLensMintable721SVGExample example)
    {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address liquidEditionAddress = vm.envAddress("LIQUID_EDITION_ADDRESS");
        string memory nftName = _envOrString(
            "NFT_NAME",
            "Liquid Lens Mintable 721 SVG Example"
        );
        string memory nftSymbol = _envOrString("NFT_SYMBOL", "LL721");
        string memory nftDescription = _envOrString(
            "NFT_DESCRIPTION",
            "Mintable ERC721 Liquid lens example using SVG metadata."
        );
        string memory nftExternalUrl = _envOrString("NFT_EXTERNAL_URL", "");
        uint256 nftMaxSupply = _envOrUint("NFT_MAX_SUPPLY", 128);
        bool autoRegister = _envOrBool("AUTO_REGISTER_RENDER", true);

        ILiquid liquid = ILiquid(liquidEditionAddress);
        address deployer = vm.addr(deployerPrivateKey);
        address creator = liquid.tokenCreator();

        vm.startBroadcast(deployerPrivateKey);
        example = new LiquidLensMintable721SVGExample(
            liquidEditionAddress,
            nftName,
            nftSymbol,
            nftDescription,
            nftExternalUrl,
            nftMaxSupply
        );

        console2.log("deployer", deployer);
        console2.log("liquid edition", liquidEditionAddress);
        console2.log("liquid creator", creator);
        console2.log(
            "deployed LiquidLensMintable721SVGExample",
            address(example)
        );

        if (autoRegister && deployer == creator) {
            liquid.setRenderContract(address(example));
            console2.log("render registered on Liquid token");
        } else if (autoRegister) {
            console2.log("auto-register skipped: deployer is not token creator");
        } else {
            console2.log("auto-register disabled");
        }

        vm.stopBroadcast();
    }

    function _envOrString(
        string memory key,
        string memory fallbackValue
    ) internal view returns (string memory) {
        try vm.envString(key) returns (string memory envValue) {
            return envValue;
        } catch {
            return fallbackValue;
        }
    }

    function _envOrUint(
        string memory key,
        uint256 fallbackValue
    ) internal view returns (uint256) {
        try vm.envUint(key) returns (uint256 envValue) {
            return envValue;
        } catch {
            return fallbackValue;
        }
    }

    function _envOrBool(
        string memory key,
        bool fallbackValue
    ) internal view returns (bool) {
        try vm.envBool(key) returns (bool envValue) {
            return envValue;
        } catch {
            return fallbackValue;
        }
    }
}
