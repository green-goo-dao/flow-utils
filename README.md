# flow-utils
Utility contracts for flow blockchain smart contracts

|Network|Address|
|-------|-------|
|testnet|0x31ad40c07a2a9788|
|mainnet|0xa340dc0a4ec828ab|

## StringUtils

- split - Split a string into an array by a provided delimiter
- join - Join an array of strings with a provided separator between them

## ScopedProviders

Providers helper structs to scope the access of providers to either specific IDs for NFT Collections,
or an allowance for FungibleTokens. 

**It is encouraged that you copy this contract to your own location
so that there isn't a risk of malicious updates**

### ScopedNFTProvider

Wrapper around an NFT Provider. You can define your own filters to be applied to the provider or
you can make use of some ready-made solutions as well

```cadence
import NonFungibleToken from 0x1
import ExampleNFT from 0x2

import ScopedNFTProviders from 0x3

transaction(ids: [UInt64], withdrawID: UInt64) {
    prepare(acct: AuthAccount) {
        let providerPath = /private/exampleNFTProvider
        acct.unlink(providerPath)
        acct.link<&{NonFungibleToken.Provider}>(providerPath, target: ExampleNFT.CollectionStoragePath)

        // We can specify any kind of filter we want.
        // In this case, ScopedNFTProviders have a few ready-made ones 
        // that folks can use 
        let idFilter = ScopedNFTProviders.NFTIDFilter(ids)
        let scopedProvider <- ScopedNFTProviders.createScopedNFTProvider(provider: cap, filters: [idFilter], expiration: nil)

        let nft <- scopedProvider.withdraw(withdrawID: withdrawID)
        assert(!scopedProvider.canWithdraw(withdrawID), message: "still able to withdraw")

        destroy nft
    }
}
```

### ScopedFungibleTokenProvider

Similar to a ScopedNFTProvider, a ScopedFTProvider wraps a FungibleToken.Provider capability
and applies filters on it to control what way it can be accessed. One such use case could be
for an allowance which restricts the total number of tokens that can be withdrawn through the provider

```cadence
import FungibleToken from 0x1
import ExampleToken from 0x2

import ScopedFTProviders from 0x3

transaction(allowance: UFix64, withdrawAmount: UFix64) {
    prepare(acct: AuthAccount) {
        let providerPath = /private/exampleTokenProvider
        acct.unlink(providerPath)
        acct.link<&{FungibleToken.Provider}>(providerPath, target: ExampleToken.StoragePath)

        let cap = acct.getCapability<&AnyResource{FungibleToken.Provider}>(providerPath)
        assert(cap.check(), message: "invalid private cap")
        
        // We can specify any kind of filter we want.
        // In this case, ScopedFTProviders have a few ready-made ones 
        // that folks can use 
        let filter = ScopedFTProviders.AllowanceFilter(allowance)
        let scopedProvider <- ScopedFTProviders.createScopedFTProvider(provider: cap, filters: [filter], expiration: nil)

        assert(scopedProvider.canWithdraw(withdrawAmount), message: "not able to withdraw")
        let tokens <- scopedProvider.withdraw(amount: withdrawAmount)
        assert(!scopedProvider.canWithdraw(withdrawAmount), message: "still able to withdraw")

        // put it back!
        destroy tokens
    }
}

```
