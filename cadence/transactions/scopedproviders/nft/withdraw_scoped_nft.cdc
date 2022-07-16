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
        let scopedProvider = ScopedProviders.ScopedNFTProvider(provider: cap, ids: ids)

        let nft <- scopedProvider.withdraw(withdrawID: withdrawID)
        assert(!scopedProvider.canWithdraw(withdrawID), message: "still able to withdraw")

        // put it back!
        acct.getCapability<&{NonFungibleToken.CollectionPublic}>(ExampleNFT.CollectionPublicPath).borrow()!.deposit(token: <-nft)
    }
}
