// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console2} from "forge-std/Script.sol";
import {TokenTransferor} from "../src/TokenTransferor.sol";

// SEPOLIA TESTNET ADDRESS
address constant router = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;
address constant linkToken = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
uint64 constant destinationChainId = 12532609583862916517;

contract DeployTT is Script {
    TokenTransferor public tokenTransferor;

    function run() external {
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
