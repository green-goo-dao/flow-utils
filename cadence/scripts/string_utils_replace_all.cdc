import StringUtils from "../contracts/StringUtils.cdc"

pub fun main(): Bool {
    // Act
    var value = StringUtils.replaceAll("Hello, World!", "l", "L")

    // Assert
    assert(value == "HeLLo, WorLd!")

    return true
}
