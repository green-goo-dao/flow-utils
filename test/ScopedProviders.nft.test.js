import {
    executeScript, sendTransaction
} from "flow-js-testing";
import {
    after, alice,
    before, exampleNFTAdmin, mintExampleNFT,
} from "./common";

// Increase timeout if your tests failing due to timeout
jest.setTimeout(10000);


describe("ScopedNonFungibleTokenProvider tests", () => {
    beforeEach(async () => {
        await before()
    });

    // Stop emulator, so it could be restarted
    afterEach(async () => {
        await after()
    });

    it("should withdraw an nft successfully", async () => {
        const id = await mintExampleNFT(alice)
        const [tx, err] = await sendTransaction({
            name: "scopedproviders/nft/withdraw_scoped_nft",
            args: [[id], id],
            signers: [alice]
        })
        expect(err).toBe(null)
        expect(tx.events[0].type).toBe(`A.${exampleNFTAdmin.substring(2)}.ExampleNFT.Withdraw`)
        expect(tx.events[0].data.id).toBe(id)
    })

    it("should withdraw an nft successfully before expiration", async () => {
        const id = await mintExampleNFT(alice)
        const [tx, err] = await sendTransaction({
            name: "scopedproviders/nft/withdraw_scoped_nft_before_expiration",
            args: [[id], id],
            signers: [alice]
        })
        expect(err).toBe(null)
        expect(tx.events[0].type).toBe(`A.${exampleNFTAdmin.substring(2)}.ExampleNFT.Withdraw`)
        expect(tx.events[0].data.id).toBe(id)
    })

    it("should fail to withdraw an nft", async () => {
        const id = await mintExampleNFT(alice)
        const id2 = await mintExampleNFT(alice)
        const [tx, err] = await sendTransaction({
            name: "scopedproviders/nft/withdraw_scoped_nft",
            args: [[id], id2],
            signers: [alice]
        })
        expect(tx).toBe(null)
        expect(err).toContain("panic: cannot withdraw nft. filter of type A.01cf0e2f2f715450.ScopedNFTProviders.NFTIDFilter failed")
    })

    it("should fail to withdraw an nft past expiration", async () => {
        const id = await mintExampleNFT(alice)
        const [tx, err] = await sendTransaction({
            name: "scopedproviders/nft/withdraw_scoped_nft_past_expiration",
            args: [[id], id],
            signers: [alice]
        })
        expect(tx).toBe(null)
        expect(err.includes("provider has expired")).toBe(true)
    })

    it("should be able to withdraw", async () => {
        const id = await mintExampleNFT(alice)
        const [tx, err] = await sendTransaction({
            name: "scopedproviders/nft/withdraw_scoped_nft",
            args: [[id], id],
            signers: [alice]
        })
        expect(err).toBe(null)
        expect(tx.events[0].type).toBe(`A.${exampleNFTAdmin.substring(2)}.ExampleNFT.Withdraw`)
        expect(tx.events[0].data.id).toBe(id)
    })

    it("should not be able to withdraw twice", async () => {
        const id = await mintExampleNFT(alice)
        const [tx, err] = await sendTransaction({
            name: "scopedproviders/nft/withdraw_scoped_nft_twice",
            args: [[id], id],
            signers: [alice]
        })
        expect(tx).toBe(null)
        expect(err).toContain("panic: cannot withdraw nft. filter of type A.01cf0e2f2f715450.ScopedNFTProviders.NFTIDFilter failed")
    })
})
