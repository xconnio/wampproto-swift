import XCTest
@testable import Wampproto

func isEqual(msg1: Welcome, msg2: Welcome) -> Bool {
    return msg1.sessionID == msg2.sessionID &&
    (msg1.roles as NSDictionary).isEqual(to: msg2.roles as NSDictionary) &&
    msg1.authID == msg2.authID &&
    msg1.authRole == msg2.authRole &&
    msg1.authMethod == msg2.authMethod &&
    (msg1.authExtra as NSDictionary).isEqual(to: msg2.authExtra as NSDictionary)
}

func testWelcomeMessage(serializerStr: String, serializer: Serializer) throws {
    let sessionID: Int64 = 12345
    let roles: [String: Any] = ["callee": true]
    let authID = "user123"
    let authRole = "admin"
    let authMethod = "wampcra"
    let authExtra: [String: Any] = ["token": "xyz"]

    let message = Welcome(
        sessionID: sessionID,
        roles: roles,
        authID: authID,
        authRole: authRole,
        authMethod: authMethod,
        authExtra: authExtra
    )

    let command = "message welcome \(sessionID) --authid \(authID) --authrole \(authRole) " +
                  "--authmethod \(authMethod) --roles callee=true -e token:xyz " +
                  "--serializer \(serializerStr) --output hex"

    guard let msg = runCommandAndDeserialize(serializer: serializer, command: command) as? Welcome else {
        XCTFail("Failed to deserialize the Welcome message")
        return
    }

    XCTAssertTrue(isEqual(msg1: message, msg2: msg), "Welcome message deserialization failed")
}

class WelcomeMessageTest: XCTestCase {

    func testJSONSerializer() {
        let serializer = JSONSerializer()
        do {
            try testWelcomeMessage(serializerStr: "json", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testMsgPackSerializer() {
        let serializer = MsgPackSerializer()
        do {
            try testWelcomeMessage(serializerStr: "msgpack", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testCBORSerializer() {
        let serializer = CBORSerializer()
        do {
            try testWelcomeMessage(serializerStr: "cbor", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }
}
