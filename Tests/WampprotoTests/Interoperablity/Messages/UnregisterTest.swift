@testable import Wampproto
import XCTest

func isEqual(msg1: Unregister, msg2: Unregister) -> Bool {
    msg1.requestID == msg2.requestID &&
        msg1.registrationID == msg2.registrationID
}

func testUnregisterMessage(serializerStr: String, serializer: Serializer) throws {
    let requestID: UInt64 = 54321
    let registrationID: UInt64 = 98765

    let message = Unregister(requestID: requestID, registrationID: registrationID)

    let command = "message unregister \(requestID) \(registrationID) --serializer \(serializerStr) --output hex"

    guard let msg = runCommandAndDeserialize(serializer: serializer, command: command) as? Unregister else {
        XCTFail("Failed to deserialize the Unregister message")
        return
    }

    XCTAssertTrue(isEqual(msg1: message, msg2: msg), "Unregister message deserialization failed")
}

class UnregisterMessageTest: XCTestCase {
    func testJSONSerializer() {
        let serializer = JSONSerializer()
        do {
            try testUnregisterMessage(serializerStr: "json", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testMsgPackSerializer() {
        let serializer = MsgPackSerializer()
        do {
            try testUnregisterMessage(serializerStr: "msgpack", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testCBORSerializer() {
        let serializer = CBORSerializer()
        do {
            try testUnregisterMessage(serializerStr: "cbor", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }
}
