@testable import Wampproto
import XCTest

func isEqual(msg1: Result, msg2: Result) -> Bool {
    msg1.requestID == msg2.requestID &&
        (msg1.args as NSArray?) == (msg2.args as NSArray?) &&
        (msg1.kwargs as NSDictionary?) == (msg2.kwargs as NSDictionary?) &&
        (msg1.details as NSDictionary) == (msg2.details as NSDictionary)
}

func testResultMessage(serializerStr: String, serializer: Serializer) throws {
    let requestID: Int64 = 12345
    let args: [Any] = [100, "data"]
    let kwargs: [String: Any] = ["status": "ok"]
    let details: [String: Any] = ["cache": true]

    let message = Result(requestID: requestID, args: args, kwargs: kwargs, details: details)

    let command = "message result \(requestID) 100 data -k status=ok -d cache=true " +
        "--serializer \(serializerStr) --output hex"

    guard let msg = runCommandAndDeserialize(serializer: serializer, command: command) as? Result else {
        XCTFail("Failed to deserialize the Result message")
        return
    }

    XCTAssertTrue(isEqual(msg1: message, msg2: msg), "Result message deserialization failed")
}

class ResultMessageTest: XCTestCase {
    func testJSONSerializer() {
        let serializer = JSONSerializer()
        do {
            try testResultMessage(serializerStr: "json", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testMsgPackSerializer() {
        let serializer = MsgPackSerializer()
        do {
            try testResultMessage(serializerStr: "msgpack", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testCBORSerializer() {
        let serializer = CBORSerializer()
        do {
            try testResultMessage(serializerStr: "cbor", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }
}
