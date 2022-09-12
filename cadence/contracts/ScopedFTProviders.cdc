import FungibleToken from "./FungibleToken.cdc"
import StringUtils from "./StringUtils.cdc"

// ScopedFTProviders
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
pub contract ScopedFTProviders {
    pub struct interface FTFilter {
        pub fun canWithdrawAmount(_ amount: UFix64): Bool
        pub fun markAmountWithdrawn(_ amount: UFix64)
    }

    pub struct AllowanceFilter: FTFilter {
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
    pub resource ScopedFungibleTokenProvider: FungibleToken.Provider {
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
                    panic(StringUtils.join(["cannot tokens. filter of type", f.getType().identifier, "failed."], " "))
                }

                f.markAmountWithdrawn(amount)
            }

            return <-self.provider.borrow()!.withdraw(amount: amount)
        }
    }
    
    pub fun createScopedFTProvider(
        provider: Capability<&{FungibleToken.Provider}>, 
        filters: [{FTFilter}],
        expiration: UFix64?
    ): @ScopedFungibleTokenProvider {
        return <- create ScopedFungibleTokenProvider(provider: provider, filters: filters, expiration: expiration)
    }
}
 