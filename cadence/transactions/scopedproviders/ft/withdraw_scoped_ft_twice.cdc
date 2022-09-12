import FungibleToken from "../../../../cadence/contracts/FungibleToken.cdc"
import ExampleToken from "../../../../cadence/contracts/ExampleToken.cdc"

import ScopedFTProviders from "../../../../cadence/contracts/ScopedFTProviders.cdc"

transaction(allowance: UFix64) {
    prepare(acct: AuthAccount) {
        let providerPath = /private/exampleTokenProvider
        acct.unlink(providerPath)
        acct.link<&{FungibleToken.Provider}>(providerPath, target: ExampleToken.StoragePath)

        let cap = acct.getCapability<&AnyResource{FungibleToken.Provider}>(providerPath)
        assert(cap.check(), message: "invalid private cap")

        let filter = ScopedFTProviders.AllowanceFilter(allowance)
        let scopedProvider <- ScopedFTProviders.createScopedFTProvider(provider: cap, filters: [filter], expiration: nil)

        let withdrawAmount = allowance / 2.0
        assert(scopedProvider.canWithdraw(withdrawAmount), message: "not able to withdraw")
        let tokens <- scopedProvider.withdraw(amount: withdrawAmount)
        // put it back!
        acct.getCapability<&{FungibleToken.Receiver}>(ExampleToken.ReceiverPath).borrow()!.deposit(from: <-tokens)

        let tokens2 <- scopedProvider.withdraw(amount: withdrawAmount)
        acct.getCapability<&{FungibleToken.Receiver}>(ExampleToken.ReceiverPath).borrow()!.deposit(from: <-tokens2)

        assert(!scopedProvider.canWithdraw(1.0), message: "still able to withdraw")
        destroy scopedProvider
    }
}
