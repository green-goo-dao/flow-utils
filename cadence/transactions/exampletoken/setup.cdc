import FungibleToken from "../../../cadence/contracts/FungibleToken.cdc"
import ExampleToken from "../../../cadence/contracts/ExampleToken.cdc"

transaction {

    prepare(signer: AuthAccount) {

        // Return early if the account already stores a ExampleToken Vault
        if signer.borrow<&AnyResource>(from: ExampleToken.StoragePath) != nil {
            return
        }

        // Create a new ExampleToken Vault and put it in storage
        signer.save(
            <-ExampleToken.createEmptyVault(),
            to: ExampleToken.StoragePath
        )

        signer.link<&ExampleToken.Vault{FungibleToken.Receiver}>(
            ExampleToken.ReceiverPath,
            target: ExampleToken.StoragePath
        )

        signer.link<&ExampleToken.Vault{FungibleToken.Balance}>(
            ExampleToken.BalancePath,
            target: ExampleToken.StoragePath
        )
    }
}