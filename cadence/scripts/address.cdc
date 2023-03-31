import AddressUtils from "../contracts/AddressUtils.cdc"
pub fun main(){

    log(AddressUtils.currentNetwork())
    log(AddressUtils.parseAddress("0x1"))
    log(AddressUtils.parseAddress(1))
    log(AddressUtils.parseAddress(0x1))
    log(AddressUtils.parseAddress("0xf8d6e0586b0a20c7"))
    log(AddressUtils.parseAddress(AddressUtils.getType()))
    

}