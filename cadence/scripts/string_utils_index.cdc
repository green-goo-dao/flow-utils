import StringUtils from "../contracts/StringUtils.cdc"

pub fun main(): Bool {
    // Act
    var value = StringUtils.index("Hello, Peter!", "Peter", 0)

    // Assert
    assert(value == 7)

    // Act
    value = StringUtils.index("Hello, Peter!", "Mark", 0)

    // Assert
    assert(value == nil)

    return true
}
