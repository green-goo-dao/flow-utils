import Test
import ArrayUtils from "ArrayUtils"

pub struct Token {
    pub let id: Int
    pub var balance: Int

    init(id: Int, balance: Int) {
        self.id = id
        self.balance = balance
    }

    pub fun setBalance(_ balance: Int) {
        self.balance = balance
    }
}

pub let arrayUtils = ArrayUtils()

pub fun testRange() {
    // Act
    let range = arrayUtils.range(0, 10)

    // Assert
    let expected: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    Test.assertEqual(expected, range)
}

pub fun testReverseRange() {
    // Act
    let range = arrayUtils.reverse(arrayUtils.range(0, 10))

    // Assert
    let expected: [Int] = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
    Test.assertEqual(expected, range)
}

pub fun testTransform() {
    // Arrange
    let tokens = [
        Token(id: 0, balance: 10),
        Token(id: 1, balance: 5),
        Token(id: 2, balance: 15)
    ]

    // Act
    arrayUtils.transform(&tokens as &[AnyStruct], fun (t: AnyStruct): AnyStruct {
        var token = t as! Token
        token.setBalance(token.balance * 2)
        return token
    })

    // Assert
    let expected = [
        Token(id: 0, balance: 20),
        Token(id: 1, balance: 10),
        Token(id: 2, balance: 30)
    ]
    Test.assertEqual(expected, tokens)
}

pub fun testIterate() {
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
    arrayUtils.iterate(tokens, fun (t: AnyStruct): Bool {
        var token = t as! Token
        if token.id <= 2 {
            totalBalance = totalBalance + token.balance
            return true
        }
        return false
    })

    Test.assertEqual(30, totalBalance)
}

pub fun testMap() {
    // Arrange
    let tokens = [
        Token(id: 0, balance: 10),
        Token(id: 1, balance: 5),
        Token(id: 2, balance: 15)
    ]

    // Act
    let mapped = arrayUtils.map(tokens, fun (t: AnyStruct): AnyStruct {
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

pub fun testMapStrings() {
    // Arrange
    let strings = ["Peter", "John", "Mark"]

    // Act
    let mapped = arrayUtils.mapStrings(strings, fun (s: String): String {
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

pub fun testReduce() {
    // Arrange
    let tokens = [
        Token(id: 0, balance: 10),
        Token(id: 1, balance: 5),
        Token(id: 2, balance: 15)
    ]
    let initial = Token(id: 5, balance: 0)

    // Act
    let token = arrayUtils.reduce(tokens, initial, fun (acc: AnyStruct, t: AnyStruct): AnyStruct {
        var token = t as! Token
        var accToken = acc as! Token
        accToken.setBalance(accToken.balance + token.balance)
        return accToken
    })

    // Assert
    Test.assertEqual(30, (token as! Token).balance)
}
