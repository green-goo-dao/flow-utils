import "NonFungibleToken"
import "ExampleNFT"

import "ScopedNFTProviders"

transaction(ids: [UInt64], withdrawID: UInt64) {
    prepare(acct: auth(Storage,Capabilities) &Account) {
        let cap = acct.capabilities.storage.issue<auth(NonFungibleToken.Withdrawable) &ExampleNFT.Collection>(ExampleNFT.CollectionStoragePath)
        assert(cap.check(), message: "invalid provider cap")
        
        let expiration = getCurrentBlock().timestamp - 1000.0
        let idFilter = ScopedNFTProviders.NFTIDFilter(ids)
        let scopedProvider <- ScopedNFTProviders.createScopedNFTProvider(provider: cap, filters: [idFilter], expiration: expiration)

        // this should fail!
        let nft <- scopedProvider.withdraw(withdrawID: withdrawID)
        destroy nft
        destroy scopedProvider
    }
}
