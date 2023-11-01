import Test
import "StringUtils"

access(all)
fun setup() {
    var err = Test.deployContract(
        name: "ArrayUtils",
        path: "../cadence/contracts/ArrayUtils.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())

    err = Test.deployContract(
        name: "StringUtils",
        path: "../cadence/contracts/StringUtils.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())
}

access(all)
fun testFormat() {
    // Act
    let str = StringUtils.format("Hello, {name}!", {"name": "Peter"})

    // Assert
    Test.assertEqual("Hello, Peter!", str)
}

access(all)
fun testExplode() {
    // Act
    let chars = StringUtils.explode("Hello!")

    // Assert
    let expected = ["H", "e", "l", "l", "o", "!"]
    Test.assertEqual(expected, chars)
}

access(all)
fun testTrimLeft() {
    // Act
    var str = StringUtils.trimLeft("    Hello, World!")

    // Assert
    Test.assertEqual("Hello, World!", str)

    // Act
    str = StringUtils.trimLeft("")

    // Assert
    Test.assertEqual("", str)
}

access(all)
fun testTrim() {
    // Act
    let str = StringUtils.trim("  Hello, World!")

    // Assert
    Test.assertEqual("Hello, World!", str)
}

access(all)
fun testReplaceAll() {
    // Act
    let str = StringUtils.replaceAll("Hello, World!", "l", "L")

    // Assert
    Test.assertEqual("HeLLo, WorLd!", str)
}

access(all)
fun testHasPrefix() {
    // Act
    var hasPrefix = StringUtils.hasPrefix("Hello, World!", "Hell")

    // Assert
    Test.assert(hasPrefix)

    // Act
    hasPrefix = StringUtils.hasPrefix("Hell", "Hello, World!")

    // Assert
    Test.assertEqual(false, hasPrefix)
}

access(all)
fun testHasSuffix() {
    // Act
    var hasSuffix = StringUtils.hasSuffix("Hello, World!", "ld!")

    // Assert
    Test.assert(hasSuffix)

    // Act
    hasSuffix = StringUtils.hasSuffix("ld!", "Hello, World!")

    // Assert
    Test.assertEqual(false, hasSuffix)
}

access(all)
fun testIndex() {
    // Act
    var index = StringUtils.index("Hello, Peter!", "Peter", 0)

    // Assert
    Test.assertEqual(7 as Int?, index)

    // Act
    index = StringUtils.index("Hello, Peter!", "Mark", 0)

    // Assert
    Test.assertEqual(nil, index)
}

access(all)
fun testCount() {
    // Act
    let count = StringUtils.count("Hello, World!", "o")

    // Assert
    Test.assertEqual(2, count)
}

access(all)
fun testContains() {
    // Act
    var found = StringUtils.contains("Hello, World!", "orl")

    // Assert
    Test.assert(found)

    // Act
    found = StringUtils.contains("Hello, World!", "wow")

    // Assert
    Test.assertEqual(false, found)
}

access(all)
fun testSubstringUntil() {
    // Act
    var substring = StringUtils.substringUntil(
        "Hello, sir. How are you today?",
        ".",
        0
    )

    // Assert
    Test.assertEqual("Hello, sir", substring)

    // Act
    substring = StringUtils.substringUntil("Hello, sir!", ".", 0)

    // Assert
    Test.assertEqual("Hello, sir!", substring)
}

access(all)
fun testSplit() {
    // Act
    let phrases = StringUtils.split("Hello,How,Are,You? Today", ",")

    // Assert
    let expected = ["Hello", "How", "Are", "You? Today"]
    Test.assertEqual(expected, phrases)
}

access(all)
fun testJoin() {
    // Act
    let str = StringUtils.join(["Hello", "How", "Are", "You", "Today?"], " ")

    // Assert
    Test.assertEqual("Hello How Are You Today?", str)
}
