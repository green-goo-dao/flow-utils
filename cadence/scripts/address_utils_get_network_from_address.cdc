import AddressUtils from "../contracts/AddressUtils.cdc"

pub fun main(): Bool {
    // Act
    let network = AddressUtils.getNetworkFromAddress(1541)

    // Assert
    assert(network == nil)

    return true
}
