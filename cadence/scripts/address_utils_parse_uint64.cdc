import FlowToken from 0x0ae53cb6e3f42a79
import AddressUtils from "../contracts/AddressUtils.cdc"

pub fun main(): Bool {
    // Act
    var value = AddressUtils.parseUInt64("0xf8d6e0586b0a20c7")

    // Assert
    assert(value == 17930765636779778247)

    // Act
    value = AddressUtils.parseUInt64(Address(0xf8d6e0586b0a20c7))

    // Assert
    assert(value == 17930765636779778247)

    // Act
    value = AddressUtils.parseUInt64(FlowToken.getType())

    // Assert
    assert(value == 785100466252163705)

    // Act
    value = AddressUtils.parseUInt64(0x01)

    // Assert
    assert(value == nil)

    // Act
    value = AddressUtils.parseUInt64("hello".getType())

    // Assert
    assert(value == nil)

    return true
}
