// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {console2} from "forge-std/console2.sol";
import {Script} from "forge-std/Script.sol";

import {LiquidLensHTMLExample} from "../src/examples/LiquidLensHTMLExample.sol";
import {ILiquid} from "../src/interfaces/ILiquid.sol";

contract DeployLiquidLensHTMLExample is Script {
    function run() external returns (LiquidLensHTMLExample example) {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address liquidEditionAddress = vm.envAddress("LIQUID_EDITION_ADDRESS");
        string memory lensName = _envOrString(
            "LENS_NAME",
            "Liquid Lens HTML Example"
        );
        string memory lensDescription = _envOrString(
            "LENS_DESCRIPTION",
            "Single artwork Liquid lens example using HTML metadata."
        );
        string memory lensExternalUrl = _envOrString(
            "LENS_EXTERNAL_URL",
            ""
        );
        bool autoRegister = _envOrBool("AUTO_REGISTER_RENDER", true);

        ILiquid liquid = ILiquid(liquidEditionAddress);
        address deployer = vm.addr(deployerPrivateKey);
        address creator = liquid.tokenCreator();

        vm.startBroadcast(deployerPrivateKey);
        example = new LiquidLensHTMLExample(
            liquidEditionAddress,
            lensName,
            lensDescription,
            lensExternalUrl
        );

        console2.log("deployer", deployer);
        console2.log("liquid edition", liquidEditionAddress);
        console2.log("liquid creator", creator);
        console2.log("deployed LiquidLensHTMLExample", address(example));

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
