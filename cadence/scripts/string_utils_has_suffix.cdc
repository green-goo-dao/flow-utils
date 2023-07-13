import StringUtils from "../contracts/StringUtils.cdc"

pub fun main(): Bool {
    // Act
    var value = StringUtils.hasSuffix("Hello, World!", "ld!")

    // Assert
    assert(value)

    // Act
    value = StringUtils.hasSuffix("ld!", "Hello, World!")

    // Assert
    assert(value == false)

    return true
}
