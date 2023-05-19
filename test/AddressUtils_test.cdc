import Test

pub let blockchain = Test.newEmulatorBlockchain()
pub let account = blockchain.createAccount()

pub fun setup() {
    blockchain.useConfiguration(Test.Configuration({
        "ArrayUtils": account.address,
        "StringUtils": account.address,
        "../contracts/AddressUtils.cdc": account.address
    }))

    let arrayUtils = Test.readFile("../cadence/contracts/ArrayUtils.cdc")
    var err = blockchain.deployContract(
        name: "ArrayUtils",
        code: arrayUtils,
        account: account,
        arguments: []
    )

    let stringUtils = Test.readFile("../cadence/contracts/StringUtils.cdc")
    err = blockchain.deployContract(
        name: "StringUtils",
        code: stringUtils,
        account: account,
        arguments: []
    )

    Test.assert(err == nil)

    let addressUtils = Test.readFile("../cadence/contracts/AddressUtils.cdc")
    err = blockchain.deployContract(
        name: "AddressUtils",
        code: addressUtils,
        account: account,
        arguments: []
    )

    Test.assert(err == nil)
}

pub fun testWithoutPrefix() {
    let returnedValue = executeScript("../cadence/scripts/address_utils_without_prefix.cdc")
    Test.assert(returnedValue, message: "found: false")
}

pub fun testParseUInt64() {
    let returnedValue = executeScript("../cadence/scripts/address_utils_parse_uint64.cdc")
    Test.assert(returnedValue, message: "found: false")
}

pub fun testParseAddress() {
    let returnedValue = executeScript("../cadence/scripts/address_utils_parse_address.cdc")
    Test.assert(returnedValue, message: "found: false")
}

pub fun testIsValidAddress() {
    let returnedValue = executeScript("../cadence/scripts/address_utils_is_valid_address.cdc")
    Test.assert(returnedValue, message: "found: false")
}

pub fun testGetNetworkFromAddress() {
    let returnedValue = executeScript("../cadence/scripts/address_utils_get_network_from_address.cdc")
    Test.assert(returnedValue, message: "found: false")
}

pub fun testGetCurrentNetwork() {
    let returnedValue = executeScript("../cadence/scripts/address_utils_get_current_network.cdc")
    Test.assert(returnedValue, message: "found: false")
}

priv fun executeScript(_ scriptPath: String): Bool {
    var script = Test.readFile(scriptPath)
    let value = blockchain.executeScript(script, [])

    Test.assert(value.status == Test.ResultStatus.succeeded)

    return value.returnValue! as! Bool
}
