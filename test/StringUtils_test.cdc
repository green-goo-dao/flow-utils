import Test
import "StringUtils"

access(all)
fun setup() {
    var err = Test.deployContract(
        name: "ArrayUtils",
        path: "../contracts/ArrayUtils.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())

    err = Test.deployContract(
        name: "StringUtils",
        path: "../contracts/StringUtils.cdc",
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
fun testFormatMissing() {
    // Act
    let str = StringUtils.format("Hello, {name}!", {})

    // Assert
    Test.assertEqual("Hello, {name}!", str)
}

access(all)
fun testFormatExtra() {
    // Act
    let str = StringUtils.format("Hello, {name}!", {"name": "Peter", "foo": "bar"})

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
fun testExplodeEmpty() {
    // Act
    let chars = StringUtils.explode("")

    // Assert
    let expected: [String] = []
    Test.assertEqual(expected, chars)
}

access(all)
fun testTrimLeft() {
    // Act
    var str = StringUtils.trimLeft("    Hello, World!")

    // Assert
    Test.assertEqual("Hello, World!", str)
}

access(all)
fun testTrimLeftEmpty() {

    // Act
    let str = StringUtils.trimLeft("")

    // Assert
    Test.assertEqual("", str)
}

access(all)
fun testTrimLeftOnlySpaces() {

    // Act
    let str = StringUtils.trimLeft("   ")

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
fun testHasPrefixValid() {
    // Act
    var hasPrefix = StringUtils.hasPrefix("Hello, World!", "Hell")

    // Assert
    Test.assert(hasPrefix)
}

access(all)
fun testHasPrefixInvalid() {
    // Act
    let hasPrefix = StringUtils.hasPrefix("Hell", "Hello, World!")

    // Assert
    Test.assert(!hasPrefix)
}

access(all)
fun testHasPrefixEmpty() {
    // Act
    var hasPrefix = StringUtils.hasPrefix("", "Hell")

    // Assert
    Test.assert(!hasPrefix)
}

access(all)
fun testHasPrefixEmptySuffix() {
    // Act
    var hasPrefix = StringUtils.hasPrefix("foo", "")

    // Assert
    Test.assert(hasPrefix)
}

access(all)
fun testHasSuffixValid() {
    // Act
    var hasSuffix = StringUtils.hasSuffix("Hello, World!", "ld!")

    // Assert
    Test.assert(hasSuffix)
}

access(all)
fun testHasSuffixInvalid() {
    // Act
    let hasSuffix = StringUtils.hasSuffix("ld!", "Hello, World!")

    // Assert
    Test.assert(!hasSuffix)
}

access(all)
fun testHasSuffixEmpty() {
    // Act
    let hasSuffix = StringUtils.hasSuffix("", "Hello, World!")

    // Assert
    Test.assert(!hasSuffix)
}

access(all)
fun testHasSuffixEmptySuffix() {
    // Act
    let hasSuffix = StringUtils.hasSuffix("foo", "")

    // Assert
    Test.assert(hasSuffix)
}

access(all)
fun testIndexValid() {
    // Act
    var index = StringUtils.index("Hello, Peter!", "Peter", 0)

    // Assert
    Test.assertEqual(7 as Int?, index)
}

access(all)
fun testIndexInvalid() {
    // Act
    let index = StringUtils.index("Hello, Peter!", "Mark", 0)

    // Assert
    Test.assertEqual(nil, index)
}

access(all)
fun testIndexValidOffset() {
    // Act
    var index = StringUtils.index("Peter, Peter!", "Peter", 1)

    // Assert
    Test.assertEqual(7 as Int?, index)
}

access(all)
fun testIndexInvalidOffset() {
    // Act
    let index = StringUtils.index("Mark, Peter!", "Mark", 1)

    // Assert
    Test.assertEqual(nil, index)
}

access(all)
fun testIndexEmpty() {
    // Act
    var index = StringUtils.index("", "Peter", 0)

    // Assert
    Test.assertEqual(nil, index)
}

access(all)
fun testIndexEmptySearch() {
    // Act
    var index = StringUtils.index("foo", "", 0)

    // Assert
    Test.assertEqual(0 as Int?, index)
}

access(all)
fun testCount() {
    // Act
    let count = StringUtils.count("Hello, World!", "o")

    // Assert
    Test.assertEqual(2, count)
}

access(all)
fun testContainsValid() {
    // Act
    var found = StringUtils.contains("Hello, World!", "orl")

    // Assert
    Test.assert(found)
}

access(all)
fun testContainsInvalid() {
    // Act
    let found = StringUtils.contains("Hello, World!", "wow")

    // Assert
    Test.assert(!found)
}

access(all)
fun testSubstringUntilValid() {
    // Act
    var substring = StringUtils.substringUntil(
        "Hello, sir. How are you today?",
        ".",
        0
    )

    // Assert
    Test.assertEqual("Hello, sir", substring)

}

access(all)
fun testSubstringUntilInvalid() {
    // Act
    let substring = StringUtils.substringUntil("Hello, sir!", ".", 0)

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
fun testSplitEmpty() {
    // Act
    let phrases = StringUtils.split("", ",")

    // Assert
    let expected = [""]
    Test.assertEqual(expected, phrases)
}

access(all)
fun testSplitEmptySeparator() {
    // Act
    let phrases = StringUtils.split("foo", "")

    // Assert
    let expected = ["f", "o", "o"]
    Test.assertEqual(expected, phrases)
}

access(all)
fun testJoin() {
    // Act
    let str = StringUtils.join(["Hello", "How", "Are", "You", "Today?"], " ")

    // Assert
    Test.assertEqual("Hello How Are You Today?", str)
}

access(all)
fun testJoinEmpty() {
    // Act
    let str = StringUtils.join([], " ")

    // Assert
    Test.assertEqual("", str)
}
