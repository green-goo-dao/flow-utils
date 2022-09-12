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
        let expiration = getCurrentBlock().timestamp - 1000.0

        let filter = ScopedFTProviders.AllowanceFilter(allowance)

        let scopedProvider <- ScopedFTProviders.createScopedFTProvider(provider: cap, filters: [filter], expiration: expiration)
        let tokens <- scopedProvider.withdraw(amount: withdrawAmount)
        destroy tokens
        destroy scopedProvider
    }
}
