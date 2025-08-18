@testable import Wampproto
import XCTest

func isEqual(msg1: Register, msg2: Register) -> Bool {
    msg1.requestID == msg2.requestID &&
        msg1.uri == msg2.uri &&
        (msg1.options as NSDictionary).isEqual(to: msg2.options as NSDictionary)
}

func testRegisterMessage(serializerStr: String, serializer: Serializer) throws {
    let requestID: Int64 = 12345
    let uri = "com.example.procedure"
    let options: [String: Any] = ["invoke": "roundrobin"]

    let message = Register(requestID: requestID, uri: uri, options: options)

    let command = "message register \(requestID) \(uri) -o invoke=roundrobin --serializer \(serializerStr) --output hex"

    guard let msg = runCommandAndDeserialize(serializer: serializer, command: command) as? Register else {
        XCTFail("Failed to deserialize the Register message")
        return
    }

    XCTAssertTrue(isEqual(msg1: message, msg2: msg), "Register message deserialization failed")
}

class RegisterMessageTest: XCTestCase {
    func testJSONSerializer() {
        let serializer = JSONSerializer()
        do {
            try testRegisterMessage(serializerStr: "json", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testMsgPackSerializer() {
        let serializer = MsgPackSerializer()
        do {
            try testRegisterMessage(serializerStr: "msgpack", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testCBORSerializer() {
        let serializer = CBORSerializer()
        do {
            try testRegisterMessage(serializerStr: "cbor", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }
}
