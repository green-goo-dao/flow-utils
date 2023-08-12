import AddressUtils from "../contracts/AddressUtils.cdc"

pub fun main(): Bool {
    // Act
    let mainnet = AddressUtils.isValidAddress("0xa340dc0a4ec828ab", forNetwork: "MAINNET")
    let testnet = AddressUtils.isValidAddress("0x31ad40c07a2a9788", forNetwork: "TESTNET")
    let emulator = AddressUtils.isValidAddress("0xf8d6e0586b0a20c7", forNetwork: "EMULATOR")

    // Assert
    assert(mainnet && testnet && emulator)

    // Act
    var valid = AddressUtils.isValidAddress(1452, forNetwork: "EMULATOR")

    // Assert
    assert(valid == false)

    // Act
    valid = AddressUtils.isValidAddress("0x6834ba37b3980209", forNetwork: "TESTNET")

    // Assert
    assert(valid == false)


    return true
}
