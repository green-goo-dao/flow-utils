import {
    executeScript, sendTransaction
} from "flow-js-testing";
import {
    after, alice,
    before, exampleNFTAdmin, exampleTokenAdmin, mintExampleNFT, mintExampleTokens,
} from "./common";

// Increase timeout if your tests failing due to timeout
jest.setTimeout(10000);

describe("ScopedFungibleToken tests", () => {
    beforeEach(async () => {
        await before()
    });

    // Stop emulator, so it could be restarted
    afterEach(async () => {
        await after()
    });

    it("should withdraw tokens successfully", async () => {
        const tokenAmount = 100.0
        const allowance = 10.0
        const amount = await mintExampleTokens(alice, tokenAmount)
        expect(tokenAmount).toBe(amount)

        const [tx, err] = await sendTransaction({
            name: "scopedproviders/ft/withdraw_scoped_ft",
            args: [allowance, allowance],
            signers: [alice]
        })
        expect(err).toBe(null)
        expect(tx.events[0].type).toBe(`A.${exampleTokenAdmin.substring(2)}.ExampleToken.TokensWithdrawn`)
        expect(Number(tx.events[0].data.amount)).toBe(allowance)
    })

    it("should withdraw tokens successfully with expiration", async () => {
        const tokenAmount = 100.0
        const allowance = 10.0
        const amount = await mintExampleTokens(alice, tokenAmount)
        expect(tokenAmount).toBe(amount)

        const [tx, err] = await sendTransaction({
            name: "scopedproviders/ft/withdraw_scoped_ft_before_expiration",
            args: [allowance, allowance],
            signers: [alice]
        })
        expect(err).toBe(null)
        expect(tx.events[0].type).toBe(`A.${exampleTokenAdmin.substring(2)}.ExampleToken.TokensWithdrawn`)
        expect(Number(tx.events[0].data.amount)).toBe(allowance)
    })

    it("should not withdraw more than allowance", async () => {
        const tokenAmount = 100.0
        const allowance = 10.0
        const amount = await mintExampleTokens(alice, tokenAmount)
        expect(tokenAmount).toBe(amount)

        const [tx, err] = await sendTransaction({
            name: "scopedproviders/ft/withdraw_scoped_ft",
            args: [allowance, allowance * 2],
            signers: [alice]
        })
        expect(err.includes("not able to withdraw")).toBe(true)
    })

    it("should not withdraw past expiration", async () => {
        const tokenAmount = 100.0
        const allowance = 10.0
        const amount = await mintExampleTokens(alice, tokenAmount)
        expect(tokenAmount).toBe(amount)

        const [tx, err] = await sendTransaction({
            name: "scopedproviders/ft/withdraw_scoped_ft_past_expiration",
            args: [allowance, 1],
            signers: [alice]
        })
        expect(err.includes("provider has expired")).toBe(true)
        expect(tx).toBe(null)
    })

    it("should withdraw twice under balance", async () => {
        const tokenAmount = 100.0
        const allowance = 10.0
        const amount = await mintExampleTokens(alice, tokenAmount)
        expect(tokenAmount).toBe(amount)

        const [tx, err] = await sendTransaction({
            name: "scopedproviders/ft/withdraw_scoped_ft_twice",
            args: [allowance],
            signers: [alice]
        })

        expect(err).toBe(null)
        const depositAmount1 = Number(tx.events[1].data.amount)
        const depositAmount2 = Number(tx.events[3].data.amount)

        expect(depositAmount1 + depositAmount2).toBe(allowance)
    })
})
