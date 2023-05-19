import Test

pub let blockchain = Test.newEmulatorBlockchain()
pub let account = blockchain.createAccount()

pub fun setup() {
    blockchain.useConfiguration(Test.Configuration({
        "ArrayUtils": account.address,
        "../contracts/StringUtils.cdc": account.address
    }))

    let arrayUtils = Test.readFile("../cadence/contracts/ArrayUtils.cdc")
    var err = blockchain.deployContract(
        name: "ArrayUtils",
        code: arrayUtils,
        account: account,
        arguments: []
    )

    Test.assert(err == nil)

    let stringUtils = Test.readFile("../cadence/contracts/StringUtils.cdc")
    err = blockchain.deployContract(
        name: "StringUtils",
        code: stringUtils,
        account: account,
        arguments: []
    )

    Test.assert(err == nil)
}

pub fun testFormat() {
    let returnedValue = executeScript("../cadence/scripts/string_utils_format.cdc")
    Test.assert(returnedValue, message: "found: false")
}

pub fun testExplode() {
    let returnedValue = executeScript("../cadence/scripts/string_utils_explode.cdc")
    Test.assert(returnedValue, message: "found: false")
}

pub fun testTrimLeft() {
    let returnedValue = executeScript("../cadence/scripts/string_utils_trim_left.cdc")
    Test.assert(returnedValue, message: "found: false")
}

pub fun testTrim() {
    let returnedValue = executeScript("../cadence/scripts/string_utils_trim.cdc")
    Test.assert(returnedValue, message: "found: false")
}

pub fun testReplaceAll() {
    let returnedValue = executeScript("../cadence/scripts/string_utils_replace_all.cdc")
    Test.assert(returnedValue, message: "found: false")
}

pub fun testHasPrefix() {
    let returnedValue = executeScript("../cadence/scripts/string_utils_has_prefix.cdc")
    Test.assert(returnedValue, message: "found: false")
}

pub fun testHasSuffix() {
    let returnedValue = executeScript("../cadence/scripts/string_utils_has_suffix.cdc")
    Test.assert(returnedValue, message: "found: false")
}

pub fun testIndex() {
    let returnedValue = executeScript("../cadence/scripts/string_utils_index.cdc")
    Test.assert(returnedValue, message: "found: false")
}

pub fun testCount() {
    let returnedValue = executeScript("../cadence/scripts/string_utils_count.cdc")
    Test.assert(returnedValue, message: "found: false")
}

pub fun testContains() {
    let returnedValue = executeScript("../cadence/scripts/string_utils_contains.cdc")
    Test.assert(returnedValue, message: "found: false")
}

pub fun testSubstringUntil() {
    let returnedValue = executeScript("../cadence/scripts/string_utils_substring_until.cdc")
    Test.assert(returnedValue, message: "found: false")
}

pub fun testSplit() {
    let returnedValue = executeScript("../cadence/scripts/string_utils_split.cdc")
    Test.assert(returnedValue, message: "found: false")
}

pub fun testJoin() {
    let returnedValue = executeScript("../cadence/scripts/string_utils_join.cdc")
    Test.assert(returnedValue, message: "found: false")
}

priv fun executeScript(_ scriptPath: String): Bool {
    var script = Test.readFile(scriptPath)
    let value = blockchain.executeScript(script, [])

    Test.assert(value.status == Test.ResultStatus.succeeded)

    return value.returnValue! as! Bool
}
