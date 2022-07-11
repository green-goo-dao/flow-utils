import {
    executeScript
} from "flow-js-testing";
import {
    after,
    before,
} from "./common";

// Increase timeout if your tests failing due to timeout
jest.setTimeout(10000);


describe("StringUtils tests", () => {
    beforeEach(async () => {
        await before()
    });

    // Stop emulator, so it could be restarted
    afterEach(async () => {
        await after()
    });

    const cadenceSplitEqualsJSSplit = async (str, delimiter) => {
        const [res, err] = await executeScript("split-string", [str, delimiter])
        expect(err).toBe(null)
        const expected = str.split(delimiter)
        expect(res.length).toBe(expected.length)

        for(let i = 0; i < res.length; i++) {
            expect(res[i]).toBe(expected[i])
        }
    }

    test("Split string", async () => {
        await cadenceSplitEqualsJSSplit("this is a string", " ")
        await cadenceSplitEqualsJSSplit("this.is.a string.", ".")
        await cadenceSplitEqualsJSSplit("", ".")
        await cadenceSplitEqualsJSSplit(".........", ".")
        await cadenceSplitEqualsJSSplit("there is no delimiter in this one", ".")
        await cadenceSplitEqualsJSSplit("❓❓❓❓❓❓❓", " ")
        await cadenceSplitEqualsJSSplit("❓❓❓❓❓❓❓", "❓")
        await cadenceSplitEqualsJSSplit("some random stuff ❓ here ❓ ❓ ❓", "❓")
    })
})
