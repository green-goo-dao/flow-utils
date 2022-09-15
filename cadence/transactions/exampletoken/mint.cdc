import FungibleToken from "../../../cadence/contracts/FungibleToken.cdc"
import ExampleToken from "../../../cadence/contracts/ExampleToken.cdc"

transaction(recipient: Address, amount: UFix64) {
    // local variable for storing the minter reference
    let admin: &ExampleToken.Administrator

    prepare(acct: AuthAccount) {
        // borrow a reference to the NFTMinter resource in storage
        self.admin = acct.borrow<&ExampleToken.Administrator>(from: ExampleToken.AdminPath)
            ?? panic("Could not borrow a reference to the Token minter")
    }

    execute {
        let minter <- self.admin.createNewMinter(allowedAmount: amount)
        let tokens <- minter.mintTokens(amount: amount)
        destroy minter

        let receiver = getAccount(recipient).getCapability<&{FungibleToken.Receiver}>(ExampleToken.ReceiverPath).borrow()!
        receiver.deposit(from: <-tokens)
    }
}
