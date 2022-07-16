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

### ScopedNonFungibleTokenProvider

Wrapper around an NFT Provider that is restricted to specific ids.
Once an nft has been withdrawn, its id cannot be withdrawn again!

```cadence
import NonFungibleToken from 0x1
import ExampleNFT from 0x2

import ScopedProviders from 0x3

transaction(ids: [UInt64], withdrawID: UInt64) {
    prepare(acct: AuthAccount) {
        let providerPath = /private/exampleNFTProvider
        acct.unlink(providerPath)
        acct.link<&{NonFungibleToken.Provider}>(providerPath, target: ExampleNFT.CollectionStoragePath)

        let cap = acct.getCapability<&{NonFungibleToken.Provider}>(providerPath)
        assert(cap.check(), message: "invalid private cap")
        let scopedProvider = ScopedProviders.ScopedNFTProvider(provider: cap, ids: ids)

        let nft <- scopedProvider.withdraw(withdrawID: withdrawID)
        assert(!scopedProvider.canWithdraw(withdrawID), message: "still able to withdraw")

        destroy nft
    }
}
```

### ScopedFungibleTokenProvider

A ScopedFungibleTokenProvider is only permitted to withdraw up to a
certain amount of tokens. This allowance is deducted upon each withdraw
and will fail if an attempt to withdraw is made that would surpass the limit.

```cadence
import FungibleToken from 0x1
import ExampleToken from 0x2

import ScopedProviders from 0x3

transaction(allowance: UFix64, withdrawAmount: UFix64) {
    prepare(acct: AuthAccount) {
        let providerPath = /private/exampleTokenProvider
        acct.unlink(providerPath)
        acct.link<&{FungibleToken.Provider}>(providerPath, target: ExampleToken.StoragePath)

        let cap = acct.getCapability<&AnyResource{FungibleToken.Provider}>(providerPath)
        assert(cap.check(), message: "invalid private cap")
        let scopedProvider = ScopedProviders.ScopedFungibleTokenProvider(provider: cap, allowance: allowance)

        assert(scopedProvider.canWithdraw(withdrawAmount), message: "not able to withdraw")
        let tokens <- scopedProvider.withdraw(amount: withdrawAmount)
        assert(!scopedProvider.canWithdraw(withdrawAmount), message: "still able to withdraw")

        // put it back!
        destroy tokens
    }
}

```
