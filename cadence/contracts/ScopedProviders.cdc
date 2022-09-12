import FungibleToken from "./FungibleToken.cdc"
import NonFungibleToken from "./NonFungibleToken.cdc"
import StringUtils from "./StringUtils.cdc"

// ScopedProviders
//
// TO AVOID RISK, PLEASE DEPLOY YOUR OWN VERSION OF THIS CONTRACT SO THAT
// MALICIOUS UPDATES ARE NOT POSSIBLE
// 
// ScopedProviders are meant to solve the issue of unbounded access to NFT Collections
// and FungibleToken vaults when a provider is called for. A provider to a sensitive resource
// like a wallet's tokens or their NFTs should be scoped to specific amounts or ids to limit
// the blast radius of things leaking or being exploited. 
//
// By using a scoped provider, only a subset of assets can be taken if the provider leaks
// instead of the entire nft collection or vault depending on the capability being used
pub contract ScopedProviders {
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
            return self.ids.containsKey(nft.id)
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
            return self.uuids.containsKey(nft.uuid)
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
    pub resource ScopedNFTProvider {
        access(self) let provider: Capability<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>
        access(self) let filters: [{NFTFilter}]

        // block timestamp that this provider can no longer be used after
        access(self) let expiration: UFix64?

        pub init(provider: Capability<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>, filters: [{NFTFilter}], expiration: UFix64?) {
            self.provider = provider
            self.expiration = expiration
            self.filters = filters
        }

        pub fun canWithdraw(_ id: UInt64): Bool {
            let nft = self.provider.borrow()!.borrowNFT(id: id)
            if nft == nil {
                return false
            }

            for f in self.filters {
                if !f.canWithdraw(nft) {
                    return false
                }
            }
            return true
        }

        pub fun check(): Bool {
            return self.provider.check()
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            pre {
                self.expiration == nil || getCurrentBlock().timestamp <= self.expiration!: "provider has expired"
            }

            let nft <- self.provider.borrow()!.withdraw(withdrawID: withdrawID)
            let ref = &nft as &NonFungibleToken.NFT
            for f in self.filters {
                if !f.canWithdraw(ref) {
                    panic(StringUtils.join(strs: ["cannot withdraw nft. filter of type", f.getType().identifier, "failed."], separator: " "))
                }

                f.markWithdrawn(ref)
            }

            return <-nft
        }
    }

    pub struct interface FTFilter {
        pub fun canWithdrawAmount(_ amount: UFix64): Bool
        pub fun markAmountWithdrawn(_ amount: UFix64)
    }

    pub struct FTAllowanceFilter: FTFilter {
        access(self) var allowance: UFix64
        access(self) var allowanceUsed: UFix64

        init(_ allowance: UFix64) {
            self.allowance = allowance
            self.allowanceUsed = 0.0
        }

        pub fun canWithdrawAmount(_ amount: UFix64): Bool {
            return amount + self.allowanceUsed <= self.allowance
        }

        pub fun markAmountWithdrawn(_ amount: UFix64) {
            self.allowance = self.allowance + amount
        }
    }

    // ScopedFungibleTokenProvider
    //
    // A ScopedFungibleTokenProvider is only permitted to withdraw up to a
    // certain amount of tokens. This allowance is deducted upon each withdraw
    // and will fail if an attempt to withdraw is made that would surpass the limit.
    pub resource ScopedFungibleTokenProvider {
        access(self) let provider: Capability<&{FungibleToken.Provider}>
        access(self) let filters: [{FTFilter}]

        // block timestamp that this provider can no longer be used after
        access(self) let expiration: UFix64?

        pub init(provider: Capability<&{FungibleToken.Provider}>, filters: [{FTFilter}], expiration: UFix64?) {
            self.provider = provider
            self.filters = filters
            self.expiration = expiration
        }

        pub fun check(): Bool {
            return self.provider.check()
        }

        pub fun canWithdraw(_ amount: UFix64): Bool {
            if self.expiration != nil && getCurrentBlock().timestamp >= self.expiration! {
                return false
            }

            for f in self.filters {
                if !f.canWithdrawAmount(amount) {
                    return false
                }
            }

            return true
        }

        pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
            pre {
                self.expiration == nil || self.expiration! >= getCurrentBlock().timestamp: "provider has expired"
            }

            for f in self.filters {
                if !f.canWithdrawAmount(amount) {
                    panic(StringUtils.join(strs: ["cannot tokens. filter of type", f.getType().identifier, "failed."], separator: " "))
                }

                f.markAmountWithdrawn(amount)
            }

            return <-self.provider.borrow()!.withdraw(amount: amount)
        }
    }

    pub fun createScopedNFTProvider(
        provider: Capability<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>, 
        filters: [{NFTFilter}], 
        expiration: UFix64?
    ): @ScopedNFTProvider {
        return <- create ScopedNFTProvider(provider: provider, filters: filters, expiration: expiration)
    }
    
    pub fun createScopedFungibleTokenProvider(
        provider: Capability<&{FungibleToken.Provider}>, 
        filters: [{FTFilter}],
        expiration: UFix64?
    ): @ScopedFungibleTokenProvider {
        return <- create ScopedFungibleTokenProvider(provider: provider, filters: filters, expiration: expiration)
    }
}
 