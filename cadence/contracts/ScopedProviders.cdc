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
    pub struct ScopedNFTProvider {
        access(self) let provider: Capability<&{NonFungibleToken.Provider}>
        pub let ids: {UInt64: Bool}

        pub init(provider: Capability<&{NonFungibleToken.Provider}>, ids: [UInt64]) {
            self.provider = provider

            self.ids = {}
            for id in ids {
                self.ids[id] = true
            }
        }

        pub fun canWithdraw(_ id: UInt64): Bool {
            return self.ids[id] == true
        }

        pub fun check(): Bool {
            return self.provider.check()
        }

        pub fun withdraw(_ id: UInt64): @NonFungibleToken.NFT {
            pre {
                self.canWithdraw(id): "id is not enabled for withdraw"
            }

            let nft <- self.provider.borrow()!.withdraw(withdrawID: id)
            self.ids.remove(key: id)
            return <-nft
        }
    }

    // ScopedFungibleTokenProvider
    //
    // A ScopedFungibleTokenProvider is only permitted to withdraw up to a
    // certain amount of tokens. This allowance is deducted upon each withdraw
    // and will fail if an attempt to withdraw is made that would surpass the limit.
    pub struct ScopedFungibleTokenProvider {
        access(self) let provider: Capability<&{FungibleToken.Provider}>
        pub var allowance: UFix64
        pub var allowanceUsed: UFix64

        pub init(provider: Capability<&{FungibleToken.Provider}>, allowance: UFix64) {
            self.provider = provider
            self.allowance = allowance
            self.allowanceUsed = 0.0
        }

        pub fun check(): Bool {
            return self.provider.check()
        }

        pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
            pre {
                amount + self.allowanceUsed <= self.allowance: "exceeds max allowance"
            }

            self.allowanceUsed = self.allowanceUsed + amount
            return <-self.provider.borrow()!.withdraw(amount: amount)
        }
    }
}