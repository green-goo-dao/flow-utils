import FungibleToken from "./FungibleToken.cdc"
import NonFungibleToken from "./NonFungibleToken.cdc"

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
    // ScopedNFTProvider
    //
    // Wrapper around an NFT Provider that is restricted to specific ids.
    // Once the ID has been withdrawn, it is removed from the list so that it cannot
    // be used again. 
    pub resource ScopedNFTProvider {
        access(self) let provider: Capability<&{NonFungibleToken.Provider}>
        pub let ids: {UInt64: Bool}
        // block timestamp that this provider can no longer be used after
        access(self) let expiration: UFix64?

        pub init(provider: Capability<&{NonFungibleToken.Provider}>, ids: [UInt64], expiration: UFix64?) {
            self.provider = provider
            self.expiration = expiration

            self.ids = {}
            for id in ids {
                self.ids[id] = true
            }
        }

        pub fun canWithdraw(_ id: UInt64): Bool {
            return self.ids.containsKey(id) && (self.expiration == nil || getCurrentBlock().timestamp <= self.expiration!)
        }

        pub fun check(): Bool {
            return self.provider.check()
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            pre {
                self.ids.containsKey(withdrawID): "id is not enabled for withdraw"
                self.expiration == nil || getCurrentBlock().timestamp <= self.expiration!: "provider has expired"
            }

            let nft <- self.provider.borrow()!.withdraw(withdrawID: withdrawID)
            self.ids.remove(key: withdrawID)
            return <-nft
        }
    }

    // ScopedFungibleTokenProvider
    //
    // A ScopedFungibleTokenProvider is only permitted to withdraw up to a
    // certain amount of tokens. This allowance is deducted upon each withdraw
    // and will fail if an attempt to withdraw is made that would surpass the limit.
    pub resource ScopedFungibleTokenProvider {
        access(self) let provider: Capability<&{FungibleToken.Provider}>
        pub var allowance: UFix64
        pub var allowanceUsed: UFix64

        // block timestamp that this provider can no longer be used after
        access(self) let expiration: UFix64?

        pub init(provider: Capability<&{FungibleToken.Provider}>, allowance: UFix64, expiration: UFix64?) {
            self.provider = provider
            self.allowance = allowance
            self.allowanceUsed = 0.0
            self.expiration = expiration
        }

        pub fun check(): Bool {
            return self.provider.check()
        }

        pub fun canWithdraw(_ amount: UFix64): Bool {
            return amount + self.allowanceUsed <= self.allowance && (self.expiration == nil || getCurrentBlock().timestamp <= self.expiration!)
        }

        pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
            pre {
                amount + self.allowanceUsed <= self.allowance: "exceeds max allowance"
                self.expiration == nil || self.expiration! >= getCurrentBlock().timestamp: "provider has expired"
            }

            self.allowanceUsed = self.allowanceUsed + amount
            return <-self.provider.borrow()!.withdraw(amount: amount)
        }
    }

    pub fun createScopedNFTProvider(
        provider: Capability<&{NonFungibleToken.Provider}>, 
        ids: [UInt64], 
        expiration: UFix64?
    ): @ScopedNFTProvider {
        return <- create ScopedNFTProvider(provider: provider, ids: ids, expiration: expiration)
    }
    
    pub fun createScopedFungibleTokenProvider(
        provider: Capability<&{FungibleToken.Provider}>, 
        allowance: UFix64, 
        expiration: UFix64?
    ): @ScopedFungibleTokenProvider {
        return <- create ScopedFungibleTokenProvider(provider: provider, allowance: allowance, expiration: expiration)
    }
}