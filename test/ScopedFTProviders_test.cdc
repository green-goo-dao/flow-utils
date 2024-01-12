import Test
import BlockchainHelpers
import "ExampleToken"

access(all) let admin = Test.getAccount(0x0000000000000007)
access(all) let alice = Test.createAccount()

access(all)
fun setup() {
    var err = Test.deployContract(
        name: "ArrayUtils",
        path: "../contracts/ArrayUtils.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())

    err = Test.deployContract(
        name: "StringUtils",
        path: "../contracts/StringUtils.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())

    err = Test.deployContract(
        name: "ExampleToken",
        path: "../node_modules/@flowtyio/flow-contracts/contracts/example/ExampleToken.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())

    err = Test.deployContract(
        name: "ScopedFTProviders",
        path: "../contracts/ScopedFTProviders.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())
}

access(all)
fun beforeEach() {
    let txResult = executeTransaction(
        "../transactions/exampletoken/destroy.cdc",
        [],
        alice
    )
    Test.expect(txResult, Test.beSucceeded())
}

access(all)
fun testWithdrawTokensSuccessfully() {
    let tokenAmount = 100.0
    let allowance = 10.0

    setupExampleToken(account: alice)
    mintExampleToken(recipient: alice, amount: tokenAmount)

    let txResult = executeTransaction(
        "../transactions/scopedproviders/ft/withdraw_scoped_ft.cdc",
        [allowance, allowance],
        alice
    )
    Test.expect(txResult, Test.beSucceeded())

    let events = Test.eventsOfType(Type<ExampleToken.TokensWithdrawn>())
    let e = events[0] as! ExampleToken.TokensWithdrawn
    Test.assertEqual(alice.address, e.from!)
    Test.assertEqual(allowance, e.amount)
}

access(all)
fun testWithdrawTokensSuccessfullyWithExpiration() {
    let tokenAmount = 100.0
    let allowance = 10.0

    setupExampleToken(account: alice)
    mintExampleToken(recipient: alice, amount: tokenAmount)

    let txResult = executeTransaction(
        "../transactions/scopedproviders/ft/withdraw_scoped_ft_before_expiration.cdc",
        [allowance, allowance],
        alice
    )
    Test.expect(txResult, Test.beSucceeded())

    let events = Test.eventsOfType(Type<ExampleToken.TokensWithdrawn>())
    let e = events[0] as! ExampleToken.TokensWithdrawn
    Test.assertEqual(alice.address, e.from!)
    Test.assertEqual(allowance, e.amount)
}

access(all)
fun testCannotWithdrawMoreThanAllowance() {
    let tokenAmount = 100.0
    let allowance = 10.0

    setupExampleToken(account: alice)
    mintExampleToken(recipient: alice, amount: tokenAmount)

    let txResult = executeTransaction(
        "../transactions/scopedproviders/ft/withdraw_scoped_ft.cdc",
        [allowance, allowance * 2.0],
        alice
    )
    Test.expect(txResult, Test.beFailed())
    Test.assertError(txResult, errorMessage: "not able to withdraw")
}

access(all)
fun testCannotWithdrawPastExpiration() {
    let tokenAmount = 100.0
    let allowance = 10.0

    setupExampleToken(account: alice)
    mintExampleToken(recipient: alice, amount: tokenAmount)

    let txResult = executeTransaction(
        "../transactions/scopedproviders/ft/withdraw_scoped_ft_past_expiration.cdc",
        [allowance, 1.0],
        alice
    )
    Test.expect(txResult, Test.beFailed())
    Test.assertError(txResult, errorMessage: "provider has expired")
}

access(all)
fun testWithdrawTwiceUnderBalance() {
    let tokenAmount = 100.0
    let allowance = 10.0

    setupExampleToken(account: alice)
    mintExampleToken(recipient: alice, amount: tokenAmount)

    let txResult = executeTransaction(
        "../transactions/scopedproviders/ft/withdraw_scoped_ft_twice.cdc",
        [allowance],
        alice
    )
    Test.expect(txResult, Test.beSucceeded())

    let events = Test.eventsOfType(Type<ExampleToken.TokensWithdrawn>())
    let event2 = events[2] as! ExampleToken.TokensWithdrawn
    let event3 = events[3] as! ExampleToken.TokensWithdrawn
    Test.assertEqual(event2.amount + event3.amount, allowance)
}

access(self)
fun setupExampleToken(account: Test.TestAccount) {
    let txResult = executeTransaction(
        "../transactions/exampletoken/setup.cdc",
        [],
        account
    )
    Test.expect(txResult, Test.beSucceeded())
}

access(self)
fun mintExampleToken(recipient: Test.TestAccount, amount: UFix64) {
    let txResult = executeTransaction(
        "../transactions/exampletoken/mint.cdc",
        [recipient.address, amount],
        admin
    )
    Test.expect(txResult, Test.beSucceeded())
}
