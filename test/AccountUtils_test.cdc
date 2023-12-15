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

    let address=Test.serviceAccount().address
    let balance = AccountUtils.getTotalFlowBalance(address:address)
    let expected : UFix64? = 1000000000.0
    Test.assertEqual(expected, balance)

}

