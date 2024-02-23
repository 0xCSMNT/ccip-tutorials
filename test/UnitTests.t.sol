// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {TokenTransferor} from "../src/TokenTransferor.sol";
import {ProgrammableTokenTransfers} from "../src/ProgrammableTokenTransfers.sol";
import {TransferorWithCalls} from "../src/TransferorWithCalls.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {MockCCIPRouter} from "test/mock/MockRouter.sol";
import {MockLinkToken, MockCCIPBnMToken} from "test/mock/DummyTokens.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SimpleStorage} from "test/mock/SimpleStorage.sol";

contract UnitTests is StdCheats, Test {
    TokenTransferor public tokenTransferor;
    ProgrammableTokenTransfers public receiver;
    ProgrammableTokenTransfers public sender;
    TransferorWithCalls public receiverWithCalls;
    TransferorWithCalls public senderWithCalls;
    MockCCIPRouter public router;
    MockLinkToken public linkToken;
    MockCCIPBnMToken public ccipBnM;
    SimpleStorage public storageContract;

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
        storageContract = new SimpleStorage();

        tokenTransferor = new TokenTransferor(
            address(router),
            address(linkToken)
        );

        receiver = new ProgrammableTokenTransfers(
            address(router),
            address(linkToken),
            address(storageContract)
        );

        sender = new ProgrammableTokenTransfers(
            address(router),
            address(linkToken),
            address(storageContract)
        );

        receiverWithCalls = new TransferorWithCalls(
            address(router),
            address(linkToken)
        );

        senderWithCalls = new TransferorWithCalls(
            address(router),
            address(linkToken)
        );

        tokenTransferor.allowlistDestinationChain(12532609583862916517, true);
        
        sender.allowlistDestinationChain(12532609583862916517, true);
        receiver.allowlistSourceChain(16015286601757825753, true);
        receiver.allowlistSender(address(sender), true);

        senderWithCalls.allowlistDestinationChain(12532609583862916517, true);
        receiverWithCalls.allowlistSourceChain(16015286601757825753, true);
        receiverWithCalls.allowlistSender(address(senderWithCalls), true);
    }

    ////////// HELPER FUNCTIONS //////////
    // transfer mocklink and mockccipbnm tokens to token transferor from dev account 0
    function transferTokensToTokenTransferor() public {
        vm.startPrank(DEV_ACCOUNT_0);

        linkToken.transfer(address(tokenTransferor), TOKEN_MINT_BALANCE);
        ccipBnM.transfer(address(tokenTransferor), TOKEN_MINT_BALANCE);

        vm.stopPrank();
    }

    function transferTokensToSender() public {
        vm.startPrank(DEV_ACCOUNT_0);

        linkToken.transfer(address(sender), TOKEN_MINT_BALANCE);
        ccipBnM.transfer(address(sender), TOKEN_MINT_BALANCE);

        vm.stopPrank();
    }

    function transferTokensToSenderWithCalls() public {
        vm.startPrank(DEV_ACCOUNT_0);

        linkToken.transfer(address(senderWithCalls), TOKEN_MINT_BALANCE);
        ccipBnM.transfer(address(senderWithCalls), TOKEN_MINT_BALANCE);

        vm.stopPrank();
    }

    function trasferTokensToReceiverWithCalls() public {
        vm.startPrank(DEV_ACCOUNT_0);

        linkToken.transfer(address(receiverWithCalls), TOKEN_MINT_BALANCE);
        ccipBnM.transfer(address(receiverWithCalls), TOKEN_MINT_BALANCE);

        vm.stopPrank();
    }

    function addressToString(
        address _addr
    ) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(_addr)));
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(42); // 2 character prefix + 40 characters for the address
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }

    ////////// TEST FUNCTIONS //////////
    function testCorrectDestinationChainId() public {
        //check that the destination chain id is correct on TokenTransferor
        assertTrue(
            tokenTransferor.allowlistedChains(12532609583862916517),
            "Destination chain id is not correctly allowlisted"
        );
    }

    function testCorrectAddressesForRouterAndLinkToken() public {
        //check that the router and link token addresses are correct on TokenTransferor
        assertTrue(
            address(router) == tokenTransferor.getRouterAddress(),
            "Router address is not correct"
        );
        assertTrue(
            address(linkToken) == tokenTransferor.getLinkTokenAddress(),
            "Link token address is not correct"
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
        console2.log("TokenTransferorCCIPBnMBalance: ", ccipBnMBalance / 1e18);
        console2.log("TokenTransferorLinkBalance: ", linkBalance / 1e18);
        console2.log("TOKEN_MINT_BALANCE: ", TOKEN_MINT_BALANCE / 1e18);
        assertTrue(
            ccipBnMBalance == TOKEN_MINT_BALANCE,
            "TokenTransferor does not have the correct amount of ccipBnM tokens"
        );
    }

    function testSenderHasTokens() public {
        transferTokensToSender();
        uint256 linkBalance = linkToken.balanceOf(address(sender));
        uint256 ccipBnMBalance = ccipBnM.balanceOf(address(sender));
        assertTrue(
            linkBalance == TOKEN_MINT_BALANCE,
            "Sender does not have the correct amount of link tokens"
        );
        assertTrue(
            ccipBnMBalance == TOKEN_MINT_BALANCE,
            "Sender does not have the correct amount of ccipBnM tokens"
        );
    }

    function testTransferTokenPayLINK() public {
        transferTokensToTokenTransferor();
        tokenTransferor.transferTokensPayLINK(
            uint64(12532609583862916517),
            address(receiver),
            address(ccipBnM),
            uint256(TOKEN_TRANSFER_AMOUNT)
        );

        // Log balances in wei for clarity and direct comparison
        uint256 receiverBalance = ccipBnM.balanceOf(address(receiver));
        uint256 tokenTransferorBalance = ccipBnM.balanceOf(
            address(tokenTransferor)
        );

        console2.log("Receiver Balance: ", receiverBalance / 1e18);
        console2.log("TOKEN_TRANSFER_AMOUNT: ", TOKEN_TRANSFER_AMOUNT / 1e18);
        console2.log(
            "TokenTransferor balance: ",
            tokenTransferorBalance / 1e18
        );

        // Assert that DEV_ACCOUNT_1's balance matches the expected transfer amount
        assertEq(
            receiverBalance,
            TOKEN_TRANSFER_AMOUNT,
            "receiver did not receive the expected amount of tokens."
        );
    }

    // Test that the sender can transfer tokens and message to the receiver
    function testSendMessagePayLINK() public {
        transferTokensToSender();
        string memory messageSent = "Hello, World!";
        sender.sendMessagePayLINK(
            uint64(12532609583862916517),
            address(receiver),
            string(messageSent),
            address(ccipBnM),
            uint256(TOKEN_TRANSFER_AMOUNT)
        );

        (, string memory messageReceived, , uint256 tokensReceived) = receiver
            .getLastReceivedMessageDetails();

        console2.log("Message Received: ", messageReceived);
        console2.log("TokensReceived: ", tokensReceived / 1e18);

        assertEq(
            messageReceived,
            messageSent,
            "Message received by receiver does not match the message sent by sender"
        );

        assertEq(
            tokensReceived,
            TOKEN_TRANSFER_AMOUNT,
            "receiver did not receive the expected amount of tokens."
        );
    }

    // Test that the sender can call a read function on the receiver
    function testGetTokenBalanceOnReceiver() public {
        transferTokensToSenderWithCalls();
        
        string memory messageSent = "getTokenBalance(address)";
        senderWithCalls.sendMessagePayLINK(
            uint64(12532609583862916517),
            address(receiverWithCalls),
            string(messageSent),
            address(ccipBnM),
            uint256(TOKEN_TRANSFER_AMOUNT)
        );
        receiverWithCalls.getLastReceivedMessageDetails();
        uint256 balance = receiverWithCalls.getTokenBalance(address(ccipBnM));
        console2.log("Receiver Balance: ", balance);
        assertEq(
            balance,
            TOKEN_TRANSFER_AMOUNT,
            "Receiver does not have the correct amount of tokens"
        );
    }

    function testDirectCallForTokenBalance() public {
        trasferTokensToReceiverWithCalls();
        uint256 balance = receiverWithCalls.getTokenBalance(address(ccipBnM));
        console2.log("Receiver Balance: ", balance);
        assertEq(
            balance,
            TOKEN_MINT_BALANCE,
            "Receiver does not have the correct amount of tokens"
        );
    }

    function testCallGetReceiverEthBalance() public {
        trasferTokensToReceiverWithCalls();
        vm.deal(address(receiverWithCalls), TOKEN_MINT_BALANCE);
        uint256 balance = receiverWithCalls.getEthBalance();
        console2.log("Receiver Ether Balance: ", balance);
        assertEq(
            balance,
            TOKEN_MINT_BALANCE,
            "Receiver does not have the correct amount of ether"
        );
    }

    function testDirectCall_getEthBalance_NoCCIP() public {
        vm.deal(address(receiver), TOKEN_MINT_BALANCE);
        uint256 balance = receiver.getEthBalance();
        console2.log("Receiver Balance: ", balance);
        assertEq(
            balance,
            TOKEN_MINT_BALANCE,
            "Receiver does not have the correct amount of tokens"
        );
    }

    function testCall_getEthBalance_OverCCIP() public {
        vm.deal(address(receiver), TOKEN_MINT_BALANCE);
        transferTokensToSender();
        string memory messageSent = "getEthBalance()";
        sender.sendMessagePayLINK(
            uint64(12532609583862916517),
            address(receiver),
            string(messageSent),
            address(ccipBnM),
            uint256(TOKEN_TRANSFER_AMOUNT)
        );

    }
    function testSetAndRetrieveStorageDirectly() public {
        storageContract.store(100);
        uint256 storedValue = storageContract.retrieve();
        console2.log("Stored Value: ", storedValue);
        assertEq(storedValue, 100, "Stored value is not correct");
    }

    function testIncreaseStorageOverCCIP() public {
        storageContract.store(123);
        vm.deal(address(receiver), TOKEN_MINT_BALANCE);
        transferTokensToSender();
        string memory messageSent = "store(uint256)";
        sender.sendMessagePayLINK(
            uint64(12532609583862916517),
            address(receiver),
            string(messageSent),
            address(ccipBnM),
            uint256(TOKEN_TRANSFER_AMOUNT)
        );
        assertEq(storageContract.retrieve(), TOKEN_TRANSFER_AMOUNT, "Stored value is not correct");
    }
}
