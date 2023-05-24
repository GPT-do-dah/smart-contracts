# Blockchain Smart Contracts: The Backbone of GPT-do-dah

At the core of the GPT-do-dah ecosystem is the implementation of smart contracts hosted on the Ethereum blockchain.

These smart contracts govern the interactions between users,
agents, and data providers, and manage the distribution and exchange of ERC-20 tokens and NFTs.

They are vital in achieving a transparent, decentralized,
and secure system of value exchange and community governance within the [panopticon styled community managed network](https://gptdodah.com/blog/gpt-panopticon).

The contracts integrate several extensions from OpenZeppelin,
a framework providing secure and community-audited smart contract templates (1).

As the GPT-do-dah project continues to develop and evolve, it has the potential to become a powerful force for promoting decentralization, transparency, and empowerment in the realm of project management and collaboration.

## Phase 1

To bootstrap the GPT-do-dah ecosystem for phase 1, the initial GPTD coin is created and the totaly supply is sent to an exchange contract. This exchange contract creates a uniswap pool with GPTD/WETH token pairs, and with every buy function, it deposits 1/2 of the purchased ETH and 1/20 of the purchased token.

The GPTD tokens will be available for sale to the public through the exchange contract, while providing a minimum return via the uniswap pool which is set to increase with purchases.

The treasury funds will be used as outlined in the (currently WIP) [whitepaper](https://gptdodah.com/info/whitepaper#erc-20-token-integration-for-p2p-value-exchange)

## References

1. OpenZeppelin. <https://openzeppelin.com/>
