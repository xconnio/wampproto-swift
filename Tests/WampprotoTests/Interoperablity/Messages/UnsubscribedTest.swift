@testable import Wampproto
import XCTest

func isEqual(msg1: Unsubscribed, msg2: Unsubscribed) -> Bool {
    msg1.requestID == msg2.requestID
}

func testUnsubscribedMessage(serializerStr: String, serializer: Serializer) throws {
    let requestID: UInt64 = 12345

    let message = Unsubscribed(requestID: requestID)

    let command = "message unsubscribed \(requestID) --serializer \(serializerStr) --output hex"

    guard let msg = runCommandAndDeserialize(serializer: serializer, command: command) as? Unsubscribed else {
        XCTFail("Failed to deserialize the Unsubscribed message")
        return
    }

    XCTAssertTrue(isEqual(msg1: message, msg2: msg), "Unsubscribed message deserialization failed")
}

class UnsubscribedMessageTest: XCTestCase {
    func testJSONSerializer() {
        let serializer = JSONSerializer()
        do {
            try testUnsubscribedMessage(serializerStr: "json", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testMsgPackSerializer() {
        let serializer = MsgPackSerializer()
        do {
            try testUnsubscribedMessage(serializerStr: "msgpack", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testCBORSerializer() {
        let serializer = CBORSerializer()
        do {
            try testUnsubscribedMessage(serializerStr: "cbor", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }
}
