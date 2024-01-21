pub contract Burner {
    pub resource interface SafeDestroy {
        pub fun callback()
    }

    pub fun safeDestroy(_ r: @AnyResource) {
        if r.isInstance(Type<@{SafeDestroy}>()) {
            let s <- (r as! @{SafeDestroy})
            s.callback()
            destroy s
            return 
        }

        destroy r
    }
}