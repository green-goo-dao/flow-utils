import StringUtils from "../contracts/StringUtils.cdc"

pub fun main(): Bool {
    // Act
    var value = StringUtils.substringUntil("Hello, sir. How are you today?", ".", 0)

    // Assert
    assert(value == "Hello, sir")

    // Act
    value = StringUtils.substringUntil("Hello, sir!", ".", 0)

    // Assert
    assert(value == "Hello, sir!")

    return true
}
