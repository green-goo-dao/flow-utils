import StringUtils from "../contracts/StringUtils.cdc"

pub fun main(): Bool {
    // Act
    var value = StringUtils.split("Hello,How,Are,You? Today", ",")

    // Assert
    var expected = ["Hello", "How", "Are", "You? Today"]
    for e in expected {
        assert(value.contains(e))
    }

    return true
}
