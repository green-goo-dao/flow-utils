import ExampleToken from "../../../cadence/contracts/ExampleToken.cdc"

transaction {
    prepare(acct: AuthAccount) {
        let resource <- acct.load<@AnyResource>(from: ExampleToken.StoragePath)
        destroy resource
        acct.unlink(ExampleToken.ReceiverPath)
        acct.unlink(ExampleToken.BalancePath)
    }
}