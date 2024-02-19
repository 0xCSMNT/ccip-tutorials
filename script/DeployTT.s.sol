// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console2} from "forge-std/Script.sol";
import {TokenTransferor} from "../src/TokenTransferor.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployTT is Script {
    TokenTransferor public tokenTransferor;

    function run() external {
        // Before startBroadcast, not a real transaction
        HelperConfig helperConfig = new HelperConfig();
        
        // Directly destructure the returned tuple from the getter
        (
            address router,
            address linkToken,
            uint64 destinationChainId
        ) = helperConfig.activeNetworkConfig();

        // After startBroadcast, real transaction
        vm.startBroadcast();
        tokenTransferor = new TokenTransferor(
            address(router),
            address(linkToken)
        );
        tokenTransferor.allowlistDestinationChain(
            uint64(destinationChainId),
            bool(true)
        );

        vm.stopBroadcast();
    }
}
