import AddressUtils from "../contracts/AddressUtils.cdc"

pub fun main(): Bool {
    // Act
    var value = AddressUtils.parseAddress("0xf8d6e0586b0a20c7")

    // Assert
    assert(value! == Address(0xf8d6e0586b0a20c7))

    // Act
    value = AddressUtils.parseAddress(1005)

    // Assert
    assert(value == nil)

    return true
}
