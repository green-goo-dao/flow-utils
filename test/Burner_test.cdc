import Test
import BlockchainHelpers

pub let BurnerAccount = Test.getAccount(0x0000000000000007)

pub fun setup() {
    Test.deployContract(name: "Burner", path: "../cadence/contracts/Burner.cdc", arguments: [])
    Test.deployContract(name: "BurnableTest", path: "../cadence/contracts/BurnableTest.cdc", arguments: [])
}

pub fun testSafeDestory_Allowed() {
    let acct = Test.createAccount()
     txExecutor(
        "burner/create_and_destroy_safe.cdc",
        [acct],
        [true]
    )
}

pub fun testSafeDestroy_NotAllowed() {
    let acct = Test.createAccount()

    Test.expectFailure(fun() {
        txExecutor(
            "burner/create_and_destroy_safe.cdc",
            [acct],
            [false]
        )
    }, errorMessageSubstring: "allowDestroy must be set to true")
}

pub fun testUnsafeDestroy_Allowed() {
    let acct = Test.createAccount()
    txExecutor(
        "burner/create_and_destroy_unsafe.cdc",
        [acct],
        []
    )
}

pub fun testDestroy_Dict() {
    let acct = Test.createAccount()

    let types = [Type<Address>(), Type<String>(), Type<CapabilityPath>(), Type<Number>(), Type<Type>(), Type<Character>()]
    for type in types {
        txExecutor(
            "burner/create_and_destroy_dict.cdc",
            [acct],
            [true, type]
        ) 
    }
}

pub fun testDestroy_Array() {
    let acct = Test.createAccount()
    txExecutor(
        "burner/create_and_destroy_array.cdc",
        [acct],
        [true]
    )
}

pub fun loadCode(_ fileName: String, _ baseDirectory: String): String {
    return Test.readFile("../cadence/".concat(baseDirectory).concat("/").concat(fileName))
}

pub fun txExecutor(_ txName: String, _ signers: [Test.Account], _ arguments: [AnyStruct]): Test.TransactionResult {
    let txCode = loadCode(txName, "transactions")

    let authorizers: [Address] = []
    for signer in signers {
        authorizers.append(signer.address)
    }
    let tx = Test.Transaction(
        code: txCode,
        authorizers: authorizers,
        signers: signers,
        arguments: arguments,
    )
    let txResult = Test.executeTransaction(tx)
    if let err = txResult.error {
        panic(err.message)
    }
    return txResult
}