import "StringUtils"

access(all) fun main(strs: [String], separator: String): String {
    return StringUtils.join(strs, separator)
}