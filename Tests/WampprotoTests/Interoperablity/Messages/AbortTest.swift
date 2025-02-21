import XCTest
@testable import Wampproto

func isEqual(msg1: Abort, msg2: Abort) -> Bool {
    return (msg1.details as NSDictionary).isEqual(to: msg2.details as NSDictionary) &&
    msg1.reason == msg2.reason &&
    (msg1.args as? NSArray)?.isEqual(to: msg2.args as? NSArray) ?? (msg1.args == nil && msg2.args == nil) &&
    (msg1.kwargs as NSDictionary?)?.isEqual(to: msg2.kwargs as NSDictionary?) ?? (msg1.kwargs == nil
                                                                                  && msg2.kwargs == nil)
}

func testAbortMessage(serializerStr: String, serializer: Serializer) throws {
    let details: [String: Any] = ["message": "unauthorized"]
    let reason = "wamp.error.authorization_failed"
    let args: [Any] = ["arg1", "arg2"]
    let kwargs: [String: Any] = ["key1": "value1"]

    let message = Abort(details: details, reason: reason, args: args, kwargs: kwargs)

    let command = "message abort \(reason) -d message=unauthorized arg1 arg2 -k key1:value1 " +
                  "--serializer \(serializerStr) --output hex"

    guard let msg = runCommandAndDeserialize(serializer: serializer, command: command) as? Abort else {
        XCTFail("Failed to deserialize the Abort message")
        return
    }

    XCTAssertTrue(isEqual(msg1: message, msg2: msg), "Abort message deserialization failed")
}

class AbortMessageTest: XCTestCase {

    func testJSONSerializer() {
        let serializer = JSONSerializer()
        do {
            try testAbortMessage(serializerStr: "json", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testMsgPackSerializer() {
        let serializer = MsgPackSerializer()
        do {
            try testAbortMessage(serializerStr: "msgpack", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testCBORSerializer() {
        let serializer = CBORSerializer()
        do {
            try testAbortMessage(serializerStr: "cbor", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }
}
