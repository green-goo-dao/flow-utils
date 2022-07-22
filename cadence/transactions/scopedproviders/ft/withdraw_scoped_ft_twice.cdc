import FungibleToken from "../../../../cadence/contracts/FungibleToken.cdc"
import ExampleToken from "../../../../cadence/contracts/ExampleToken.cdc"

import ScopedProviders from "../../../../cadence/contracts/ScopedProviders.cdc"

transaction(allowance: UFix64, withdrawAmount: UFix64) {
    prepare(acct: AuthAccount) {
        let providerPath = /private/exampleTokenProvider
        acct.unlink(providerPath)
        acct.link<&{FungibleToken.Provider}>(providerPath, target: ExampleToken.StoragePath)

        let cap = acct.getCapability<&AnyResource{FungibleToken.Provider}>(providerPath)
        assert(cap.check(), message: "invalid private cap")
        let scopedProvider <- ScopedProviders.createScopedFungibleTokenProvider(provider: cap, allowance: allowance, expiration: nil)

        assert(scopedProvider.canWithdraw(withdrawAmount), message: "not able to withdraw")
        let tokens <- scopedProvider.withdraw(amount: withdrawAmount)        
        // put it back!
        acct.getCapability<&{FungibleToken.Receiver}>(ExampleToken.ReceiverPath).borrow()!.deposit(from: <-tokens)

        let tokens2 <- scopedProvider.withdraw(amount: withdrawAmount)
        acct.getCapability<&{FungibleToken.Receiver}>(ExampleToken.ReceiverPath).borrow()!.deposit(from: <-tokens2)
        
        assert(!scopedProvider.canWithdraw(withdrawAmount), message: "still able to withdraw")
        destroy scopedProvider
    }
}
