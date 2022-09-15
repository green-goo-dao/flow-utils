import path from "path";
import {
    deployContractByName,
    emulator,
    getAccountAddress,
    init, mintFlow,
    sendTransaction,
} from "flow-js-testing";

// contracts
export let flowUtils, exampleNFTAdmin, exampleTokenAdmin

// users
export let alice

export const setup = async () => {
    const basePath = path.resolve(__dirname, "../cadence");
    const port = 8080;
    const logging = false;

    await init(basePath, {port});
    await emulator.start(port, logging);

    flowUtils = await getAccountAddress("FlowUtils")
    exampleNFTAdmin = await getAccountAddress("ExampleNFT")
    exampleTokenAdmin = await getAccountAddress("ExampleToken")
    alice = await getAccountAddress("alice")

    await deployContractByName({name: "NonFungibleToken", to: exampleNFTAdmin, update: true})
    await deployContractByName({name: "MetadataViews", to: exampleNFTAdmin, update: true})
    await deployContractByName({name: "ExampleNFT", to: exampleNFTAdmin, update: true})
    await deployContractByName({name: "ExampleToken", to: exampleTokenAdmin, update: true})

    await deployContractByName({name: "ArrayUtils", to: flowUtils, update: true})
    await deployContractByName({name: "StringUtils", to: flowUtils, update: true})
    await deployContractByName({name: "ScopedNFTProviders", to: flowUtils, update: true})
    await deployContractByName({name: "ScopedFTProviders", to: flowUtils, update: true})

    await mintFlow(alice, 1.0)

    await setupExampleNFT(alice)
    await setupExampleToken(alice)
}

export const before = async () => {
    await setup()
}

export const after = async () => {
    await cleanup(alice)
    await emulator.stop()
}

const destroyExampleNFT = async (account) => {
    const [tx, err] = await sendTransaction({name: "examplenft/destroy", args: [], signers: [account]})
    expect(err).toBe(null)
}

const destroyExampleToken = async (account) => {
    const [tx, err] = await sendTransaction({name: "exampletoken/destroy", args: [], signers: [account]})
    expect(err).toBe(null)
}

const cleanup = async (account) => {
    await destroyExampleNFT(account)
    await destroyExampleToken(account)
}

export const setupExampleNFT = async (account) => {
    const [tx, err] = await sendTransaction({name: "examplenft/setup", args: [], signers: [account]})
    expect(err).toBe(null)
}

export const mintExampleNFT = async (recipient) => {
    const [tx, err] = await sendTransaction({name: "examplenft/mint", args: [recipient], signers: [exampleNFTAdmin]})
    expect(err).toBe(null)
    return tx.events[0].data.id
}

export const setupExampleToken = async (account) => {
    const [tx, err] = await sendTransaction({"name": "exampletoken/setup", args: [], signers: [account]})
    expect(err).toBe(null)
}

export const mintExampleTokens = async (recipient, amount) => {
    const [tx, err] = await sendTransaction({name: "exampletoken/mint", args: [recipient, amount], signers: [exampleTokenAdmin]})
    expect(err).toBe(null)
    return Number(tx.events[2].data.amount)
}

