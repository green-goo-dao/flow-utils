import "SafeDestroyTest"
import "Burner"

transaction(allowDestroy: Bool) {
    prepare(acct: AuthAccount) {
        let r <- SafeDestroyTest.createSafe(allowDestroy: allowDestroy)
        Burner.safeDestroy(<- r)
    }
}
