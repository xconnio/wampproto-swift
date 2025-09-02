@testable import Wampproto
import XCTest

func isEqual(msg1: Wampproto.Published, msg2: Wampproto.Published) -> Bool {
    msg1.requestID == msg2.requestID &&
        msg1.publicationID == msg2.publicationID
}

func testPublishedMessage(serializerStr: String, serializer: Serializer) throws {
    let requestID: UInt64 = 67890
    let publicationID: UInt64 = 98765

    let message = Published(requestID: requestID, publicationID: publicationID)

    let command = "message published \(requestID) \(publicationID) --serializer \(serializerStr) --output hex"

    guard let msg = runCommandAndDeserialize(serializer: serializer, command: command) as? Wampproto.Published else {
        XCTFail("Failed to deserialize the Published message")
        return
    }

    XCTAssertTrue(isEqual(msg1: message, msg2: msg), "Published message deserialization failed")
}

class PublishedMessageTest: XCTestCase {
    func testJSONSerializer() {
        let serializer = JSONSerializer()
        do {
            try testPublishedMessage(serializerStr: "json", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testMsgPackSerializer() {
        let serializer = MsgPackSerializer()
        do {
            try testPublishedMessage(serializerStr: "msgpack", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testCBORSerializer() {
        let serializer = CBORSerializer()
        do {
            try testPublishedMessage(serializerStr: "cbor", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }
}
