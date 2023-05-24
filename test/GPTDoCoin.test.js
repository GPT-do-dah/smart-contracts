const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("GPTDoDahToken ERC20 Standard Test", function () {
  let owner, recipient1, recipient2, recipient3, token;

  beforeEach(async function () {
    // Deploy the contract and get reference to the contract instance
    [owner, recipient1, recipient2, recipient3] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("GPTDoCoin");
    token = await Token.connect(owner).deploy();
    await token.deployed();
    await token.connect(owner).transfer(recipient1.address, 1000);
  });

  describe("Contract Initialization", function () {
    it("Should correctly deploy the contract", async function () {
      expect(token.address).to.be.properAddress;
    });

    it("Should correctly report the token balance of the contract owner", async function () {
      const balance = await token.balanceOf(owner.address);
      const decimals = await token.decimals();
      const supply = ethers.utils.parseUnits("21000000", decimals).sub("1000");
      expect(balance).to.equal(supply);
    });

    it("Should correctly report the token balance of any other address", async function () {
      const balance = await token.balanceOf(recipient1.address);
      expect(balance).to.equal(1000);
    });

    it("Should correctly report the token name", async function () {
      const name = await token.name();
      expect(name).to.equal("GPTDoDahToken");
    });

    it("Should correctly report the token symbol", async function () {
      const symbol = await token.symbol();
      expect(symbol).to.equal("GPTD");
    });

    it("Should correctly report the token decimals", async function () {
      const decimals = await token.decimals();
      expect(decimals).to.equal(18);
    });

    it("Should correctly report the token total supply", async function () {
      const decimals = await token.decimals();
      const supply = await token.totalSupply();
      expect(supply).to.equal(ethers.utils.parseUnits("21000000", decimals));
    })
  });

  describe("Token Transfer Functionality", function () {
    it("Should correctly transfer tokens from the sender to the recipient", async function () {
      const initialSenderBalance = await token.balanceOf(owner.address);
      const initialRecipientBalance = await token.balanceOf(recipient1.address);
      await token.connect(owner).transfer(recipient1.address, 100);
      const finalSenderBalance = await token.balanceOf(owner.address);
      const finalRecipientBalance = await token.balanceOf(recipient1.address);
      expect(finalSenderBalance).to.equal(initialSenderBalance.sub(100));
      expect(finalRecipientBalance).to.equal(initialRecipientBalance.add(100));
    });

    it("Should correctly emit a Transfer event on token transfer", async function () {
      await expect(token.transfer(recipient1.address, 100)).to.emit(token, 'Transfer').withArgs(owner.address, recipient1.address, 100);
    });

    it("Should revert when sender does not have sufficient balance for transfer", async function () {
      const decimals = await token.decimals();
      await expect(token.connect(recipient3).transfer(owner.address, ethers.BigNumber.from("21000000").mul(ethers.BigNumber.from("10").pow(decimals)).add("1"))).to.be.revertedWith("ERC20: transfer amount exceeds balance");
    });
    });

  describe("Token transferFrom Functionality", function () {
    beforeEach(async function () {
      // Give an allowance to recipient1 from owner's account
      await token.approve(recipient1.address, 1000);
    });
  
    it("Should correctly transfer tokens from the sender to the recipient using transferFrom function", async function () {
      const initialSenderBalance = await token.balanceOf(owner.address);
      const initialRecipientBalance = await token.balanceOf(recipient2.address);
      await token.connect(recipient1).transferFrom(owner.address, recipient2.address, 100);
      const finalSenderBalance = await token.balanceOf(owner.address);
      const finalRecipientBalance = await token.balanceOf(recipient2.address);
      expect(finalSenderBalance).to.equal(initialSenderBalance.sub(100));
      expect(finalRecipientBalance).to.equal(initialRecipientBalance.add(100));
    });
  
    it("Should correctly update the balances of the sender, recipient, and spender on transferFrom function", async function () {
      const initialOwnerBalance = await token.balanceOf(owner.address);
      const initialRecipientBalance = await token.balanceOf(recipient2.address);
      const initialSpenderAllowance = await token.allowance(owner.address, recipient1.address);
      await token.connect(recipient1).transferFrom(owner.address, recipient2.address, 100);
      const finalOwnerBalance = await token.balanceOf(owner.address);
      const finalRecipientBalance = await token.balanceOf(recipient2.address);
      const finalSpenderAllowance = await token.allowance(owner.address, recipient1.address);
      expect(finalOwnerBalance).to.equal(initialOwnerBalance.sub(100));
      expect(finalRecipientBalance).to.equal(initialRecipientBalance.add(100));
      expect(finalSpenderAllowance).to.equal(initialSpenderAllowance.sub(100));
    });
  
    it("Should correctly emit a Transfer event on transferFrom function", async function () {
      await expect(token.connect(recipient1).transferFrom(owner.address, recipient2.address, 100)).to.emit(token, 'Transfer').withArgs(owner.address, recipient2.address, 100);
    });
  
    it("Should revert when spender does not have a sufficient allowance on transferFrom function", async function () {
      await expect(token.connect(recipient1).transferFrom(recipient2.address, owner.address, 1000)).to.be.revertedWith("ERC20: insufficient allowance");
    });
  
    it("Should revert when sender does not have a sufficient balance on transferFrom function", async function () {
      await expect(token.connect(recipient1).transferFrom(recipient2.address, owner.address, 21000001)).to.be.revertedWith("ERC20: insufficient allowance");
    });
  });
    
  describe("Token Allowance Functionality", function () {
    it("Should correctly set allowance for spender using approve function", async function () {
      const initialAllowance = await token.allowance(owner.address, recipient1.address);
      await token.increaseAllowance(recipient1.address, 100);
      const finalAllowance = await token.allowance(owner.address, recipient1.address);
      expect(finalAllowance).to.equal(initialAllowance.add(100));
    });
  
    it("Should correctly emit an Approval event on allowance setting using approve function", async function () {
      await expect(token.approve(recipient1.address, 100)).to.emit(token, 'Approval').withArgs(owner.address, recipient1.address, 100);
    });
  
    it("Should correctly report allowance for spender using allowance function", async function () {
      await token.approve(recipient1.address, 100);
      const allowance = await token.allowance(owner.address, recipient1.address);
      expect(allowance).to.equal(100);
    });
  
    it("Should correctly increase allowance for spender using increaseAllowance function", async function () {
      const initialAllowance = await token.allowance(owner.address, recipient1.address);
      await token.increaseAllowance(recipient1.address, 50);
      const finalAllowance = await token.allowance(owner.address, recipient1.address);
      expect(finalAllowance).to.equal(initialAllowance.add(50));
    });
  
    it("Should correctly emit an Approval event on allowance increase using increaseAllowance function", async function () {
      await expect(token.increaseAllowance(recipient1.address, 50)).to.emit(token, 'Approval').withArgs(owner.address, recipient1.address, 50);
    });
  
    it("Should correctly decrease allowance for spender using decreaseAllowance function", async function () {
      await token.approve(recipient1.address, 100);
      const initialAllowance = await token.allowance(owner.address, recipient1.address);
      await token.decreaseAllowance(recipient1.address, 50);
      const finalAllowance = await token.allowance(owner.address, recipient1.address);
      expect(finalAllowance).to.equal(initialAllowance.sub(50));
    });
  
    it("Should correctly emit an Approval event on allowance decrease using decreaseAllowance function", async function () {
      await token.approve(recipient1.address, 100);
      await expect(token.decreaseAllowance(recipient1.address, 50)).to.emit(token, 'Approval').withArgs(owner.address, recipient1.address, 50);
    });
  });
});
