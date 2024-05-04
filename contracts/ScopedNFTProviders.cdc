import "NonFungibleToken"
import "StringUtils"

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
access(all) contract ScopedNFTProviders {
    access(all) struct interface NFTFilter {
        access(all) fun canWithdraw(_ nft: &{NonFungibleToken.NFT}): Bool
        access(NonFungibleToken.Withdraw) fun markWithdrawn(_ nft: &{NonFungibleToken.NFT})
        access(all) fun getDetails(): {String: AnyStruct}
    }

    access(all) struct NFTIDFilter: NFTFilter {
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

        access(all) fun canWithdraw(_ nft: &{NonFungibleToken.NFT}): Bool {
            return self.ids[nft.id] != nil && self.ids[nft.id] == true
        }

        access(NonFungibleToken.Withdraw) fun markWithdrawn(_ nft: &{NonFungibleToken.NFT}) {
            self.ids[nft.id] = false
        }

        access(all) fun getDetails(): {String: AnyStruct} {
            return {
                "ids": self.ids
            }
        }
    }

    access(all) struct UUIDFilter: NFTFilter {
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

        access(all) fun canWithdraw(_ nft: &{NonFungibleToken.NFT}): Bool {
            return self.uuids[nft.uuid] != nil && self.uuids[nft.uuid]! == true
        }

        access(NonFungibleToken.Withdraw) fun markWithdrawn(_ nft: &{NonFungibleToken.NFT}) {
            self.uuids[nft.uuid] = false
        }

        access(all) fun getDetails(): {String: AnyStruct} {
            return {
                "uuids": self.uuids
            }
        }
    }

    // ScopedNFTProvider
    //
    // Wrapper around an NFT Provider that is restricted to specific ids.
    access(all) resource ScopedNFTProvider: NonFungibleToken.Provider {
        access(self) let provider: Capability<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}>
        access(self) let filters: [{NFTFilter}]

        // block timestamp that this provider can no longer be used after
        access(self) let expiration: UFix64?

         access(all) view fun isExpired(): Bool {
            if let expiration = self.expiration {
                return getCurrentBlock().timestamp >= expiration
            }
            return false
        }

        access(all) init(provider: Capability<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}>, filters: [{NFTFilter}], expiration: UFix64?) {
            self.provider = provider
            self.expiration = expiration
            self.filters = filters
        }

        access(all) fun canWithdraw(_ id: UInt64): Bool {
            if self.isExpired() {
                return false
            }

            if !self.provider.check() {
                return false
            }

            let nft: &{NonFungibleToken.NFT}? = self.provider.borrow()!.borrowNFT(id)
            if nft == nil {
                return false
            }

            var i = 0
            while i < self.filters.length {
                if !self.filters[i].canWithdraw(nft!) {
                    return false
                }
                i = i + 1
            }
            return true
        }

        access(all) fun check(): Bool {
            return self.provider.check()
        }

        access(NonFungibleToken.Withdraw) fun withdraw(withdrawID: UInt64): @{NonFungibleToken.NFT} {
            pre {
                !self.isExpired(): "provider has expired"
            }

            let nft <- self.provider.borrow()!.withdraw(withdrawID: withdrawID)
            let ref = &nft as &{NonFungibleToken.NFT}

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

        access(all) fun getDetails(): [{String: AnyStruct}] {
            let details: [{String: AnyStruct}] = []
            for f in self.filters {
                details.append(f.getDetails())
            }

            return details
        }
    }

    access(all) fun createScopedNFTProvider(
        provider: Capability<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}>,
        filters: [{NFTFilter}],
        expiration: UFix64?
    ): @ScopedNFTProvider {
        return <- create ScopedNFTProvider(provider: provider, filters: filters, expiration: expiration)
    }
}

