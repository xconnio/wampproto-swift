@testable import Wampproto
import XCTest

func isEqual(msg1: Cancel, msg2: Cancel) -> Bool {
    msg1.requestID == msg2.requestID &&
        (msg1.options as NSDictionary).isEqual(to: msg2.options as NSDictionary)
}

func testCancelMessage(serializerStr: String, serializer: Serializer) throws {
    let requestID: Int64 = 987_654_321
    let options: [String: Any] = ["mode": "kill"]

    let message = Cancel(requestID: requestID, options: options)

    let command = "message cancel \(requestID) -o mode=kill --serializer \(serializerStr) --output hex"

    guard let msg = runCommandAndDeserialize(serializer: serializer, command: command) as? Cancel else {
        XCTFail("Failed to deserialize the Cancel message")
        return
    }

    XCTAssertTrue(isEqual(msg1: message, msg2: msg), "Cancel message deserialization failed")
}

class CancelMessageTest: XCTestCase {
    func testJSONSerializer() {
        let serializer = JSONSerializer()
        do {
            try testCancelMessage(serializerStr: "json", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testMsgPackSerializer() {
        let serializer = MsgPackSerializer()
        do {
            try testCancelMessage(serializerStr: "msgpack", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testCBORSerializer() {
        let serializer = CBORSerializer()
        do {
            try testCancelMessage(serializerStr: "cbor", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }
}
