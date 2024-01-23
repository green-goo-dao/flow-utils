import "BurnableTest"
import "Burner"

transaction(allowDestroy: Bool, dictType: Type) {
    prepare(acct: AuthAccount) {
        let r <- BurnableTest.createSafe(allowDestroy: allowDestroy)
        if dictType.isSubtype(of: Type<Number>()) {
            let d: @{Number: AnyResource} <- {1: <-r}
            Burner.burn(<-d)
        } else if dictType.isSubtype(of: Type<String>()) {
            let d: @{String: AnyResource} <- {"a": <-r}
            Burner.burn(<-d)
        } else if dictType.isSubtype(of: Type<Path>()) {
            let d: @{Path: AnyResource} <- {/public/foo: <-r}
            Burner.burn(<-d)
        } else if dictType.isSubtype(of: Type<Address>()) {
            let d: @{Address: AnyResource} <- {Address(0x1): <-r}
            Burner.burn(<-d)
        } else if dictType.isSubtype(of: Type<Character>()) {
            let d: @{Character: AnyResource} <- {"c": <-r}
            Burner.burn(<-d)
        } else if dictType.isSubtype(of: Type<Type>()) {
            let d: @{Type: AnyResource} <- {Type<Burner>(): <-r}
            Burner.burn(<-d)
        } else {
            panic("unsupported dict type")
        }
    }
}
