const { setBalance } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

require("@nomiclabs/hardhat-ethers");
const { parseEther } = ethers.utils;

const WETH9_MAINNET = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const UNISWAP_ROUTER = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
const impersonatoraddress = "0xD98C3b7f0297f2eD1861893cFD80C4CfA24Fb687";

let gptDoDahExchange,
  UniswapRouter,
  GPTDoDahToken,
  GPTDoDahTreasury,
  owner,
  addr1,
  addr2;
  
describe("GPTDoDahExchange", function () {
  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    await setBalance(owner.address, 10 * 10**18);
    await setBalance(addr1.address, 10 * 10**18);
    // First we need to deploy the necessary contracts before the exchange
    const GPTDoDahTreasuryFactory = await ethers.getContractFactory(
      "GPTDoDahTreasury"
    );
    GPTDoDahTreasury = await GPTDoDahTreasuryFactory.deploy();
    await GPTDoDahTreasury.deployed();

    const GPTDoCoinFactory = await ethers.getContractFactory("GPTDoCoin");
    GPTDoDahToken = await GPTDoCoinFactory.deploy();
    await GPTDoDahToken.deployed();

    WETH9 = await ethers.getContractAt("IERC20", WETH9_MAINNET);
    UniswapRouter = await ethers.getContractAt(
      "IUniswapV2Router02",
      UNISWAP_ROUTER
    );

    const GPTDoDahExchangeFactory = await ethers.getContractFactory(
      "GPTDoDahExchange"
    );
    gptDoDahExchange = await GPTDoDahExchangeFactory.deploy(
      GPTDoDahToken.address,
      UniswapRouter.address,
      GPTDoDahTreasury.address
    );
    await gptDoDahExchange.deployed();
  });

  describe("Deployment/Contract Setup", function () {
    it("Should set the right owner", async function () {
      expect(await gptDoDahExchange.hasRole(gptDoDahExchange.DEFAULT_ADMIN_ROLE(), owner.address)).to.equal(true);
    });

    it("Should set the correct addresses", async function() {
      expect(await gptDoDahExchange.gptDoDahTreasury()).to.equal(GPTDoDahTreasury.address);
      expect(await gptDoDahExchange.gptDoCoin()).to.equal(GPTDoDahToken.address);
      expect(await gptDoDahExchange.uniswapRouter()).to.equal(UniswapRouter.address);
    });

    it("Should set the correct variables", async function() {
      
      // Parsing Error expected ~~> Parsing error: Identifier directly after number
      expect(await gptDoDahExchange.MINIMUM_PURCHASE()).to.equal(100000000000000000n);
      expect(await gptDoDahExchange.TOKEN_RATIO()).to.equal(180);
    });

    it("Should assign the total supply of tokens to the owner", async function () {
      const ownerBalance = await GPTDoDahToken.balanceOf(owner.address);
      expect(await GPTDoDahToken.totalSupply()).to.equal(ownerBalance);
    });

    
    it("Should revert if non-admin tries to create Uniswap pool", async function () {
      await expect(gptDoDahExchange.connect(addr1).createUniswapPool()).to.be.revertedWith(`AccessControl: account 0x70997970c51812dc3a010c7d01b50e0d17dc79c8 is missing role 0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775`);
      expect(await gptDoDahExchange.uniswapPoolCreated()).to.equal(false);
    });

    it("Should revert if no tokens are provided when creating a Uniswap pool", async function() {
      await expect(gptDoDahExchange.connect(owner).createUniswapPool()).to.be.revertedWith("No tokens provided!");
    });
    
    it("Should create the Uniswap pool for GPTD/WETH pair", async function () {
      await GPTDoDahToken.connect(owner).approve(gptDoDahExchange.address,
      await GPTDoDahToken.totalSupply());
      await GPTDoDahToken.connect(owner).transfer(gptDoDahExchange.address,
      await GPTDoDahToken.totalSupply());
  
      // Create Uniswap pool
      await gptDoDahExchange.connect(owner).createUniswapPool();
      expect(await gptDoDahExchange.uniswapPoolCreated()).to.equal(true);
    });

    it("Should allow admin to create Uniswap pool only once", async function () {
      await GPTDoDahToken.connect(owner).approve(gptDoDahExchange.address,
      await GPTDoDahToken.totalSupply());
      await GPTDoDahToken.connect(owner).transfer(gptDoDahExchange.address,
      await GPTDoDahToken.totalSupply());
      // Create Uniswap pool
      await gptDoDahExchange.connect(owner).createUniswapPool();
      expect(await gptDoDahExchange.uniswapPoolCreated()).to.equal(true);
      await expect(gptDoDahExchange.createUniswapPool()).to.be.revertedWith("Uniswap pool already created");
    });
  });

  describe("Transactions", function () {

    it("Should revert if sender doesn’t have enough tokens", async function () {
      const initialAddr2Balance = await GPTDoDahToken.balanceOf(addr2.address);

      await expect(gptDoDahExchange.connect(addr2).buyTokens())
          .to.be.revertedWith("Purchase amount below minimum");

      expect(await GPTDoDahToken.balanceOf(addr2.address)).to.equal(initialAddr2Balance);
    });

    it("Should revert if Uniswap Pool is not created", async function () {
      await expect(gptDoDahExchange.connect(addr1).buyTokens({ value: ethers.utils.parseEther("0.1") })).to.be.revertedWith("Trading not yet enabled!");
    });

    it("Should purchase tokens using ETH", async function () {

      const impersonator = await ethers.getImpersonatedSigner(impersonatoraddress);

      await GPTDoDahToken.connect(owner).approve(gptDoDahExchange.address,
      await GPTDoDahToken.totalSupply());
      await GPTDoDahToken.connect(owner).transfer(gptDoDahExchange.address,
      await GPTDoDahToken.totalSupply());
  
      // Create Uniswap pool
      await gptDoDahExchange.connect(owner).createUniswapPool();

      await gptDoDahExchange
        .connect(impersonator)
        .buyTokens({ value: parseEther("1") });
    });

    it("Should purchase tokens by sending ETH", async function () {

      const impersonator = await ethers.getImpersonatedSigner(impersonatoraddress);

      await GPTDoDahToken.connect(owner).approve(gptDoDahExchange.address,
      await GPTDoDahToken.totalSupply());
      await GPTDoDahToken.connect(owner).transfer(gptDoDahExchange.address,
      await GPTDoDahToken.totalSupply());
  
      // Create Uniswap pool
      await gptDoDahExchange.connect(owner).createUniswapPool();

      await impersonator.sendTransaction({
        to: gptDoDahExchange.address,
        value: ethers.utils.parseEther("10")
      });
    });

    it("Should update balances after purchases", async function () {
      
      await GPTDoDahToken.connect(owner).approve(gptDoDahExchange.address,
      await GPTDoDahToken.totalSupply());
      await GPTDoDahToken.connect(owner).transfer(gptDoDahExchange.address,
      await GPTDoDahToken.totalSupply());
       
      // Create Uniswap pool
      await gptDoDahExchange.connect(owner).createUniswapPool();
      const initialOwnerBalance = await GPTDoDahToken.balanceOf(owner.address);
      
      await gptDoDahExchange.connect(addr1).buyTokens({ value: ethers.utils.parseEther("0.1") });

      expect(await GPTDoDahToken.balanceOf(owner.address)).to.equal(initialOwnerBalance);

      //Parsing Error expected ~~> Parsing error: Identifier directly after number
      expect(await GPTDoDahToken.balanceOf(addr1.address)).to.be.equal(18000000000000000000n);
    });

  });

  describe("Withdrawing funds to treasuries", function () {
    it("Should withdraw ETH to treasuries correctly", async function () {
      await GPTDoDahToken.connect(owner).approve(gptDoDahExchange.address,
      await GPTDoDahToken.totalSupply());
      await GPTDoDahToken.connect(owner).transfer(gptDoDahExchange.address,
      await GPTDoDahToken.totalSupply());
  
      // Create Uniswap pool
      await gptDoDahExchange.connect(owner).createUniswapPool();

      await gptDoDahExchange
        .connect(addr1)
        .buyTokens({ value: parseEther("1") });

      const initialTreasuryBalance = await ethers.provider.getBalance(
        GPTDoDahTreasury.address
      );

      await gptDoDahExchange.connect(owner).withdraw();

      const finalTreasuryBalance = await ethers.provider.getBalance(
        GPTDoDahTreasury.address
      );

      expect(finalTreasuryBalance).to.be.above(initialTreasuryBalance);
    });
    it("Should allow withdrawal only by admin", async function () {
      await GPTDoDahToken.connect(owner).approve(gptDoDahExchange.address,
      await GPTDoDahToken.totalSupply());
      await GPTDoDahToken.connect(owner).transfer(gptDoDahExchange.address,
      await GPTDoDahToken.totalSupply());
  
      // Create Uniswap pool
      await gptDoDahExchange.connect(owner).createUniswapPool();

      await expect(gptDoDahExchange.connect(addr1).withdraw()).to.be.revertedWith("AccessControl: account 0x70997970c51812dc3a010c7d01b50e0d17dc79c8 is missing role 0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775");
  });

    it("Should be able to withdraw accumulated ETH to the treasury contract", async function () {
      await GPTDoDahToken.connect(owner).approve(gptDoDahExchange.address,
      await GPTDoDahToken.totalSupply());
      await GPTDoDahToken.connect(owner).transfer(gptDoDahExchange.address,
      await GPTDoDahToken.totalSupply());
  
      // Create Uniswap pool
      await gptDoDahExchange.connect(owner).createUniswapPool();

      await gptDoDahExchange
        .connect(addr1)
        .buyTokens({ value: parseEther("1") });

        const initialBalance = await ethers.provider.getBalance(GPTDoDahTreasury.address);
        await gptDoDahExchange.withdraw();
        expect(await ethers.provider.getBalance(GPTDoDahTreasury.address)).to.be.gt(initialBalance);
    });
  });

  describe("Withdrawing funds from the Treasury", function() {
    it("Should allow owner to withdraw funds", async function() {
      await GPTDoDahToken.connect(owner).approve(gptDoDahExchange.address,
        await GPTDoDahToken.totalSupply());
        await GPTDoDahToken.connect(owner).transfer(gptDoDahExchange.address,
        await GPTDoDahToken.totalSupply());
    
        // Create Uniswap pool
        await gptDoDahExchange.connect(owner).createUniswapPool();
  
        await gptDoDahExchange
          .connect(addr1)
          .buyTokens({ value: parseEther("1") });
        
        const initialBalance = await ethers.provider.getBalance(owner.address);
        await gptDoDahExchange.withdraw();
        await GPTDoDahTreasury.connect(owner).releaseEth();
        expect(await ethers.provider.getBalance(owner.address)).to.be.gt(initialBalance);
    });

    it("Should revert if there is no balance in the Treasury contract", async function() {
      await expect(GPTDoDahTreasury.connect(owner).releaseEth()).to.be.revertedWith("Insufficient balance");
    })
  })
});
