import StringUtils from "../contracts/StringUtils.cdc"

pub fun main(str: String, delimiter: Character): [String] {
    return StringUtils.split(str, delimiter.toString())
}