import XCTest
@testable import Wampproto

func isEqual(msg1: Registered, msg2: Registered) -> Bool {
    return msg1.requestID == msg2.requestID &&
           msg1.registrationID == msg2.registrationID
}

func testRegisteredMessage(serializerStr: String, serializer: Serializer) throws {
    let requestID: Int64 = 12345
    let registrationID: Int64 = 67890

    let message = Registered(requestID: requestID, registrationID: registrationID)

    let command = "message registered \(requestID) \(registrationID) --serializer \(serializerStr) --output hex"

    guard let msg = runCommandAndDeserialize(serializer: serializer, command: command) as? Registered else {
        XCTFail("Failed to deserialize the Registered message")
        return
    }

    XCTAssertTrue(isEqual(msg1: message, msg2: msg), "Registered message deserialization failed")
}

class RegisteredMessageTest: XCTestCase {

    func testJSONSerializer() {
        let serializer = JSONSerializer()
        do {
            try testRegisteredMessage(serializerStr: "json", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testMsgPackSerializer() {
        let serializer = MsgPackSerializer()
        do {
            try testRegisteredMessage(serializerStr: "msgpack", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testCBORSerializer() {
        let serializer = CBORSerializer()
        do {
            try testRegisteredMessage(serializerStr: "cbor", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }
}
