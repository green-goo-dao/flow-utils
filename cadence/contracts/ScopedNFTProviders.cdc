import NonFungibleToken from "./NonFungibleToken.cdc"
import StringUtils from "./StringUtils.cdc"

// ScopedNFTProviders
//
// TO AVOID RISK, PLEASE DEPLOY YOUR OWN VERSION OF THIS CONTRACT SO THAT
// MALICIOUS UPDATES ARE NOT POSSIBLE
//
// ScopedNFTProviders are meant to solve the issue of unbounded access to NFT Collections.
// A provider can be given extensible filters which allow limited access to resources based on any trait on the NFT itself.
//
// By using a scoped provider, only a subset of assets can be taken if the provider leaks
// instead of the entire nft collection.
pub contract ScopedNFTProviders {
    pub struct interface NFTFilter {
        pub fun canWithdraw(_ nft: &NonFungibleToken.NFT): Bool
        pub fun markWithdrawn(_ nft: &NonFungibleToken.NFT)
        pub fun getDetails(): {String: AnyStruct}
    }

    pub struct NFTIDFilter: NFTFilter {
        // the ids that are allowed to be withdrawn.
        // If ids[num] is false, the id cannot be withdrawn anymore
        access(self) let ids: {UInt64: Bool}

        init(_ ids: [UInt64]) {
            let d: {UInt64: Bool} = {}
            for i in ids {
                d[i] = true
            }
            self.ids = d
        }

        pub fun canWithdraw(_ nft: &NonFungibleToken.NFT): Bool {
            return self.ids[nft.id] != nil && self.ids[nft.id] == true
        }

        pub fun markWithdrawn(_ nft: &NonFungibleToken.NFT) {
            self.ids[nft.id] = false
        }

        pub fun getDetails(): {String: AnyStruct} {
            return {
                "ids": self.ids
            }
        }
    }

    pub struct UUIDFilter: NFTFilter {
        // the ids that are allowed to be withdrawn.
        // If ids[num] is false, the id cannot be withdrawn anymore
        access(self) let uuids: {UInt64: Bool}

        init(_ uuids: [UInt64]) {
            let d: {UInt64: Bool} = {}
            for i in uuids {
                d[i] = true
            }
            self.uuids = d
        }

        pub fun canWithdraw(_ nft: &NonFungibleToken.NFT): Bool {
            return self.uuids[nft.uuid] != nil && self.uuids[nft.uuid]! == true
        }

        pub fun markWithdrawn(_ nft: &NonFungibleToken.NFT) {
            self.uuids[nft.uuid] = false
        }

        pub fun getDetails(): {String: AnyStruct} {
            return {
                "uuids": self.uuids
            }
        }
    }

    // ScopedNFTProvider
    //
    // Wrapper around an NFT Provider that is restricted to specific ids.
    pub resource ScopedNFTProvider: NonFungibleToken.Provider {
        access(self) let provider: Capability<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
        access(self) let filters: [{NFTFilter}]

        // block timestamp that this provider can no longer be used after
        access(self) let expiration: UFix64?

         pub fun isExpired(): Bool {
            if let expiration = self.expiration {
                return getCurrentBlock().timestamp >= expiration
            }
            return false
        }

        pub init(provider: Capability<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>, filters: [{NFTFilter}], expiration: UFix64?) {
            self.provider = provider
            self.expiration = expiration
            self.filters = filters
        }

        pub fun canWithdraw(_ id: UInt64): Bool {
            if self.isExpired() {
                return false
            }

            let nft = self.provider.borrow()!.borrowNFT(id: id)
            if nft == nil {
                return false
            }

            var i = 0
            while i < self.filters.length {
                if !self.filters[i].canWithdraw(nft) {
                    return false
                }
                i = i + 1
            }
            return true
        }

        pub fun check(): Bool {
            return self.provider.check()
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            pre {
                !self.isExpired(): "provider has expired"
            }

            let nft <- self.provider.borrow()!.withdraw(withdrawID: withdrawID)
            let ref = &nft as &NonFungibleToken.NFT

            var i = 0
            while i < self.filters.length {
                if !self.filters[i].canWithdraw(ref) {
                    panic(StringUtils.join(["cannot withdraw nft. filter of type", self.filters[i].getType().identifier, "failed."], " "))
                }

                self.filters[i].markWithdrawn(ref)
                i = i + 1
            }

            return <-nft
        }

        pub fun getDetails(): [{String: AnyStruct}] {
            let details: [{String: AnyStruct}] = []
            for f in self.filters {
                details.append(f.getDetails())
            }

            return details
        }
    }

    pub fun createScopedNFTProvider(
        provider: Capability<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>,
        filters: [{NFTFilter}],
        expiration: UFix64?
    ): @ScopedNFTProvider {
        return <- create ScopedNFTProvider(provider: provider, filters: filters, expiration: expiration)
    }
}

