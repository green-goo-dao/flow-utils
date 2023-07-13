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

    Test.expect(err, Test.beNil())

    let stringUtils = Test.readFile("../cadence/contracts/StringUtils.cdc")
    err = blockchain.deployContract(
        name: "StringUtils",
        code: stringUtils,
        account: account,
        arguments: []
    )

    Test.expect(err, Test.beNil())
}

pub fun testFormat() {
    let value = executeScript("../cadence/scripts/string_utils_format.cdc")
    Test.assertEqual(true, value)
}

pub fun testExplode() {
    let value = executeScript("../cadence/scripts/string_utils_explode.cdc")
    Test.assertEqual(true, value)
}

pub fun testTrimLeft() {
    let value = executeScript("../cadence/scripts/string_utils_trim_left.cdc")
    Test.assertEqual(true, value)
}

pub fun testTrim() {
    let value = executeScript("../cadence/scripts/string_utils_trim.cdc")
    Test.assertEqual(true, value)
}

pub fun testReplaceAll() {
    let value = executeScript("../cadence/scripts/string_utils_replace_all.cdc")
    Test.assertEqual(true, value)
}

pub fun testHasPrefix() {
    let value = executeScript("../cadence/scripts/string_utils_has_prefix.cdc")
    Test.assertEqual(true, value)
}

pub fun testHasSuffix() {
    let value = executeScript("../cadence/scripts/string_utils_has_suffix.cdc")
    Test.assertEqual(true, value)
}

pub fun testIndex() {
    let value = executeScript("../cadence/scripts/string_utils_index.cdc")
    Test.assertEqual(true, value)
}

pub fun testCount() {
    let value = executeScript("../cadence/scripts/string_utils_count.cdc")
    Test.assertEqual(true, value)
}

pub fun testContains() {
    let value = executeScript("../cadence/scripts/string_utils_contains.cdc")
    Test.assertEqual(true, value)
}

pub fun testSubstringUntil() {
    let value = executeScript("../cadence/scripts/string_utils_substring_until.cdc")
    Test.assertEqual(true, value)
}

pub fun testSplit() {
    let value = executeScript("../cadence/scripts/string_utils_split.cdc")
    Test.assertEqual(true, value)
}

pub fun testJoin() {
    let value = executeScript("../cadence/scripts/string_utils_join.cdc")
    Test.assertEqual(true, value)
}

priv fun executeScript(_ scriptPath: String): Bool {
    let script = Test.readFile(scriptPath)
    let value = blockchain.executeScript(script, [])

    Test.expect(value, Test.beSucceeded())

    return value.returnValue! as! Bool
}
