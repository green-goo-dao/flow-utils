import "FungibleToken"
import "ExampleToken"

import "ScopedFTProviders"

transaction(allowance: UFix64, withdrawAmount: UFix64) {
    prepare(acct: auth(Storage, Capabilities) &Account) {
        let cap = acct.capabilities.storage.issue<auth(FungibleToken.Withdraw) &ExampleToken.Vault>(/storage/exampleTokenVault)
        
        assert(cap.check(), message: "invalid provider cap")
        let expiration = getCurrentBlock().timestamp - 1000.0

        let filter = ScopedFTProviders.AllowanceFilter(allowance)

        let scopedProvider <- ScopedFTProviders.createScopedFTProvider(provider: cap, filters: [filter], expiration: expiration)
        let tokens <- scopedProvider.withdraw(amount: withdrawAmount)
        destroy tokens
        destroy scopedProvider
    }
}
