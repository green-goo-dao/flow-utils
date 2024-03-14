import "FungibleToken"
import "ExampleToken"

import "ScopedFTProviders"

transaction(allowance: UFix64) {
    prepare(acct: auth(Storage, Capabilities) &Account) {
        let cap = acct.capabilities.storage.issue<auth(FungibleToken.Withdraw) &ExampleToken.Vault>(/storage/exampleTokenVault)
        assert(cap.check(), message: "invalid private cap")

        let filter = ScopedFTProviders.AllowanceFilter(allowance)
        let scopedProvider <- ScopedFTProviders.createScopedFTProvider(provider: cap, filters: [filter], expiration: nil)

        let withdrawAmount = allowance / 2.0
        assert(scopedProvider.canWithdraw(withdrawAmount), message: "not able to withdraw")
        let tokens <- scopedProvider.withdraw(amount: withdrawAmount)
        // put it back!
        cap.borrow()!.deposit(from: <-tokens)

        let tokens2 <- scopedProvider.withdraw(amount: withdrawAmount)
        cap.borrow()!.deposit(from: <-tokens2)

        assert(!scopedProvider.canWithdraw(1.0), message: "still able to withdraw")
        destroy scopedProvider
    }
}
