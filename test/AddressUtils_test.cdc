import Test
import "FlowToken"
import "StringUtils"
import "AddressUtils"

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

    err = Test.deployContract(
        name: "AddressUtils",
        path: "../contracts/AddressUtils.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())
}

access(all)
fun testWithoutPrefixEvenLength() {
    // Act
    let address = AddressUtils.withoutPrefix("0xf8d6e0586b0a20c7")

    // Assert
    Test.assertEqual("f8d6e0586b0a20c7", address)
}


access(all)
fun testWithoutPrefixOddLength() {
    // Act
    let address = AddressUtils.withoutPrefix("8d6e0586b0a20c7")

    // Assert
    Test.assertEqual("08d6e0586b0a20c7", address)
}

access(all)
fun testParseUInt64HexString() {
    // Act
    var address = AddressUtils.parseUInt64("0xf8d6e0586b0a20c7")

    // Assert
    Test.assertEqual(17930765636779778247 as UInt64?, address)
}

access(all)
fun testParseUInt64Address() {
    // Act
    let address = AddressUtils.parseUInt64(Address(0xf8d6e0586b0a20c7))

    // Assert
    Test.assertEqual(17930765636779778247 as UInt64?, address)
}

access(all)
fun testParseUInt64Type() {

    // Act
    // In the testing framework, the FlowToken address is:
    // 0x0000000000000003
    let address = AddressUtils.parseUInt64(FlowToken.getType())

    // Assert
    Test.assertEqual(3 as UInt64?, address)
}

access(all)
fun testParseUInt64HexInteger() {
    // Act
    let address = AddressUtils.parseUInt64(0x01)

    // Assert
    Test.assertEqual(nil, address)
}

access(all)
fun testParseUInt64String() {

    // Act
    let address = AddressUtils.parseUInt64("hello".getType())

    // Assert
    Test.assertEqual(nil, address)
}

access(all)
fun testParseAddressValid() {
    // Act
    let address = AddressUtils.parseAddress("0xf8d6e0586b0a20c7")

    // Assert
    Test.assertEqual(0xf8d6e0586b0a20c7 as Address?, address)
}

access(all)
fun testParseAddressInvalid() {
    // Act
    let address = AddressUtils.parseAddress(1005)

    // Assert
    Test.assertEqual(nil, address)
}

access(all)
fun testIsValidAddressValid() {
    Test.assert(AddressUtils.isValidAddress("0xa340dc0a4ec828ab", forNetwork: "MAINNET"))
    Test.assert(AddressUtils.isValidAddress("0x31ad40c07a2a9788", forNetwork: "TESTNET"))
    Test.assert(AddressUtils.isValidAddress("0xf8d6e0586b0a20c7", forNetwork: "EMULATOR"))
}

access(all)
fun testIsValidAddressInvalidEmulator() {
    Test.assert(!AddressUtils.isValidAddress(1452, forNetwork: "EMULATOR"))
}

access(all)
fun testIsValidAddressInvalidTestnet() {
    Test.assert(!AddressUtils.isValidAddress("0x6834ba37b3980209", forNetwork: "TESTNET"))
}

access(all)
fun testGetNetworkFromAddressInvalid() {
    // Act
    var network = AddressUtils.getNetworkFromAddress(1541)

    // Assert
    Test.assertEqual(nil, network)
}

access(all)
fun testGetNetworkFromAddressEmulator() {
    // Act
    let network = AddressUtils.getNetworkFromAddress("0xf8d6e0586b0a20c7")

    // Assert
    Test.assertEqual("EMULATOR" as String?, network)
}

access(all)
fun testGetNetworkFromAddressTestnet() {
    // Act
    let network = AddressUtils.getNetworkFromAddress("0x31ad40c07a2a9788")

    // Assert
    Test.assertEqual("TESTNET" as String?, network)
}

access(all)
fun testGetNetworkFromAddressMainnet() {
    // Act
    let network = AddressUtils.getNetworkFromAddress("0xa340dc0a4ec828ab")

    // Assert
    Test.assertEqual("MAINNET" as String?, network)
}

access(all)
fun testGetCurrentNetwork() {
    Test.expectFailure(
        fun() {
            let network = AddressUtils.currentNetwork()
        },
        errorMessageSubstring: "unknown network!"
    )
}
