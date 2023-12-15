import Test
import "AccountUtils"

access(all)
fun setup() {
    var err = Test.deployContract(
        name: "AccountUtils",
        path: "../cadence/contracts/AccountUtils.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())
}

access(all)
fun testGetFlowBalance() {
    // Act
    var balance = AccountUtils.getTotalFlowBalance(address:Address(0xf8d6e0586b0a20c7))

    Test.assertEqual(nil, balance)

}

