// Copied from https://github.com/bluesign/flow-utils/blob/dnz/cadence/contracts/ArrayUtils.cdc with minor adjustments

access(all) contract ArrayUtils {

    access(all) fun rangeFunc(_ start: Int, _ end: Int, _ f: fun (Int): Void) {
        var current = start
        while current < end {
            f(current)
            current = current + 1
        }
    }

    access(all) fun range(_ start: Int, _ end: Int): [Int] {
        var res: [Int] = []
        self.rangeFunc(start, end, fun (i: Int) {
            res.append(i)
        })
        return res
    }

    access(all) fun reverse(_ array: [Int]): [Int] {
        return array.reverse()
    }

    access(all) fun transform(
        _ array: auth(Mutate) &[AnyStruct],
        _ f : fun (&AnyStruct, auth(Mutate) &[AnyStruct], Int)
    ) {
        let length = array.length
        if length > 0 {
            for i in InclusiveRange(0, length - 1) {
                f(array[i], array, i)
            }
        }
    }

    access(all) fun iterate(_ array: [AnyStruct], _ f: fun (AnyStruct): Bool) {
        for item in array {
            if !f(item) {
                break
            }
        }
    }

    access(all) fun map(_ array: [AnyStruct], _ f: fun (AnyStruct): AnyStruct): [AnyStruct] {
        return array.map(f)
    }

    access(all) fun mapStrings(_ array: [String], _ f: fun (String): String): [String] {
        return array.map(f)
    }

    access(all) fun reduce(_
        array: [AnyStruct],
        _ initial: AnyStruct,
        _ f: fun (AnyStruct, AnyStruct): AnyStruct
    ): AnyStruct {
        var res = initial
        let length = array.length
        if length > 0 {
            for i in InclusiveRange(0, length - 1) {
                res = f(res, array[i])
            }
        }
        return res
    }
}