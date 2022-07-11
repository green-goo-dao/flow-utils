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
}