import "NonFungibleToken"
import "ExampleNFT"

import "ScopedNFTProviders"

transaction(ids: [UInt64], withdrawID: UInt64) {
    prepare(acct: auth(Storage,Capabilities) &Account) {
        let cap = acct.capabilities.storage.issue<auth(NonFungibleToken.Withdrawable) &ExampleNFT.Collection>(ExampleNFT.CollectionStoragePath)
        assert(cap.check(), message: "invalid provider cap")

        let idFilter = ScopedNFTProviders.NFTIDFilter(ids)
        let scopedProvider <- ScopedNFTProviders.createScopedNFTProvider(provider: cap, filters: [idFilter], expiration: nil)

        let nft <- scopedProvider.withdraw(withdrawID: withdrawID)

        // put it back!
        cap.borrow()!.deposit(token: <-nft)
        
        assert(!scopedProvider.canWithdraw(withdrawID), message: "still able to withdraw")
        destroy scopedProvider
    }
}
