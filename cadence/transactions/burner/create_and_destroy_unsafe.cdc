import "BurnableTest"
import "Burner"

transaction {
    prepare(acct: AuthAccount) {
        let r <- BurnableTest.createUnsafe()
        Burner.burn(<- r)
    }
}