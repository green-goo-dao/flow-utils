import NonFungibleToken from "../../../../cadence/contracts/NonFungibleToken.cdc"
import ExampleNFT from "../../../../cadence/contracts/ExampleNFT.cdc"

import ScopedNFTProviders from "../../../../cadence/contracts/ScopedNFTProviders.cdc"

transaction(ids: [UInt64], withdrawID: UInt64) {
    prepare(acct: AuthAccount) {
        let providerPath = /private/exampleNFTProvider
        acct.unlink(providerPath)
        acct.link<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(providerPath, target: ExampleNFT.CollectionStoragePath)

        let cap = acct.getCapability<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(providerPath)
        assert(cap.check(), message: "invalid private cap")

        let idFilter = ScopedNFTProviders.NFTIDFilter(ids)
        let scopedProvider <- ScopedNFTProviders.createScopedNFTProvider(provider: cap, filters: [idFilter], expiration: nil)

        assert(scopedProvider.canWithdraw(withdrawID), message: "not able to withdraw")
        let nft <- scopedProvider.withdraw(withdrawID: withdrawID)

        // put it back!
        acct.getCapability<&{NonFungibleToken.CollectionPublic}>(ExampleNFT.CollectionPublicPath).borrow()!.deposit(token: <-nft)
        assert(!scopedProvider.canWithdraw(withdrawID), message: "still able to withdraw")

        // this should panic!
        let secondAttempt <- scopedProvider.withdraw(withdrawID: withdrawID)
        destroy secondAttempt
        destroy scopedProvider
    }
}
