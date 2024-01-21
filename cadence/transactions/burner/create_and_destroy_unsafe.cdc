import "SafeDestroyTest"
import "Burner"

transaction {
    prepare(acct: AuthAccount) {
        let r <- SafeDestroyTest.createUnsafe()
        Burner.safeDestroy(<- r)
    }
}