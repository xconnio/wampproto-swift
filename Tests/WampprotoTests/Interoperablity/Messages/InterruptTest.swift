@testable import Wampproto
import XCTest

func isEqual(msg1: Interrupt, msg2: Interrupt) -> Bool {
    msg1.requestID == msg2.requestID &&
        (msg1.options as NSDictionary).isEqual(to: msg2.options as NSDictionary)
}

func testInterruptMessage(serializerStr: String, serializer: Serializer) throws {
    let requestID: Int64 = 123_456_789
    let options: [String: Any] = ["mode": "abort"]

    let message = Interrupt(requestID: requestID, options: options)

    let command = "message interrupt \(requestID) -o mode=abort --serializer \(serializerStr) --output hex"

    guard let msg = runCommandAndDeserialize(serializer: serializer, command: command) as? Interrupt else {
        XCTFail("Failed to deserialize the Interrupt message")
        return
    }

    XCTAssertTrue(isEqual(msg1: message, msg2: msg), "Interrupt message deserialization failed")
}

class InterruptMessageTest: XCTestCase {
    func testJSONSerializer() {
        let serializer = JSONSerializer()
        do {
            try testInterruptMessage(serializerStr: "json", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testMsgPackSerializer() {
        let serializer = MsgPackSerializer()
        do {
            try testInterruptMessage(serializerStr: "msgpack", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testCBORSerializer() {
        let serializer = CBORSerializer()
        do {
            try testInterruptMessage(serializerStr: "cbor", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }
}
