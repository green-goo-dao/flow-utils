import StringUtils from "../contracts/StringUtils.cdc"

pub fun main(): Bool {
    // Act
    var value = StringUtils.hasPrefix("Hello, World!", "Hell")

    // Assert
    assert(value)

    // Act
    value = StringUtils.hasPrefix("Hell", "Hello, World!")

    // Assert
    assert(value == false)

    return true
}
