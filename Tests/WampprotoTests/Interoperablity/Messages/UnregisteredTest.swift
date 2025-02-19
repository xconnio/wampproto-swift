import XCTest
@testable import Wampproto

func isEqual(msg1: Unregistered, msg2: Unregistered) -> Bool {
    return msg1.requestID == msg2.requestID
}

func testUnregisteredMessage(serializerStr: String, serializer: Serializer) throws {
    let requestID: Int64 = 12345

    let message = Unregistered(requestID: requestID)

    let command = "message unregistered \(requestID) --serializer \(serializerStr) --output hex"

    guard let msg = runCommandAndDeserialize(serializer: serializer, command: command) as? Unregistered else {
        XCTFail("Failed to deserialize the Unregistered message")
        return
    }

    XCTAssertTrue(isEqual(msg1: message, msg2: msg), "Unregistered message deserialization failed")
}

class UnregisteredMessageTest: XCTestCase {

    func testJSONSerializer() {
        let serializer = JSONSerializer()
        do {
            try testUnregisteredMessage(serializerStr: "json", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testMsgPackSerializer() {
        let serializer = MsgPackSerializer()
        do {
            try testUnregisteredMessage(serializerStr: "msgpack", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testCBORSerializer() {
        let serializer = CBORSerializer()
        do {
            try testUnregisteredMessage(serializerStr: "cbor", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }
}
