import "StringUtils"

access(all) fun main(str: String, delimiter: Character): [String] {
    return StringUtils.split(str, delimiter.toString())
}