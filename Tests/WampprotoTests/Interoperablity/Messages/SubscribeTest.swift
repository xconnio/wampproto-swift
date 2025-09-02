@testable import Wampproto
import XCTest

func isEqual(msg1: Subscribe, msg2: Subscribe) -> Bool {
    msg1.requestID == msg2.requestID &&
        msg1.topic == msg2.topic &&
        (msg1.options as NSDictionary) == (msg2.options as NSDictionary)
}

func testSubscribeMessage(serializerStr: String, serializer: Serializer) throws {
    let requestID: UInt64 = 98765
    let topic = "com.example.topic"
    let options: [String: Any] = ["option1": true, "option2": 42]

    let message = Subscribe(requestID: requestID, topic: topic, options: options)

    let command = "message subscribe \(requestID) \(topic) -o option1=true -o option2=42" +
        " --serializer \(serializerStr) --output hex"

    guard let msg = runCommandAndDeserialize(serializer: serializer, command: command) as? Subscribe else {
        XCTFail("Failed to deserialize the Subscribe message")
        return
    }

    XCTAssertTrue(isEqual(msg1: message, msg2: msg), "Subscribe message deserialization failed")
}

class SubscribeMessageTest: XCTestCase {
    func testJSONSerializer() {
        let serializer = JSONSerializer()
        do {
            try testSubscribeMessage(serializerStr: "json", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testMsgPackSerializer() {
        let serializer = MsgPackSerializer()
        do {
            try testSubscribeMessage(serializerStr: "msgpack", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testCBORSerializer() {
        let serializer = CBORSerializer()
        do {
            try testSubscribeMessage(serializerStr: "cbor", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }
}
