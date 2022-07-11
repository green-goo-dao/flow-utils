import path from "path";
import {
    deployContractByName,
    emulator,
    getAccountAddress,
    init,
} from "flow-js-testing";

let flowUtils

export const setup = async () => {
    const basePath = path.resolve(__dirname, "../cadence");
    const port = 8080;
    const logging = false;

    await init(basePath, {port});
    await emulator.start(port, logging);

    flowUtils = await getAccountAddress("FlowUtils")

    await deployContractByName({name: "StringUtils", to: flowUtils, update: true})
}

export const before = async () => {
    await setup()
}

export const after = async () => {
    await emulator.stop()
}
