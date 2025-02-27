import XCTest
@testable import Wampproto

func isEqual(msg1: Event, msg2: Event) -> Bool {
    return msg1.subscriptionID == msg2.subscriptionID &&
    msg1.publicationID == msg2.publicationID &&
    (msg1.args as? [AnyHashable]) == (msg2.args as? [AnyHashable]) &&
    (msg1.kwargs as NSDictionary?) == (msg2.kwargs as NSDictionary?) &&
    (msg1.details as NSDictionary) == (msg2.details as NSDictionary)
}

func testEventMessage(serializerStr: String, serializer: Serializer) throws {
    let subscriptionID: Int64 = 12345
    let publicationID: Int64 = 67890
    let args: [Any] = ["value1", 42]
    let kwargs: [String: Any] = ["key1": "value1", "key2": 42]
    let details: [String: Any] = ["detailKey": "detailValue"]

    let message = Event(subscriptionID: subscriptionID, publicationID: publicationID,
                        args: args, kwargs: kwargs, details: details)

    let command = "message event \(subscriptionID) \(publicationID) value1 42 -k key1=value1 -k key2=42 " +
    "-d detailKey=detailValue --serializer \(serializerStr) --output hex"

    guard let msg = runCommandAndDeserialize(serializer: serializer, command: command) as? Event else {
        XCTFail("Failed to deserialize the Event message")
        return
    }

    XCTAssertTrue(isEqual(msg1: message, msg2: msg), "Event message deserialization failed")
}

class EventMessageTest: XCTestCase {

    func testJSONSerializer() {
        let serializer = JSONSerializer()
        do {
            try testEventMessage(serializerStr: "json", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testMsgPackSerializer() {
        let serializer = MsgPackSerializer()
        do {
            try testEventMessage(serializerStr: "msgpack", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testCBORSerializer() {
        let serializer = CBORSerializer()
        do {
            try testEventMessage(serializerStr: "cbor", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }
}
