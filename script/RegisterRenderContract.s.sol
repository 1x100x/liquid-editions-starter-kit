// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {console2} from "forge-std/console2.sol";
import {Script} from "forge-std/Script.sol";

import {ILiquid} from "../src/interfaces/ILiquid.sol";

contract RegisterRenderContract is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address liquidEditionAddress = vm.envAddress("LIQUID_EDITION_ADDRESS");
        address renderContractAddress = vm.envAddress("RENDER_CONTRACT_ADDRESS");

        console2.log("Registering render contract");
        console2.log("liquid edition", liquidEditionAddress);
        console2.log("render contract", renderContractAddress);

        vm.startBroadcast(deployerPrivateKey);
        ILiquid(liquidEditionAddress).setRenderContract(renderContractAddress);
        vm.stopBroadcast();

        console2.log("render contract registered");
    }
}
