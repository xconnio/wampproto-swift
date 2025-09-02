@testable import Wampproto
import XCTest

func isEqual(msg1: Invocation, msg2: Invocation) -> Bool {
    msg1.requestID == msg2.requestID &&
        msg1.registrationID == msg2.registrationID &&
        (msg1.args as NSArray?) == (msg2.args as NSArray?) &&
        (msg1.kwargs as NSDictionary?) == (msg2.kwargs as NSDictionary?) &&
        (msg1.details as NSDictionary) == (msg2.details as NSDictionary)
}

func testInvocationMessage(serializerStr: String, serializer: Serializer) throws {
    let requestID: UInt64 = 56789
    let registrationID: UInt64 = 98765
    let args: [Any] = [100, "test"]
    let kwargs: [String: Any] = ["param": "value"]
    let details: [String: Any] = ["info": true]

    let message = Invocation(requestID: requestID, registrationID: registrationID,
                             args: args, kwargs: kwargs, details: details)

    let command = "message invocation \(requestID) \(registrationID) 100 test" +
        " -k param=value -d info=true --serializer \(serializerStr) --output hex"

    guard let msg = runCommandAndDeserialize(serializer: serializer, command: command) as? Invocation else {
        XCTFail("Failed to deserialize the Invocation message")
        return
    }

    XCTAssertTrue(isEqual(msg1: message, msg2: msg), "Invocation message deserialization failed")
}

class InvocationMessageTest: XCTestCase {
    func testJSONSerializer() {
        let serializer = JSONSerializer()
        do {
            try testInvocationMessage(serializerStr: "json", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testMsgPackSerializer() {
        let serializer = MsgPackSerializer()
        do {
            try testInvocationMessage(serializerStr: "msgpack", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testCBORSerializer() {
        let serializer = CBORSerializer()
        do {
            try testInvocationMessage(serializerStr: "cbor", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }
}
