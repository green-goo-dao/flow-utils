import StringUtils from "../contracts/StringUtils.cdc"

pub fun main(): Bool {
    // Act
    var value = StringUtils.contains("Hello, World!", "orl")

    // Assert
    assert(value)

    // Act
    value = StringUtils.contains("Hello, World!", "wow")

    // Assert
    assert(value == false)

    return true
}
