import StringUtils from "../contracts/StringUtils.cdc"

pub fun main(): Bool {
    // Act
    var value = StringUtils.count("Hello, World!", "o")

    // Assert
    assert(value == 2)

    return true
}
