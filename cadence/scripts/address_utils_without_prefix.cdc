import AddressUtils from "../contracts/AddressUtils.cdc"

pub fun main(): Bool {
    // Act
    var value = AddressUtils.withoutPrefix("0xf8d6e0586b0a20c7")

    // Assert
    assert(value == "f8d6e0586b0a20c7")

    // Act
    // Odd length
    value = AddressUtils.withoutPrefix("8d6e0586b0a20c7")

    // Assert
    assert(value == "08d6e0586b0a20c7")

    return true
}
