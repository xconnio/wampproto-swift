@testable import Wampproto
import XCTest

func isEqual(msg1: Authenticate, msg2: Authenticate) -> Bool {
    msg1.signature == msg2.signature &&
        (msg1.extra as NSDictionary).isEqual(to: msg2.extra as NSDictionary)
}

func testAuthenticateMessage(serializerStr: String, serializer: Serializer) throws {
    let signature = "test-signature"
    let extra: [String: Any] = ["foo": "bar"]

    let message = Authenticate(signature: signature, extra: extra)

    let command = "message authenticate \(signature) -e foo:bar --serializer \(serializerStr) --output hex"

    guard let msg = runCommandAndDeserialize(serializer: serializer, command: command) as? Authenticate else {
        XCTFail("Failed to deserialize the Authenticate message")
        return
    }

    XCTAssertTrue(isEqual(msg1: message, msg2: msg), "Authenticate message deserialization failed")
}

class AuthenticateMessageTest: XCTestCase {
    func testJSONSerializer() {
        let serializer = JSONSerializer()
        do {
            try testAuthenticateMessage(serializerStr: "json", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testMsgPackSerializer() {
        let serializer = MsgPackSerializer()
        do {
            try testAuthenticateMessage(serializerStr: "msgpack", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testCBORSerializer() {
        let serializer = CBORSerializer()
        do {
            try testAuthenticateMessage(serializerStr: "cbor", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }
}
