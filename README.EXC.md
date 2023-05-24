# GPTdodahExchange Contract

The GPTdodahExchange contract facilitates the exchange of WETH (Wrapped Ether) for GPTdodah tokens. It integrates with the Uniswap decentralized exchange to provide liquidity and allows users to purchase GPTdodah tokens with WETH. Additionally, it supports the wrapping and unwrapping of ETH/WETH.

## Contracts and Dependencies

The GPTdodahExchange contract relies on the following external dependencies:

- OpenZeppelin Contracts: Provides standard ERC20 token functionality and safe transfer operations.
- Uniswap: Interfaces with the Uniswap decentralized exchange for adding liquidity to the GPTdodah token.

## Contract Overview

The GPTdodahExchange contract allows users to:

- Buy GPTdodah tokens with ETH.
- Withdraw funds from the contract to the Treasury with AC.

The key functionalities and interactions of the contract are as follows:

- `buyTokens() payable`: Allows users to purchase GPTdodah tokens by sending ETH directly to the contract.

- `withdraw()`: Allows the acting `ADMIN_ROLE` to withdraw the remaining funds to the Team treasury.

## Configuration and Deployment

The GPTdodahExchange contract requires the following parameters to be provided during deployment:

- `_gptdodahToken`: The address of the GPTdodah token contract.
- `_uniswapRouter`: The address of the Uniswap router contract.
- `_gptDoDahTreasury`: The address of the team treasury where ETH/WETH is transferred.

## Events

The GPTdodahExchange contract emits the following events:

- `TokenPurchase(address indexed buyer, uint256 amount)`: Indicates the successful purchase of GPTdodah tokens by a buyer.
- `Withdrawal(uint256 amount, uint256 timestamp)`: Indicates the withdrawal of funds from the contract, specifying the amount and the timestamp of the withdrawal.

Please note that the contract also includes access control, where certain functions can only be executed by the contract owner.

- `withdraw()`: This function allows the contract owner to withdraw the remaining funds to the Treasury contract. Only the acting `ADMIN_ROLE` of the contract can call this function.

- `receive() external payable`: This fallback function allows the contract to accept ETH sent directly to it.

## Usage and Interactions

The GPTdodahExchange contract enables users to exchange WETH or ETH for GPTdodah tokens. Here's an overview of the typical interactions:

- Deployment: Deploy the GPTdodahExchange contract by providing the necessary parameters, including the addresses of the GPTdodah token, Uniswap router, GPTdoDAO, DAO treasury, and team treasury. Make sure to transfer an initial supply of GPTdodah tokens to the contract.

- Buying Tokens: Users can purchase GPTdodah tokens by calling buyTokens(). They need to provide the required amount of ETH above the minimum threshold. The contract interacts with the Uniswap router to add liquidity by executing `addLiquidityETH()` and sending half of the purchase to the pool along with 1/20 of the purchased token amount. The function then transfers the purchased tokens to the buyer.

- Withdrawal: The contract owner can call the withdraw() function to withdraw the remaining funds to the treasury contract.

Please note that certain functions, such as withdraw(), can only be executed by the acting `ADMIN_ROLE` role.

It's essential to review and understand the contract's code and its dependencies to ensure secure and accurate usage.

Please note that this README provides a high-level overview of the contract and its interactions. It's recommended to review the contract's code, dependencies, and comments for a more comprehensive understanding of the implementation and functionalities.
