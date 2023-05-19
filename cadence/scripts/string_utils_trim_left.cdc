import StringUtils from "../contracts/StringUtils.cdc"

pub fun main(): Bool {
    // Act
    var value = StringUtils.trimLeft("    Hello, World!")

    // Assert
    assert(value == "Hello, World!")

    // Act
    value = StringUtils.trimLeft("")

    // Assert
    assert(value == "")

    return true
}
