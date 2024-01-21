import Test
import "ArrayUtils"

access(all) struct Token {
    access(all) let id: Int
    access(all) var balance: Int

    init(id: Int, balance: Int) {
        self.id = id
        self.balance = balance
    }

    access(all)
    fun setBalance(_ balance: Int) {
        self.balance = balance
    }
}

access(all)
fun setup() {
    let err = Test.deployContract(
        name: "ArrayUtils",
        path: "../contracts/ArrayUtils.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())
}

access(all)
fun testRange() {
    // Act
    let range = ArrayUtils.range(0, 10)

    // Assert
    let expected: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    Test.assertEqual(expected, range)
}

access(all)
fun testReverseRange() {
    // Act
    let range = ArrayUtils.reverse(ArrayUtils.range(0, 10))

    // Assert
    let expected: [Int] = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
    Test.assertEqual(expected, range)
}

access(all)
fun testTransform() {
    // Arrange
    let tokens: [Token] = [
        Token(id: 0, balance: 10),
        Token(id: 1, balance: 5),
        Token(id: 2, balance: 15)
    ]

    // Act
    ArrayUtils.transform(&tokens, fun (t: &AnyStruct, arr: auth(Mutate) &[AnyStruct], index: Int) {
        let token = t as! &Token
        token.setBalance(token.balance * 2)
    })

    // Assert
    let expected = [
        Token(id: 0, balance: 20),
        Token(id: 1, balance: 10),
        Token(id: 2, balance: 30)
    ]
    Test.assertEqual(expected, tokens)
}

access(all)
fun testIterate() {
    // Arrange
    let tokens = [
        Token(id: 0, balance: 10),
        Token(id: 1, balance: 5),
        Token(id: 2, balance: 15),
        Token(id: 3, balance: 22),
        Token(id: 4, balance: 31)
    ]

    // Act
    var totalBalance = 0
    ArrayUtils.iterate(tokens, fun (t: AnyStruct): Bool {
        var token = t as! Token
        if token.id <= 2 {
            totalBalance = totalBalance + token.balance
            return true
        }
        return false
    })

    Test.assertEqual(30, totalBalance)
}

access(all)
fun testMap() {
    // Arrange
    let tokens = [
        Token(id: 0, balance: 10),
        Token(id: 1, balance: 5),
        Token(id: 2, balance: 15)
    ]

    // Act
    let mapped = ArrayUtils.map(tokens, fun (t: AnyStruct): AnyStruct {
        var token = t as! Token
        token.setBalance(token.balance - 2)
        return token
    })

    // Assert
    let expected: [AnyStruct] = [
        Token(id: 0, balance: 8),
        Token(id: 1, balance: 3),
        Token(id: 2, balance: 13)
    ]
    Test.assertEqual(expected, mapped)
}

access(all)
fun testMapStrings() {
    // Arrange
    let strings = ["Peter", "John", "Mark"]

    // Act
    let mapped = ArrayUtils.mapStrings(strings, fun (s: String): String {
        return "Hello, ".concat(s).concat("!")
    })

    // Assert
    let expected = [
        "Hello, Peter!",
        "Hello, John!",
        "Hello, Mark!"
    ]
    Test.assertEqual(expected, mapped)
}

access(all)
fun testReduce() {
    // Arrange
    let tokens = [
        Token(id: 0, balance: 10),
        Token(id: 1, balance: 5),
        Token(id: 2, balance: 15)
    ]
    let initial = Token(id: 5, balance: 0)

    // Act
    let token = ArrayUtils.reduce(tokens, initial, fun (acc: AnyStruct, t: AnyStruct): AnyStruct {
        var token = t as! Token
        var accToken = acc as! Token
        accToken.setBalance(accToken.balance + token.balance)
        return accToken
    })

    // Assert
    Test.assertEqual(30, (token as! Token).balance)
}
