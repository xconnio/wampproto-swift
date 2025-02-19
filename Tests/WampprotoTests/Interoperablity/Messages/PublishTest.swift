import XCTest
@testable import Wampproto

func isEqual(msg1: Publish, msg2: Publish) -> Bool {
    return msg1.requestID == msg2.requestID &&
    msg1.uri == msg2.uri &&
    (msg1.options as NSDictionary) == (msg2.options as NSDictionary) &&
    (msg1.args as NSArray?) == (msg2.args as NSArray?) &&
    (msg1.kwargs as NSDictionary?) == (msg2.kwargs as NSDictionary?)
}

func testPublishMessage(serializerStr: String, serializer: Serializer) throws {
    let requestID: Int64 = 12345
    let uri = "com.example.topic"
    let args: [Any] = [42, "Hello"]
    let kwargs: [String: Any] = ["key": "value"]
    let options: [String: Any] = ["acknowledge": true]

    let message = Publish(requestID: requestID, uri: uri, args: args, kwargs: kwargs, options: options)

    let command = "message publish \(requestID) \(uri) 42 Hello -k key=value -o acknowledge=true" +
    " --serializer \(serializerStr) --output hex"

    guard let msg = runCommandAndDeserialize(serializer: serializer, command: command) as? Publish else {
        XCTFail("Failed to deserialize the Publish message")
        return
    }

    XCTAssertTrue(isEqual(msg1: message, msg2: msg), "Publish message deserialization failed")
}

class PublishMessageTest: XCTestCase {

    func testJSONSerializer() {
        let serializer = JSONSerializer()
        do {
            try testPublishMessage(serializerStr: "json", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testMsgPackSerializer() {
        let serializer = MsgPackSerializer()
        do {
            try testPublishMessage(serializerStr: "msgpack", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testCBORSerializer() {
        let serializer = CBORSerializer()
        do {
            try testPublishMessage(serializerStr: "cbor", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }
}
