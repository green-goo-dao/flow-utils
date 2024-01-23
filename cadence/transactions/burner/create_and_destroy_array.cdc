import "BurnableTest"
import "Burner"

transaction(allowDestroy: Bool) {
    prepare(acct: AuthAccount) {
        let r <- BurnableTest.createSafe(allowDestroy: allowDestroy)
        Burner.burn(<- [<- r])
    }
}
