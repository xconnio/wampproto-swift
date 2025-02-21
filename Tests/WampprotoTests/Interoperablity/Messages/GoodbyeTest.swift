import XCTest
@testable import Wampproto

func isEqual(msg1: Goodbye, msg2: Goodbye) -> Bool {
    return (msg1.details as NSDictionary).isEqual(to: msg2.details as NSDictionary) &&
           msg1.reason == msg2.reason
}

func testGoodbyeMessage(serializerStr: String, serializer: Serializer) throws {
    let details: [String: Any] = ["message": "crash"]
    let reason = "wamp.close.goodbye_and_out"

    let message = Goodbye(details: details, reason: reason)

    let command = "message goodbye \(reason) -d message=crash --serializer \(serializerStr) --output hex"

    guard let msg = runCommandAndDeserialize(serializer: serializer, command: command) as? Goodbye else {
        XCTFail("Failed to deserialize the Goodbye message")
        return
    }

    XCTAssertTrue(isEqual(msg1: message, msg2: msg), "Goodbye message deserialization failed")
}

class GoodbyeMessageTest: XCTestCase {

    func testJSONSerializer() {
        let serializer = JSONSerializer()
        do {
            try testGoodbyeMessage(serializerStr: "json", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testMsgPackSerializer() {
        let serializer = MsgPackSerializer()
        do {
            try testGoodbyeMessage(serializerStr: "msgpack", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testCBORSerializer() {
        let serializer = CBORSerializer()
        do {
            try testGoodbyeMessage(serializerStr: "cbor", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }
}
