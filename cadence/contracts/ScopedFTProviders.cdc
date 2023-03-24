import FungibleToken from "./FungibleToken.cdc"
import StringUtils from "./StringUtils.cdc"

// ScopedFTProviders
//
// TO AVOID RISK, PLEASE DEPLOY YOUR OWN VERSION OF THIS CONTRACT SO THAT
// MALICIOUS UPDATES ARE NOT POSSIBLE
//
// ScopedProviders are meant to solve the issue of unbounded access FungibleToken vaults
// when a provider is called for.
pub contract ScopedFTProviders {
    pub struct interface FTFilter {
        pub fun canWithdrawAmount(_ amount: UFix64): Bool
        pub fun markAmountWithdrawn(_ amount: UFix64)
        pub fun getDetails(): {String: AnyStruct}
    }

    pub struct AllowanceFilter: FTFilter {
        access(self) let allowance: UFix64
        access(self) var allowanceUsed: UFix64

        init(_ allowance: UFix64) {
            self.allowance = allowance
            self.allowanceUsed = 0.0
        }

        pub fun canWithdrawAmount(_ amount: UFix64): Bool {
            return amount + self.allowanceUsed <= self.allowance
        }

        pub fun markAmountWithdrawn(_ amount: UFix64) {
            self.allowanceUsed = self.allowanceUsed + amount
        }

        pub fun getDetails(): {String: AnyStruct} {
            return {
                "allowance": self.allowance,
                "allowanceUsed": self.allowanceUsed
            }
        }
    }

    // ScopedFTProvider
    //
    // A ScopedFTProvider is a wrapped FungibleTokenProvider with
    // filters that can be defined by anyone using the ScopedFTProvider.
    pub resource ScopedFTProvider: FungibleToken.Provider {
        access(self) let provider: Capability<&{FungibleToken.Provider}>
        access(self) var filters: [{FTFilter}]

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

        pub fun isExpired(): Bool {
            if let expiration = self.expiration {
                return getCurrentBlock().timestamp >= expiration
            }
            return false
        }

        pub fun canWithdraw(_ amount: UFix64): Bool {
            if self.isExpired() {
                return false
            }

            for filter in self.filters {
                if !filter.canWithdrawAmount(amount) {
                    return false
                }
            }

            return true
        }

        pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
            pre {
                !self.isExpired(): "provider has expired"
            }

            var i = 0
            while i < self.filters.length {
                if !self.filters[i].canWithdrawAmount(amount) {
                    panic(StringUtils.join(["cannot withdraw tokens. filter of type", self.filters[i].getType().identifier, "failed."], " "))
                }

                self.filters[i].markAmountWithdrawn(amount)
                i = i + 1
            }

            return <-self.provider.borrow()!.withdraw(amount: amount)
        }

        pub fun getDetails(): [{String: AnyStruct}] {
            let details: [{String: AnyStruct}] = []
            for filter in self.filters {
                details.append(filter.getDetails())
            }

            return details
        }
    }

    pub fun createScopedFTProvider(
        provider: Capability<&{FungibleToken.Provider}>,
        filters: [{FTFilter}],
        expiration: UFix64?
    ): @ScopedFTProvider {
        return <- create ScopedFTProvider(provider: provider, filters: filters, expiration: expiration)
    }
}

