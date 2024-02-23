This project was built using Foundry.

It's not a real project, more just some tests so I can understand how local testing works with CCIP. As such, it is messy and some earlier test that worked are now broken as I refactored contracts.

You can ignore 90% of it.

The last test was to send a token transfer, as well as a function call with argument on another contract. It's passing and looks good in the traces so I think I solved it.

```solidity
forge test --match-test testIncreaseStorageOverCCIP -vvvv
```
