pub contract StringUtils {
    pub fun split(str: String, delimiter: Character): [String] {
        let segments = [] as [String]

        var currentSegment = ""
        var index = 0
        while index < str.length {
            let c = str[index]
            if c == delimiter {
                segments.append(currentSegment)
                currentSegment = ""
            } else {
                currentSegment = currentSegment.concat(c.toString())
            }

            index = index + 1
        }
        segments.append(currentSegment)

        return segments
    }

    pub fun join(strs: [String], separator: String): String {
        var joinedStr = ""
        for str in strs {
            joinedStr = joinedStr.concat(str).concat(separator)
        }
        return joinedStr.slice(from: 0, upTo: joinedStr.length - separator.length)
    }
}
    pub fun explode(_ s: String): [String]{
        var chars : [String] =  []
        for i in range(0, s.length){
            chars.append(s[i].toString())
        }  
        return chars
    }

    pub fun trimLeft(_ s: String): String{
        for i in range(0, s.length){
            if s[i] != " "{
                return s.slice(from: i, upTo: s.length)
            }
        }
        return ""
    }

    pub fun trimRight(_ s:  String): String{
        for i in rrange(s.length-1, -1){
            if s[i] != " "{
                return s.slice(from: 0, upTo: i+1)
            }
        }
        return ""
    }

    pub fun trim(_ s: String): String{
        return trimRight(trimLeft(s))
    }

