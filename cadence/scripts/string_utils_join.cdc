import StringUtils from "../contracts/StringUtils.cdc"

pub fun main(): Bool {
    // Act
    var value = StringUtils.join(["Hello", "How", "Are", "You", "Today?"], " ")

    // Assert
    assert(value == "Hello How Are You Today?")

    return true
}
