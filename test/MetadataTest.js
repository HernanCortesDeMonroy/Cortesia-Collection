const {ethers} = require("hardhat");
const {expect} = require("chai");
const {assert} = require("chai");

describe("Metadata", () => {
    const _name = "Cortesia";
    const _symbol = "CTS";
    const _uriBase = "cortesia.uri/";
    const initialSupply = 10;
    let creator;
    let contract;

    beforeEach(async() => {
        creator = await ethers.getSigner();
        const CortesiaMetadata = await ethers.getContractFactory("CortesiaMetadata"); 
        contract = await CortesiaMetadata.deploy(
            initialSupply,
            _name,
            _symbol,
            _uriBase
        );
        await contract.deployed();
    })

    it("Name should be correct", async() => {
        const nameReported = await contract.name();
        expect(nameReported).to.be.equal(_name);
    })

    it("Symbol should be correct", async() => {
        const symbolReported = await contract.symbol();
        expect(symbolReported).to.be.equal(_symbol);
    })

    it("UriBase should be correct", async() => {
        const tokenId = '3';
        const uriBaseReported = await contract.tokenURI(tokenId);
        const uriBaseExpected = _uriBase + tokenId;
        expect(uriBaseReported).to.be.equal(uriBaseExpected);
    })
})