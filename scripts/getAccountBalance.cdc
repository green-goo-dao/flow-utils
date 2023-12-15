import "AccountUtils"
pub fun main(address:Address) : AnyStruct {

    return AccountUtils.getTotalFlowBalance(address:address)
}
