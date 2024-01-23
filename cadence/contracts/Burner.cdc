// Burner is a contract that can facilitate the destruction of any resource on flow.
pub contract Burner {

    // When Crescendo (Cadence 1.0) is released, custom destructors will be removed from cadece.
    // Burnable is an interface meant to replace this lost feature, allowing anyone to add a callback
    // method to ensure they do not destroy something which is not meant to be, or to add logic based on destruction
    // such as tracking the supply of an NFT Collection
    //
    // NOTE: The only way to see benefit from this interface is to call the burnCallback method yourself,
    // or to always use the burn method in this contract. Anyone who owns a resource can always elect **not**
    // to destroy a resource this way
    pub resource interface Burnable {
        pub fun burnCallback()
    }

    // burn is a global method which will destroy any resource it is given.
    // If the provided resource implements the Burnable interface, it will call the burnCallback
    // method and then destroy afterwards.
    pub fun burn(_ r: @AnyResource) {
        if r.isInstance(Type<@{Burnable}>()) {
            let s <- (r as! @{Burnable})
            s.burnCallback()
            destroy s
        } else if r.isInstance(Type<@[AnyResource]>()) {
            let arr <- (r as! @[AnyResource])
            while arr.length > 0 {
                let item <- arr.removeFirst()
                self.burn(<-item)
            }
            destroy arr
        } else if r.isInstance(Type<@{String: AnyResource}>()) {
            let d <- (r as! @{String: AnyResource})
            let keys = d.keys
            while keys.length > 0 {
                let item <- d.remove(key: keys.removeFirst())
                self.burn(<-item)
            }
            destroy d
        } else if r.isInstance(Type<@{Number: AnyResource}>()) {
            let d <- (r as! @{Number: AnyResource})
            let keys = d.keys
            while keys.length > 0 {
                let item <- d.remove(key: keys.removeFirst())
                self.burn(<-item)
            }
            destroy d
        } else if r.isInstance(Type<@{Type: AnyResource}>()) {
            let d <- (r as! @{Type: AnyResource})
            let keys = d.keys
            while keys.length > 0 {
                let item <- d.remove(key: keys.removeFirst())
                self.burn(<-item)
            }
            destroy d
        }  else if r.isInstance(Type<@{Address: AnyResource}>()) {
            let d <- (r as! @{Address: AnyResource})
            let keys = d.keys
            while keys.length > 0 {
                let item <- d.remove(key: keys.removeFirst())
                self.burn(<-item)
            }
            destroy d
        }  else if r.isInstance(Type<@{Path: AnyResource}>()) {
            let d <- (r as! @{Path: AnyResource})
            let keys = d.keys
            while keys.length > 0 {
                let item <- d.remove(key: keys.removeFirst())
                self.burn(<-item)
            }
            destroy d
        }  else if r.isInstance(Type<@{Character: AnyResource}>()) {
            let d <- (r as! @{Character: AnyResource})
            let keys = d.keys
            while keys.length > 0 {
                let item <- d.remove(key: keys.removeFirst())
                self.burn(<-item)
            }
            destroy d
        } else {
            destroy r
        }
    }
}