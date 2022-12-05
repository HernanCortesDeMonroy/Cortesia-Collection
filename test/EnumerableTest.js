const {ethers} = require("hardhat");
const {expect} = require('chai');
const { string } = require("hardhat/internal/core/params/argumentTypes");

describe("Enumerable", () => {
    const initialSupply = 10;
    let contract;
    let creator, owner;

    beforeEach(async() => {
        [creator, owner] = await ethers.getSigners();
        const Enumerable = await ethers.getContractFactory("CortesiaEnumerable");
        contract = await Enumerable.deploy(initialSupply);
        await contract.deployed();
    })

    it("Total supply equal initialSupply", async() => {
        const totalSupply = await contract.totalSupply();
        expect(totalSupply).to.be.equal(initialSupply);
    })

    it("Reported total supply is accurate after minting extra tokens", async() => {
        const mintAmount = 2;
        await contract.connect(creator)._issueTokens(mintAmount);

        const totalSupply = await contract.totalSupply();
        expect(totalSupply).to.be.equal(initialSupply + mintAmount);
    })

    it("Reportes total supply after burning a token", async() => {
        const tokenToBurn = 2;
        await contract.connect(creator)._burnToken(tokenToBurn);
        
        const totalSupply = await contract.totalSupply();
        expect(totalSupply).to.be.equal(initialSupply - 1);
    })

    it("Reports correct tokenByIndex after minting extra tokens", async() => {
        let tokenExpected, tokenReported;
        const mintAmount = 2;
        await contract.connect(creator)._issueTokens(mintAmount);

        for(let i = 0; i < initialSupply + mintAmount; i++) {
            tokenExpected = i+1;
            tokenReported = await contract.tokenByIndex(i);
            expect(tokenReported).to.be.equal(tokenExpected);
        }
    })

    it("Reports correct tokenByIndex after burning a token", async() => {
        let tokenIdsExpected = ['1','10','3','4','5','6','7','8','9'];
        let tokenReported, tokenExpected;
        const burnToken = 2;
        await contract.connect(creator)._burnToken(burnToken);

        for(let i = 0; i < tokenIdsExpected.length; i++) {
            tokenExpected = tokenIdsExpected[i];
            tokenReported = await contract.tokenByIndex(i);
            expect(tokenReported).to.be.equal(tokenExpected);
        }
    })

    it("Initially reports correct tokenOfOwnerByIndex", async() => {
        let tokenReported, tokenExpected;
        for(let i = 0; i < initialSupply; i++) {
            tokenExpected = (i+1).toString();
            tokenReported = await contract.tokenByIndex(i);
            expect(tokenReported).to.be.equal(tokenExpected);
        }
    })

    it("Reports correct tokenOfOwnerByIndex after minting extra tokens", async() => {
        let tokenReported, tokenExpected;
        const mintAmount = 3;
        await contract._issueTokens(3);

        for(let i = 0; i < initialSupply + mintAmount; i++) {
            tokenExpected = (i+1).toString();
            tokenReported = await contract.tokenByIndex(i);
            expect(tokenExpected).to.be.equal(tokenReported);
        }
    })

    it("Reports correct tokenOfOwnerByIndex after transferring tokens", async() => {
        let tokenReported, tokenExpected;

        await contract.connect(creator)._transferFrom(creator.address, owner.address, '2');
        await contract.connect(creator)._transferFrom(creator.address, owner.address, '4');
        await contract.connect(owner)._transferFrom(owner.address, creator.address, '2');

/*         await contract._transferFrom(creator.address, owner.address, '2', {from: creator});
        await contract._transferFrom(creator.address, owner.address, '4', {from: creator});
        await contract._tranferFrom(owner.address, creator.address, '2', {from: creator}); */

        let tokenIdsExpected = ['1','10','3','9','5','6','7','8','2'];
        let tokenIdsExpected1 = ['4'];
        
        for(let i = 0; i < tokenIdsExpected.length; i++) {
            tokenExpected = tokenIdsExpected[i];
            tokenReported = await contract.tokenOfOwnerByIndex(creator.address, i);
            expect(tokenReported).to.be.equal(tokenExpected);
        }

        for(let i = 0; i < tokenIdsExpected1.length; i++) {
            tokenExpected = tokenIdsExpected1[i];
            tokenReported = await contract.tokenOfOwnerByIndex(owner.address, i);
            expect(tokenReported).to.be.equal(tokenExpected);
        }
    })


})