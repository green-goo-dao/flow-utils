import "ExampleToken"

transaction {
    prepare(acct: auth(Storage, Capabilities) &Account) {
        let r <- acct.storage.load<@AnyResource>(from: /storage/exampleTokenVault)
        destroy r
        acct.capabilities.unpublish(/public/exampleTokenPublic)
    }
}