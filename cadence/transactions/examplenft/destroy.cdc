import NonFungibleToken from "../../../cadence/contracts/NonFungibleToken.cdc"
import ExampleNFT from "../../../cadence/contracts/ExampleNFT.cdc"
import MetadataViews from "../../../cadence/contracts/MetadataViews.cdc"

transaction {
    prepare(signer: AuthAccount) {
        let resource <- signer.load<@AnyResource>(from: ExampleNFT.CollectionStoragePath)
        destroy resource
        signer.unlink(ExampleNFT.CollectionPublicPath)
    }
}