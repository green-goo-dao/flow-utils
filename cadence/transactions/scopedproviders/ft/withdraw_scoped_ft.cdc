import FungibleToken from "../../../../cadence/contracts/FungibleToken.cdc"
import ExampleToken from "../../../../cadence/contracts/ExampleToken.cdc"

import ScopedFTProviders from "../../../../cadence/contracts/ScopedFTProviders.cdc"

transaction(allowance: UFix64, withdrawAmount: UFix64) {
    prepare(acct: AuthAccount) {
        let providerPath = /private/exampleTokenProvider
        acct.unlink(providerPath)
        acct.link<&{FungibleToken.Provider}>(providerPath, target: ExampleToken.StoragePath)

        let cap = acct.getCapability<&AnyResource{FungibleToken.Provider}>(providerPath)
        assert(cap.check(), message: "invalid private cap")

        let filter = ScopedFTProviders.AllowanceFilter(allowance)
        let scopedProvider <- ScopedFTProviders.createScopedFTProvider(provider: cap, filters: [filter], expiration: nil)

        assert(scopedProvider.canWithdraw(withdrawAmount), message: "not able to withdraw")
        let tokens <- scopedProvider.withdraw(amount: withdrawAmount)

        assert(!scopedProvider.canWithdraw(withdrawAmount + 1.0), message: "still able to withdraw")

        // put it back!
        acct.getCapability<&{FungibleToken.Receiver}>(ExampleToken.ReceiverPath).borrow()!.deposit(from: <-tokens)
        destroy scopedProvider
    }
}
