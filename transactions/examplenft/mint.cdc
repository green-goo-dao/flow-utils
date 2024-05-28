import "NonFungibleToken"
import "ExampleNFT"
import "MetadataViews"


transaction(recipient: Address) {
    // local variable for storing the minter reference
    let minter: &ExampleNFT.NFTMinter

    prepare(acct: auth(Storage) &Account) {
        // borrow a reference to the NFTMinter resource in storage
        self.minter = acct.storage.borrow<&ExampleNFT.NFTMinter>(from: /storage/exampleNFTMinter)
            ?? panic("Could not borrow a reference to the NFT minter")
    }

    execute {
        let receiver = getAccount(recipient).capabilities.get<&{NonFungibleToken.Collection}>(ExampleNFT.CollectionPublicPath).borrow()!
        self.minter.mintNFT(recipient: receiver, name: "testname", description: "descr", thumbnail: "image.html", royaltyReceipient: self.minter.owner!.address)
    }
}
