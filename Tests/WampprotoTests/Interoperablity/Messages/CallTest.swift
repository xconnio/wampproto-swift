@testable import Wampproto
import XCTest

func isEqual(msg1: Call, msg2: Call) -> Bool {
    msg1.requestID == msg2.requestID &&
        msg1.uri == msg2.uri &&
        (msg1.args as NSArray?) == (msg2.args as NSArray?) &&
        (msg1.kwargs as NSDictionary?) == (msg2.kwargs as NSDictionary?) &&
        (msg1.options as NSDictionary) == (msg2.options as NSDictionary)
}

func testCallMessage(serializerStr: String, serializer: Serializer) throws {
    let requestID: UInt64 = 12345
    let uri = "com.example.method"
    let args: [Any] = [42, "hello"]
    let kwargs: [String: Any] = ["key": "value"]
    let options: [String: Any] = ["option1": true]

    let message = Call(requestID: requestID, uri: uri, args: args, kwargs: kwargs, options: options)

    let command = "message call \(requestID) \(uri) 42 hello -k key=value -o option1=true " +
        "--serializer \(serializerStr) --output hex"

    guard let msg = runCommandAndDeserialize(serializer: serializer, command: command) as? Call else {
        XCTFail("Failed to deserialize the Call message")
        return
    }

    XCTAssertTrue(isEqual(msg1: message, msg2: msg), "Call message deserialization failed")
}

class CallMessageTest: XCTestCase {
    func testJSONSerializer() {
        let serializer = JSONSerializer()
        do {
            try testCallMessage(serializerStr: "json", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testMsgPackSerializer() {
        let serializer = MsgPackSerializer()
        do {
            try testCallMessage(serializerStr: "msgpack", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testCBORSerializer() {
        let serializer = CBORSerializer()
        do {
            try testCallMessage(serializerStr: "cbor", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }
}
