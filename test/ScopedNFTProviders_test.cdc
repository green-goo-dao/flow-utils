import Test
import BlockchainHelpers
import "ExampleNFT"

access(all) let admin = Test.getAccount(0x0000000000000007)
access(all) let alice = Test.createAccount()

access(all)
fun setup() {
    var err = Test.deployContract(
        name: "ArrayUtils",
        path: "../cadence/contracts/ArrayUtils.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())

    err = Test.deployContract(
        name: "StringUtils",
        path: "../cadence/contracts/StringUtils.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())

    err = Test.deployContract(
        name: "ExampleNFT",
        path: "../cadence/contracts/ExampleNFT.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())

    err = Test.deployContract(
        name: "ScopedNFTProviders",
        path: "../cadence/contracts/ScopedNFTProviders.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())
}

access(all)
fun beforeEach() {
    let txResult = executeTransaction(
        "../cadence/transactions/examplenft/destroy.cdc",
        [],
        alice
    )
    Test.expect(txResult, Test.beSucceeded())
}

access(all)
fun testWithdrawNFTSuccessfully() {
    setupExampleNFT(account: alice)
    let id = mintExampleNFT(recipient: alice)
    let ids: [UInt64] = [id]

    let txResult = executeTransaction(
        "../cadence/transactions/scopedproviders/nft/withdraw_scoped_nft.cdc",
        [ids, id],
        alice
    )
    Test.expect(txResult, Test.beSucceeded())

    let events = Test.eventsOfType(Type<ExampleNFT.Withdraw>())
    let event = events[events.length - 1] as! ExampleNFT.Withdraw
    Test.assertEqual(event.id, id)
}

access(all)
fun testWithdrawNFTSuccessfullyBeforeExpiration() {
    setupExampleNFT(account: alice)
    let id = mintExampleNFT(recipient: alice)
    let ids: [UInt64] = [id]

    let txResult = executeTransaction(
        "../cadence/transactions/scopedproviders/nft/withdraw_scoped_nft_before_expiration.cdc",
        [ids, id],
        alice
    )
    Test.expect(txResult, Test.beSucceeded())

    let events = Test.eventsOfType(Type<ExampleNFT.Withdraw>())
    let event = events[events.length - 1] as! ExampleNFT.Withdraw
    Test.assertEqual(event.id, id)
}

access(all)
fun testFailsToWithdrawNFT() {
    setupExampleNFT(account: alice)
    let id = mintExampleNFT(recipient: alice)
    let id2 = mintExampleNFT(recipient: alice)
    let ids: [UInt64] = [id]

    let txResult = executeTransaction(
        "../cadence/transactions/scopedproviders/nft/withdraw_scoped_nft.cdc",
        [ids, id2],
        alice
    )
    Test.expect(txResult, Test.beFailed())
    Test.assertError(
        txResult,
        errorMessage: "cannot withdraw nft. filter of type A.0000000000000007.ScopedNFTProviders.NFTIDFilter failed."
    )
}

access(all)
fun testFailsToWithdrawNFTPastExpiration() {
    setupExampleNFT(account: alice)
    let id = mintExampleNFT(recipient: alice)
    let ids: [UInt64] = [id]

    let txResult = executeTransaction(
        "../cadence/transactions/scopedproviders/nft/withdraw_scoped_nft_past_expiration.cdc",
        [ids, id],
        alice
    )
    Test.expect(txResult, Test.beFailed())
    Test.assertError(
        txResult,
        errorMessage: "provider has expired"
    )
}

access(all)
fun testShouldWithdrawSuccessfully() {
    setupExampleNFT(account: alice)
    let id = mintExampleNFT(recipient: alice)
    let ids: [UInt64] = [id]

    let txResult = executeTransaction(
        "../cadence/transactions/scopedproviders/nft/withdraw_scoped_nft.cdc",
        [ids, id],
        alice
    )
    Test.expect(txResult, Test.beSucceeded())

    let events = Test.eventsOfType(Type<ExampleNFT.Withdraw>())
    let event = events[events.length - 1] as! ExampleNFT.Withdraw
    Test.assertEqual(event.id, id)
}

access(all)
fun testFailsToWithdrawTwice() {
    setupExampleNFT(account: alice)
    let id = mintExampleNFT(recipient: alice)
    let ids: [UInt64] = [id]

    let txResult = executeTransaction(
        "../cadence/transactions/scopedproviders/nft/withdraw_scoped_nft_twice.cdc",
        [ids, id],
        alice
    )
    Test.expect(txResult, Test.beFailed())
    Test.assertError(
        txResult,
        errorMessage: "cannot withdraw nft. filter of type A.0000000000000007.ScopedNFTProviders.NFTIDFilter failed."
    )
}

access(self)
fun setupExampleNFT(account: Test.Account) {
    let txResult = executeTransaction(
        "../cadence/transactions/examplenft/setup.cdc",
        [],
        account
    )
    Test.expect(txResult, Test.beSucceeded())
}

access(self)
fun mintExampleNFT(recipient: Test.Account): UInt64 {
    let txResult = executeTransaction(
        "../cadence/transactions/examplenft/mint.cdc",
        [recipient.address],
        admin
    )
    Test.expect(txResult, Test.beSucceeded())

    let events = Test.eventsOfType(Type<ExampleNFT.Deposit>())
    let event = events[events.length - 1] as! ExampleNFT.Deposit
    return event.id
}
