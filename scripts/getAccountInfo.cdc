import "AccountUtils"
pub fun main(address:Address) : AnyStruct {

    return AccountUtils.getAccountInfo(address:address)
}
