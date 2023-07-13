import StringUtils from "../contracts/StringUtils.cdc"

pub fun main(): Bool {
    // Act
    var value = StringUtils.format("Hello, {name}!", {"name": "Peter"})

    // Assert
    assert(value == "Hello, Peter!")

    return true
}
