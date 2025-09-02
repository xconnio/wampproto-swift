@testable import Wampproto
import XCTest

func isEqual(msg1: Yield, msg2: Yield) -> Bool {
    msg1.requestID == msg2.requestID &&
        (msg1.args as NSArray?) == (msg2.args as NSArray?) &&
        (msg1.kwargs as NSDictionary?) == (msg2.kwargs as NSDictionary?) &&
        (msg1.options as NSDictionary) == (msg2.options as NSDictionary)
}

func testYieldMessage(serializerStr: String, serializer: Serializer) throws {
    let requestID: UInt64 = 12345
    let args: [Any] = [200, "response"]
    let kwargs: [String: Any] = ["status": "success"]
    let options: [String: Any] = ["cache": false]

    let message = Yield(requestID: requestID, args: args, kwargs: kwargs, options: options)

    let command = "message yield \(requestID) 200 response -k status=success -o cache=false" +
        " --serializer \(serializerStr) --output hex"

    guard let msg = runCommandAndDeserialize(serializer: serializer, command: command) as? Yield else {
        XCTFail("Failed to deserialize the Yield message")
        return
    }

    XCTAssertTrue(isEqual(msg1: message, msg2: msg), "Yield message deserialization failed")
}

class YieldMessageTest: XCTestCase {
    func testJSONSerializer() {
        let serializer = JSONSerializer()
        do {
            try testYieldMessage(serializerStr: "json", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testMsgPackSerializer() {
        let serializer = MsgPackSerializer()
        do {
            try testYieldMessage(serializerStr: "msgpack", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testCBORSerializer() {
        let serializer = CBORSerializer()
        do {
            try testYieldMessage(serializerStr: "cbor", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }
}
