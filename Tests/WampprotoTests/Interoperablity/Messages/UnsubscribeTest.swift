@testable import Wampproto
import XCTest

func isEqual(msg1: Unsubscribe, msg2: Unsubscribe) -> Bool {
    msg1.requestID == msg2.requestID &&
        msg1.subscriptionID == msg2.subscriptionID
}

func testUnsubscribeMessage(serializerStr: String, serializer: Serializer) throws {
    let requestID: UInt64 = 12345
    let subscriptionID: UInt64 = 67890

    let message = Unsubscribe(requestID: requestID, subscriptionID: subscriptionID)

    let command = "message unsubscribe \(requestID) \(subscriptionID) --serializer \(serializerStr) --output hex"

    guard let msg = runCommandAndDeserialize(serializer: serializer, command: command) as? Unsubscribe else {
        XCTFail("Failed to deserialize the Unsubscribe message")
        return
    }

    XCTAssertTrue(isEqual(msg1: message, msg2: msg), "Unsubscribe message deserialization failed")
}

class UnsubscribeMessageTest: XCTestCase {
    func testJSONSerializer() {
        let serializer = JSONSerializer()
        do {
            try testUnsubscribeMessage(serializerStr: "json", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testMsgPackSerializer() {
        let serializer = MsgPackSerializer()
        do {
            try testUnsubscribeMessage(serializerStr: "msgpack", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testCBORSerializer() {
        let serializer = CBORSerializer()
        do {
            try testUnsubscribeMessage(serializerStr: "cbor", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }
}
