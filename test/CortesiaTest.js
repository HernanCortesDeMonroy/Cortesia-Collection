const {expect} = require('chai');
const {ethers} = require('hardhat');
const {assert} = require('chai')

describe("Cortesia", function() {
    let creator, operator, receiver;
    const initialTokens = 10;
    let contract;

    beforeEach(async () => {
        [creator, operator, receiver] = await ethers.getSigners();
        const Cortesia = await ethers.getContractFactory("Cortesia");
        contract = await Cortesia.deploy(initialTokens);
        await contract.deployed(); 
    })

    it("Should show creator's balance", async function() {
        assert.equal(await contract.balanceOf(creator.address), 10);
    })

    it("Should allow to issue tokens by creator", async function() {
        const issueAmount = 2;
        await contract.issueTokens(issueAmount, {
            from: creator.address
        });
        const finalBalance = await contract.balanceOf(creator.address);
        assert.equal(finalBalance, initialTokens + issueAmount);
    })

    it("Should allow to burn token by creator", async function() {
        await contract.burnToken( '2', {
            from: creator.address
        })
        const finalBalance = await contract.balanceOf(creator.address);
        assert.equal(finalBalance, initialTokens - 1);
    })

    it("Should allow to transfer your own token", async function() {
        const from = creator.address;
        const to = receiver.address;
        const tokenId = 3;
        
        try{
            const tx = await contract.transferFrom(from, to, tokenId, {from: creator.address});
            await tx.wait();
            const receiverBalance = await contract.balanceOf(receiver.address);
            expect(receiverBalance).to.equal(1);
            await expect(tx).to.emit(contract, 'Transfer');
        } catch(err) {
            assert(false);
        }
    })

    it("Should allow to safeTransfer your own token", async function() {
        const from = creator.address;
        const to = receiver.address;
        const tokenId = 3;
        let gotReceiver;

        const tx = await contract["safeTransferFrom(address,address,uint256)"](from, to, tokenId, {from: creator.address});
        await tx.wait();
        
        gotReceiver = await contract.ownerOf(tokenId);
        expect(gotReceiver).to.equal(receiver.address);
    })

    it("Should safeTransfer to the valid contract", async function() {
        const from = creator.address;
        const tokenId = 3;
        let gotReceiver;
        let validReceiver = await ethers.getContractFactory("ValidReceiver");
        let contractReceiver = await validReceiver.deploy();
        await contractReceiver.deployed();
        const to = contractReceiver.address;

        await contract["safeTransferFrom(address,address,uint256)"](
            from,
            to, 
            tokenId,
            {from: creator.address}
        )
        gotReceiver = await contract.ownerOf(tokenId);
        expect(gotReceiver).to.equal(to)
    })

    it("Should not to safeTransfer to the invalid contract", async function() {
        const from = creator.address;
        const tokenId = 3;
        let invalidReceiver = await ethers.getContractFactory("InvalidReceiver");
        invalidReceiver = await invalidReceiver.deploy();
        await invalidReceiver.deployed();
        const to = invalidReceiver.address;


        await expect(contract["safeTransferFrom(address,address,uint256)"](
            from,
            to,
            tokenId,
            {from: creator.address}
        )).to.be.reverted;
    })

    it("Should allow to safeTransfer with data", async function() {
        const from = creator.address;
        const to = receiver.address;
        const tokenId = 3;
        let gotReceiver;
        const bytes = ethers.utils.hexlify(ethers.utils.toUtf8Bytes("Hernando Cortes"));

        await contract["safeTransferFrom(address,address,uint256,bytes)"](
            from, 
            to, 
            tokenId,
            bytes,
            {from: creator.address}
        );
        gotReceiver = await contract.ownerOf(tokenId);
        expect(gotReceiver).to.equal(to);
    })

    it("Should approve your token to operator", async function() {
        const to = receiver.address;
        const tokenId = 3;

        await contract.approve(to, tokenId, {
            from: creator.address 
        });

        const approved = await contract.getApproved(tokenId);
        await expect(approved).to.equal(to);
    })

    it("Should not to approve someone for someone else’s token", async function() {
        const to = receiver.address;
        const tokenId = 15;

        await expect(contract.approve(to, tokenId)
        ).to.be.revertedWith("Token is not valid");
    })

    it("Should overwrite new approve", async function() {
        const to = receiver.address;
        const to2 = operator.address;
        const tokenId = 3;

        await contract.approve(to, tokenId, {
            from: creator.address 
        });
        const approve0 = await contract.getApproved(tokenId);
        await contract.approve(to2, tokenId);
        const approve1 = await contract.getApproved(tokenId);

        expect(approve0).to.not.equal(approve1);
        expect(approve1).to.equal(to2)
    })

    it("Should overwrite new approve", async function() {
        const to = receiver.address;
        const to2 = operator.address;
        const tokenId = 3;

        await contract.approve(to, tokenId, {
            from: creator.address 
        });
        const approve0 = await contract.getApproved(tokenId);
        await contract.approve(to2, tokenId);
        const approve1 = await contract.getApproved(tokenId);

        expect(approve0).to.not.equal(approve1);
        expect(approve1).to.equal(to2)
    })

    it("Should un-approve", async() => {
        const to = receiver.address;
        const tokenId = 3;

        await contract.approve(to, tokenId, {
            from: creator.address 
        });
        const approve0 = await contract.getApproved(tokenId);
        await contract.approve(ethers.constants.AddressZero, tokenId);
        const approve1 = await contract.getApproved(tokenId);

        expect(approve0).to.not.equal(approve1);
        expect(approve1).to.equal(ethers.constants.AddressZero);
    })

    it("Approved address can transfer token", async() => {
        const owner = creator.address;
        const oper = operator.address;
        const to = receiver.address;
        const tokenId = 3;

        await contract.connect(creator).approve(oper, tokenId)
        await contract.connect(operator).transferFrom(owner, to, tokenId);
        const checker = await contract.ownerOf(tokenId);

        expect(checker).to.equal(to);
    })

    it("After sending, no longer approval", async() => {
        const owner = creator.address;
        const oper = operator.address;
        const to = receiver.address;
        const tokenId = 3;

        await contract.connect(creator).approve(oper, tokenId)
        await contract.connect(operator).transferFrom(owner, to, tokenId);
        const checker = await contract.getApproved(tokenId);

        expect(checker).to.equal(ethers.constants.AddressZero);
    })

    it("Should allow to set operator", async() => {
        const owner = creator.address;
        const oper = operator.address;

        await contract.connect(creator).setApprovalForAll(oper, true);
        const isApproved = await contract.isApprovedForAll(owner, oper);

        assert(isApproved);
    })

    it("Should allow to unset operator", async() => {
        const owner = creator.address;
        const oper = operator.address;

        await contract.connect(creator).setApprovalForAll(oper, true);
        await contract.connect(creator).setApprovalForAll(oper, false);
        const isApproved = await contract.isApprovedForAll(owner, oper);

        expect(isApproved).to.be.equal(false);
    })

    it("Operator can send a coin", async() => {
        const owner = creator.address;
        const oper = operator.address;
        const to = receiver.address;
        const tokenId = 3;

        await contract.connect(creator).setApprovalForAll(oper, true);
        await contract.connect(operator).transferFrom(owner, to, tokenId);

        const gotReceiver = await contract.ownerOf(tokenId);
        expect(gotReceiver).to.be.equal(to);
    })

    it("Operator can't send coin twice", async() => {
        const owner = creator.address;
        const oper = operator.address;
        const to = receiver.address;
        const tokenId = 3;
        let success = false;

        await contract.connect(creator).setApprovalForAll(oper, true);
        await contract.connect(operator).transferFrom(owner, to, tokenId);
        try {
            await contract.connect(operator).transferFrom(owner, to, tokenId);
            success = true;
        } catch(err) {
            success = false;
        }

        expect(success).to.be.equal(false);
    })


})