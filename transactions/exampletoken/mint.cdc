import "FungibleToken"
import "ExampleToken"

transaction(recipient: Address, amount: UFix64) {
    // local variable for storing the minter reference
    let admin: &ExampleToken.Administrator

    prepare(acct: auth(Storage) &Account) {
        // borrow a reference to the NFTMinter resource in storage
        self.admin = acct.storage.borrow<&ExampleToken.Administrator>(from: /storage/exampleTokenAdmin)
            ?? panic("Could not borrow a reference to the Token minter")
    }

    execute {
        let minter <- self.admin.createNewMinter(allowedAmount: amount)
        let tokens <- minter.mintTokens(amount: amount)
        destroy minter

        let receiver = getAccount(recipient).capabilities.get<&{FungibleToken.Receiver}>(/public/exampleTokenPublic)!.borrow()!
        receiver.deposit(from: <-tokens)
    }
}
