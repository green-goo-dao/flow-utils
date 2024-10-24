import "ArrayUtils"

access(all) contract StringUtils {

    access(all) fun format(_ s: String, _ args: {String: String}): String {
        var formatted = s
        for key in args.keys {
            formatted = StringUtils.replaceAll(formatted, "{".concat(key).concat("}"), args[key]!)
        }
        return formatted
    }

    access(all) fun explode(_ s: String): [String] {
        return s.split(separator: "")
    }

    access(all) fun trimLeft(_ s: String): String {
        let length = s.length
        if length > 0 {
            for i in InclusiveRange(0, length - 1) {
                if s[i] != " " {
                    return s.slice(from: i, upTo: s.length)
                }
            }
        }
        return ""
    }

    access(all) fun trim(_ s: String): String {
        return self.trimLeft(s)
    }

    access(all) fun replaceAll(_ s: String, _ search: String, _ replace: String): String {
        return s.replaceAll(of: search, with: replace)
    }

    access(all) fun hasPrefix(_ s: String, _ prefix: String): Bool {
        return s.length >= prefix.length
            && s.slice(from:0, upTo: prefix.length) == prefix
    }

    access(all) fun hasSuffix(_ s: String, _ suffix: String): Bool {
        return s.length >= suffix.length
            && s.slice(from: s.length - suffix.length, upTo: s.length) == suffix
    }

    access(all) fun index(_ s: String, _ substr: String, _ startIndex: Int): Int? {
        var s = s
        if startIndex > 0 {
            s = s.slice(from: startIndex, upTo: s.length)
        }
        let index = s.index(of: substr)
        if index < 0 {
            return nil
        }
        return index + startIndex
    }

    access(all) fun count(_ s: String, _ substr: String): Int {
        return s.count(substr)
    }

    access(all) fun contains(_ s: String, _ substr: String): Bool {
        return s.contains(substr)
    }

    access(all) fun substringUntil(_ s: String, _ until: String, _ startIndex: Int): String {
        if let index = self.index(s, until, startIndex) {
            return s.slice(from: startIndex, upTo: index)
        }
        return s.slice(from: startIndex, upTo: s.length)
    }

    access(all) fun split(_ s: String, _ delimiter: String): [String] {
        return s.split(separator: delimiter)
    }

    access(all) fun join(_ strs: [String], _ separator: String): String {
        return String.join(strs, separator: separator)
    }
}
