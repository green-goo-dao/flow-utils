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
    var balance = AccountUtils.getTotalFlowBalance(address:address)

    Test.assertEqual(1000000000.0, balance)

}

