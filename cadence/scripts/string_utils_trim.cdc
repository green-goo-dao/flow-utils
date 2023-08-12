import StringUtils from "../contracts/StringUtils.cdc"

pub fun main(): Bool {
    // Act
    var value = StringUtils.trim("  Hello, World!")

    // Assert
    assert(value == "Hello, World!")

    return true
}
