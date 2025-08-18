@testable import Wampproto
import XCTest

func isEqual(msg1: Error, msg2: Error) -> Bool {
    msg1.messageType == msg2.messageType &&
        msg1.requestID == msg2.requestID &&
        msg1.uri == msg2.uri &&
        (msg1.args as? NSArray)?.isEqual(to: msg2.args as? NSArray) ??
        (msg1.args == nil && msg2.args == nil) &&
        (msg1.kwargs as NSDictionary?)?.isEqual(to: msg2.kwargs as NSDictionary?) ??
        (msg1.kwargs == nil && msg2.kwargs == nil) &&
        (msg1.details as NSDictionary).isEqual(to: msg2.details as NSDictionary)
}

func testErrorMessage(serializerStr: String, serializer: Serializer) throws {
    let messageType: Int64 = 48
    let requestID: Int64 = 1_234_567_890
    let uri = "wamp.error.invalid_uri"
    let args: [Any] = ["arg1", "arg2"]
    let kwargs: [String: Any] = ["key1": "value1"]
    let details: [String: Any] = ["detail1": "value1"]

    let message = Error(messageType: messageType, requestID: requestID, uri: uri,
                        args: args, kwargs: kwargs, details: details)

    let command = "message error \(messageType) \(requestID) \(uri) " +
        "-d detail1=value1 arg1 arg2 -k key1=value1 --serializer \(serializerStr) --output hex"

    guard let msg = runCommandAndDeserialize(serializer: serializer, command: command) as? Error else {
        XCTFail("Failed to deserialize the Error message")
        return
    }

    XCTAssertTrue(isEqual(msg1: message, msg2: msg), "Error message deserialization failed")
}

class ErrorMessageTest: XCTestCase {
    func testJSONSerializer() {
        let serializer = JSONSerializer()
        do {
            try testErrorMessage(serializerStr: "json", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testMsgPackSerializer() {
        let serializer = MsgPackSerializer()
        do {
            try testErrorMessage(serializerStr: "msgpack", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testCBORSerializer() {
        let serializer = CBORSerializer()
        do {
            try testErrorMessage(serializerStr: "cbor", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }
}
