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

    Test.expect(err, Test.beNil())

    let stringUtils = Test.readFile("../cadence/contracts/StringUtils.cdc")
    err = blockchain.deployContract(
        name: "StringUtils",
        code: stringUtils,
        account: account,
        arguments: []
    )

    Test.expect(err, Test.beNil())

    let addressUtils = Test.readFile("../cadence/contracts/AddressUtils.cdc")
    err = blockchain.deployContract(
        name: "AddressUtils",
        code: addressUtils,
        account: account,
        arguments: []
    )

    Test.expect(err, Test.beNil())
}

pub fun testWithoutPrefix() {
    let value = executeScript("../cadence/scripts/address_utils_without_prefix.cdc")
    Test.assertEqual(true, value)
}

pub fun testParseUInt64() {
    let value = executeScript("../cadence/scripts/address_utils_parse_uint64.cdc")
    Test.assertEqual(true, value)
}

pub fun testParseAddress() {
    let value = executeScript("../cadence/scripts/address_utils_parse_address.cdc")
    Test.assertEqual(true, value)
}

pub fun testIsValidAddress() {
    let value = executeScript("../cadence/scripts/address_utils_is_valid_address.cdc")
    Test.assertEqual(true, value)
}

pub fun testGetNetworkFromAddress() {
    let value = executeScript("../cadence/scripts/address_utils_get_network_from_address.cdc")
    Test.assertEqual(true, value)
}

pub fun testGetCurrentNetwork() {
    let value = executeScript("../cadence/scripts/address_utils_get_current_network.cdc")
    Test.assertEqual(true, value)
}

priv fun executeScript(_ scriptPath: String): Bool {
    let script = Test.readFile(scriptPath)
    let value = blockchain.executeScript(script, [])

    Test.expect(value, Test.beSucceeded())

    return value.returnValue! as! Bool
}
