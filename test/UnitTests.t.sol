// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {TokenTransferor} from "../src/TokenTransferor.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {MockCCIPRouter} from "test/mock/MockRouter.sol";
import {MockLinkToken, MockCCIPBnMToken} from "test/mock/DummyTokens.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract UnitTests is StdCheats, Test {
    TokenTransferor public tokenTransferor;
    MockCCIPRouter public router;
    MockLinkToken public linkToken;
    MockCCIPBnMToken public ccipBnM;

    ////////// CONSTANTS //////////
    uint256 public constant TOKEN_MINT_BALANCE = 100e18;
    uint256 public constant TOKEN_TRANSFER_AMOUNT = 10e18;
    address public constant DEV_ACCOUNT_0 =
        0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address public constant DEV_ACCOUNT_1 =
        0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address public constant DEV_ACCOUNT_2 =
        0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;

    ////////// SETUP //////////
    function setUp() external {
        router = new MockCCIPRouter();
        linkToken = new MockLinkToken();
        ccipBnM = new MockCCIPBnMToken();

        tokenTransferor = new TokenTransferor(
            address(router),
            address(linkToken)
        );

        tokenTransferor.allowlistDestinationChain(12532609583862916517, true);
    }

    ////////// HELPER FUNCTIONS //////////
    // transfer mocklink and mockccipbnm tokens to token transferor from dev account 0
    function transferTokensToTokenTransferor() public {
        vm.startPrank(DEV_ACCOUNT_0);

        linkToken.transfer(address(tokenTransferor), TOKEN_MINT_BALANCE);
        ccipBnM.transfer(address(tokenTransferor), TOKEN_MINT_BALANCE);

        vm.stopPrank();
    }

    ////////// TEST FUNCTIONS //////////
    function testCorrectDestinationChainId() public {
        //check that the destination chain id is correct on TokenTransferor
        assertTrue(
            tokenTransferor.allowlistedChains(12532609583862916517),
            "Destination chain id is not correctly allowlisted"
        );
    }

    function testTransferTokensHasTokens() public {
        transferTokensToTokenTransferor();
        uint256 linkBalance = linkToken.balanceOf(address(tokenTransferor));
        uint256 ccipBnMBalance = ccipBnM.balanceOf(address(tokenTransferor));
        assertTrue(
            linkBalance == TOKEN_MINT_BALANCE,
            "TokenTransferor does not have the correct amount of link tokens"
        );
        console2.log("linkBalance: ", linkBalance / 1e18);
        console2.log("TOKEN_MINT_BALANCE: ", TOKEN_MINT_BALANCE / 1e18);
        assertTrue(
            ccipBnMBalance == TOKEN_MINT_BALANCE,
            "TokenTransferor does not have the correct amount of ccipBnM tokens"
        );
    }
}
