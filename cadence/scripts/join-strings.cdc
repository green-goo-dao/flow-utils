import StringUtils from "../contracts/StringUtils.cdc"

pub fun main(strs: [String], separator: String): String {
    return StringUtils.join(strs, separator)
}