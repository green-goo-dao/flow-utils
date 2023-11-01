import Test
import "FlowToken"
import "StringUtils"
import "AddressUtils"

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

    err = Test.deployContract(
        name: "AddressUtils",
        path: "../cadence/contracts/AddressUtils.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())
}

access(all)
fun testWithoutPrefix() {
    // Act
    var address = AddressUtils.withoutPrefix("0xf8d6e0586b0a20c7")

    // Assert
    Test.assertEqual("f8d6e0586b0a20c7", address)

    // Act
    // Odd length
    address = AddressUtils.withoutPrefix("8d6e0586b0a20c7")

    // Assert
    Test.assertEqual("08d6e0586b0a20c7", address)
}

access(all)
fun testParseUInt64() {
    // Act
    var address = AddressUtils.parseUInt64("0xf8d6e0586b0a20c7")

    // Assert
    Test.assertEqual(17930765636779778247 as UInt64?, address)

    // Act
    address = AddressUtils.parseUInt64(Address(0xf8d6e0586b0a20c7))

    // Assert
    Test.assertEqual(17930765636779778247 as UInt64?, address)

    // Act
    // In the testing framework, the FlowToken address is:
    // 0x0000000000000003
    address = AddressUtils.parseUInt64(FlowToken.getType())

    // Assert
    Test.assertEqual(3 as UInt64?, address)

    // Act
    address = AddressUtils.parseUInt64(0x01)

    // Assert
    Test.assertEqual(nil, address)

    // Act
    address = AddressUtils.parseUInt64("hello".getType())

    // Assert
    Test.assertEqual(nil, address)
}

access(all)
fun testParseAddress() {
    // Act
    var address = AddressUtils.parseAddress("0xf8d6e0586b0a20c7")

    // Assert
    Test.assertEqual(Address(0xf8d6e0586b0a20c7), address!)

    // Act
    address = AddressUtils.parseAddress(1005)

    // Assert
    Test.assertEqual(nil, address)
}

access(all)
fun testIsValidAddress() {
    // Act
    let mainnet = AddressUtils.isValidAddress("0xa340dc0a4ec828ab", forNetwork: "MAINNET")
    let testnet = AddressUtils.isValidAddress("0x31ad40c07a2a9788", forNetwork: "TESTNET")
    let emulator = AddressUtils.isValidAddress("0xf8d6e0586b0a20c7", forNetwork: "EMULATOR")

    // Assert
    Test.assert(mainnet && testnet && emulator)

    // Act
    var valid = AddressUtils.isValidAddress(1452, forNetwork: "EMULATOR")

    // Assert
    Test.assertEqual(false, valid)

    // Act
    valid = AddressUtils.isValidAddress("0x6834ba37b3980209", forNetwork: "TESTNET")

    // Assert
    Test.assertEqual(false, valid)
}

access(all)
fun testGetNetworkFromAddress() {
    // Act
    var network = AddressUtils.getNetworkFromAddress(1541)

    // Assert
    Test.assertEqual(nil, network)

    // Act
    network = AddressUtils.getNetworkFromAddress("0xf8d6e0586b0a20c7")

    // Assert
    Test.assertEqual("EMULATOR" as String?, network)

    // Act
    network = AddressUtils.getNetworkFromAddress("0x31ad40c07a2a9788")

    // Assert
    Test.assertEqual("TESTNET" as String?, network)

    // Act
    network = AddressUtils.getNetworkFromAddress("0xa340dc0a4ec828ab")

    // Assert
    Test.assertEqual("MAINNET" as String?, network)
}

access(all)
fun testGetCurrentNetwork() {
    Test.expectFailure(fun(): Void {
        AddressUtils.currentNetwork()
    }, errorMessageSubstring: "unknown network!")
}
