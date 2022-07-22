import NonFungibleToken from "../../../../cadence/contracts/NonFungibleToken.cdc"
import ExampleNFT from "../../../../cadence/contracts/ExampleNFT.cdc"

import ScopedProviders from "../../../../cadence/contracts/ScopedProviders.cdc"

transaction(ids: [UInt64], withdrawID: UInt64) {
    prepare(acct: AuthAccount) {
        let providerPath = /private/exampleNFTProvider
        acct.unlink(providerPath)
        acct.link<&{NonFungibleToken.Provider}>(providerPath, target: ExampleNFT.CollectionStoragePath)

        let cap = acct.getCapability<&{NonFungibleToken.Provider}>(providerPath)
        assert(cap.check(), message: "invalid private cap")
        let expiration = getCurrentBlock().timestamp - 1000.0
        let scopedProvider <- ScopedProviders.createScopedNFTProvider(provider: cap, ids: ids, expiration: expiration)

        // this should fail!
        let nft <- scopedProvider.withdraw(withdrawID: withdrawID)
        destroy nft
        destroy scopedProvider
    }
}
