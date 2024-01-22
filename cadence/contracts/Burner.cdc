// Burner is a contract that can facilitate the destruction of any resource on flow.
pub contract Burner {

    // When Crescendo (Cadence 1.0) is released, custom destructors will be removed from the language.
    // SafeDestroy is an interface meant to replace custom destructors, allowing anyone to add a callback
    // method to ensure they do not destroy something which is not meant to be.
    //
    // NOTE: The only way to see benefit from this interface is to call the safeDestroyCallback method yourself,
    // or to always use the safeDestroy method in this contract. Anyone who owns a resource can always elect **not**
    // to destroy a resource this way
    pub resource interface SafeDestroy {
        pub fun safeDestroyCallback()
    }

    // safeDestroy is a global burn method which will destroy any resource it is given.
    // If the provided resource implements the SafeDestroy interface, it will call the safeDestroyCallback
    // method and then destroy afterwards.
    pub fun safeDestroy(_ r: @AnyResource) {
        if r.isInstance(Type<@{SafeDestroy}>()) {
            let s <- (r as! @{SafeDestroy})
            s.safeDestroyCallback()
            destroy s
            return 
        }

        destroy r
    }
}