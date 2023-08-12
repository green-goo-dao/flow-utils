import StringUtils from "../contracts/StringUtils.cdc"

pub fun main(): Bool {
    // Act
    var value = StringUtils.explode("Hello!")

    // Assert
    var expected = ["H", "e", "l", "l", "o", "!"]
    for char in expected {
        assert(value.contains(char))
    }

    return true
}
