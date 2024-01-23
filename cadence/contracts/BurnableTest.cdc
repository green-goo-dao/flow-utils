import "Burner"

pub contract BurnableTest {
    pub var totalBurned: UInt64

    pub resource Safe: Burner.Burnable {
        pub let allowDestroy: Bool

        pub fun burnCallback() {
            assert(self.allowDestroy, message: "allowDestroy must be set to true")
            BurnableTest.totalBurned = BurnableTest.totalBurned + 1
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

    init() {
        self.totalBurned = 0
    }
}