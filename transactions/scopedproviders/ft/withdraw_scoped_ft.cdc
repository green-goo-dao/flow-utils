import "FungibleToken"
import "ExampleToken"

import "ScopedFTProviders"

transaction(allowance: UFix64, withdrawAmount: UFix64) {
    prepare(acct: auth(Storage, Capabilities) &Account) {
        let cap = acct.capabilities.storage.issue<auth(FungibleToken.Withdrawable) &ExampleToken.Vault>(/storage/exampleTokenVault)
        assert(cap.check(), message: "invalid private cap")

        let filter = ScopedFTProviders.AllowanceFilter(allowance)
        let scopedProvider <- ScopedFTProviders.createScopedFTProvider(provider: cap, filters: [filter], expiration: nil)

        assert(scopedProvider.canWithdraw(withdrawAmount), message: "not able to withdraw")
        let tokens <- scopedProvider.withdraw(amount: withdrawAmount)

        assert(!scopedProvider.canWithdraw(withdrawAmount + 1.0), message: "still able to withdraw")

        // put it back!
        cap.borrow()!.deposit(from: <-tokens)
        destroy scopedProvider
    }
}
