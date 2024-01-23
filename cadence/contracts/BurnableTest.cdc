import "Burner"

pub contract BurnableTest {
    pub resource Safe: Burner.Burnable {
        pub let allowDestroy: Bool

        pub fun burnCallback() {
            assert(self.allowDestroy, message: "allowDestroy must be set to true")
        }

        init(_ allowDestroy: Bool) {
            self.allowDestroy = allowDestroy
        }
    }

    pub resource Unsafe {}

    pub fun createSafe(allowDestroy: Bool): @Safe {
        return <- create Safe(allowDestroy)
    }

    pub fun createUnsafe(): @Unsafe {
        return <- create Unsafe()
    }
}