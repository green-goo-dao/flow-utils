import Test
import ArrayUtils from "../cadence/contracts/ArrayUtils.cdc"

pub struct Token {
    pub let id: Int
    pub(set) var balance: Int

    init(id: Int, balance: Int) {
        self.id = id
        self.balance = balance
    }
}

pub(set) var arrayUtils = ArrayUtils()

pub fun testRange() {
    // Act
    var range = arrayUtils.range(0, 10)

    // Assert
    var expected: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    var i: Int = 0
    while i < expected.length {
        Test.assert(expected[i] == range[i])
        i = i + 1
    }
}

pub fun testReverseRange() {
    // Act
    var range = arrayUtils.reverse(arrayUtils.range(0, 10))

    // Assert
    var expected: [Int] = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
    var i: Int = 0
    while i < expected.length {
        Test.assert(expected[i] == range[i])
        i = i + 1
    }
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
        token.balance = token.balance * 2
        return token
    })

    // Assert
    Test.assert(tokens[0].balance == 20)
    Test.assert(tokens[1].balance == 10)
    Test.assert(tokens[2].balance == 30)
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
    arrayUtils.iterate(tokens as [AnyStruct], fun (t: AnyStruct): Bool {
        var token = t as! Token
        return token.id <= 2
    })
}

pub fun testMap() {
    // Arrange
    let tokens = [
        Token(id: 0, balance: 10),
        Token(id: 1, balance: 5),
        Token(id: 2, balance: 15)
    ]

    // Act
    let mapped = arrayUtils.map(tokens as [AnyStruct], fun (t: AnyStruct): AnyStruct {
        var token = t as! Token
        token.balance = token.balance - 2
        return token
    })

    // Assert
    Test.assert((mapped[0] as! Token).balance == 8)
    Test.assert((mapped[1] as! Token).balance == 3)
    Test.assert((mapped[2] as! Token).balance == 13)
}

pub fun testMapStrings() {
    // Arrange
    let strings = ["Peter", "John", "Mark"]

    // Act
    let mapped = arrayUtils.mapStrings(strings, fun (s: String): String {
        return "Hello, ".concat(s).concat("!")
    })

    // Assert
    Test.assert(mapped[0] == "Hello, Peter!")
    Test.assert(mapped[1] == "Hello, John!")
    Test.assert(mapped[2] == "Hello, Mark!")
}

pub fun testReduce() {
    // Arrange
    let tokens = [
        Token(id: 0, balance: 10),
        Token(id: 1, balance: 5),
        Token(id: 2, balance: 15)
    ]
    let initial = Token(id: 5, balance: 0) as AnyStruct

    // Act
    let token = arrayUtils.reduce(tokens as [AnyStruct], initial, fun (acc: AnyStruct, t: AnyStruct): AnyStruct {
        var token = t as! Token
        var accToken = acc as! Token
        accToken.balance = accToken.balance + token.balance
        return accToken
    })

    // Assert
    Test.assert((token as! Token).balance == 30)
}
