@testable import Wampproto
import XCTest

func isEqual(msg1: Subscribed, msg2: Subscribed) -> Bool {
    msg1.requestID == msg2.requestID &&
        msg1.subscriptionID == msg2.subscriptionID
}

func testSubscribedMessage(serializerStr: String, serializer: Serializer) throws {
    let requestID: UInt64 = 12345
    let subscriptionID: UInt64 = 67890

    let message = Subscribed(requestID: requestID, subscriptionID: subscriptionID)

    let command = "message subscribed \(requestID) \(subscriptionID) --serializer \(serializerStr) --output hex"

    guard let msg = runCommandAndDeserialize(serializer: serializer, command: command) as? Subscribed else {
        XCTFail("Failed to deserialize the Subscribed message")
        return
    }

    XCTAssertTrue(isEqual(msg1: message, msg2: msg), "Subscribed message deserialization failed")
}

class SubscribedMessageTest: XCTestCase {
    func testJSONSerializer() {
        let serializer = JSONSerializer()
        do {
            try testSubscribedMessage(serializerStr: "json", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testMsgPackSerializer() {
        let serializer = MsgPackSerializer()
        do {
            try testSubscribedMessage(serializerStr: "msgpack", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testCBORSerializer() {
        let serializer = CBORSerializer()
        do {
            try testSubscribedMessage(serializerStr: "cbor", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }
}
