import AddressUtils from "../contracts/AddressUtils.cdc"

pub fun main(): Bool {
    // Act
    var network = AddressUtils.currentNetwork()

    // Assert
    assert(network == "EMULATOR")

    return true
}
