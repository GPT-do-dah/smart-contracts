const { ethers } = require("hardhat");

let gptDoDahExchange,
  UniswapRouter,
  GPTDoCoin,
  GPTDoDahTreasury;

const WETH9_MAINNET = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const UNISWAP_ROUTER = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";

describe("GPTDoDahExchange", function () {
  beforeEach(async function () {
    [owner] = await ethers.getSigners();
  });

  describe("Should compile and deploy the contracts", function () {
    it("Should deploy the GPTDoDahTreasuryFactory contract", async function () {
      const GPTDoDahTreasuryFactory = await ethers.getContractFactory(
        "GPTDoDahTreasury"
      );
      GPTDoDahTreasury = await GPTDoDahTreasuryFactory.deploy();
      await GPTDoDahTreasury.deployed();
    });

    it("Should deploy the GPTDoCoinFactory contract", async function () {
      const GPTDoCoinFactory = await ethers.getContractFactory(
        "GPTDoCoin"
      );
      GPTDoCoin = await GPTDoCoinFactory.deploy();
      await GPTDoCoin.deployed();
    });

    it("Should deploy the GPTDoDahExchangeFactory contract", async function () {
      WETH9 = await ethers.getContractAt("IWETH", WETH9_MAINNET);
      UniswapRouter = await ethers.getContractAt(
        "IUniswapV2Router02",
        UNISWAP_ROUTER
      );

      const GPTDoDahExchangeFactory = await ethers.getContractFactory(
        "GPTDoDahExchange"
      );
      gptDoDahExchange = await GPTDoDahExchangeFactory.deploy(
        GPTDoCoin.address,
        UniswapRouter.address,
        GPTDoDahTreasury.address
      );
      await gptDoDahExchange.deployed();
    });
  });
});
