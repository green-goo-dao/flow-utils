import "NonFungibleToken"
import "ExampleNFT"
import "MetadataViews"

transaction {

    prepare(signer: auth(Storage, Capabilities) &Account) {

        // Return early if the account already stores a ExampleToken Vault
        if signer.storage.borrow<&AnyResource>(from: ExampleNFT.CollectionStoragePath) != nil {
            return
        }

        // Create a new ExampleToken Vault and put it in storage
        signer.storage.save(
            <-ExampleNFT.createEmptyCollection(),
            to: ExampleNFT.CollectionStoragePath
        )

        // Create a public capability to the Vault that only exposes
        // the balance field through the Balance interface
        let cap = signer.capabilities.storage.issue<&ExampleNFT.Collection>(ExampleNFT.CollectionStoragePath)
        signer.capabilities.publish(cap, at: ExampleNFT.CollectionPublicPath)
    }
}