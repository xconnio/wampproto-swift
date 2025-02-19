import XCTest
@testable import Wampproto

func isEqual(msg1: Hello, msg2: Hello) -> Bool {
    return msg1.authID == msg2.authID &&
    msg1.realm == msg2.realm &&
    (msg1.roles as NSDictionary).isEqual(to: msg2.roles as NSDictionary) &&
    msg1.authMethods == msg2.authMethods &&
    (msg1.authExtra as NSDictionary).isEqual(to: msg2.authExtra as NSDictionary)
}

func testHelloMessage(serializerStr: String, serializer: Serializer) throws {
    let realm1 = "realm1"
    let authMethod = "anonymous"
    let authID = "foo"

    let message = Hello(
        realm: realm1,
        roles: ["callee": true],
        authID: authID,
        authMethods: [authMethod],
        authExtra: ["foo": "bar"]
    )

    let command = "message hello \(realm1) \(authMethod) --authid \(authID) -r callee=true " +
    "-e foo:bar --serializer \(serializerStr) --output hex"

    guard let msg = runCommandAndDeserialize(serializer: serializer, command: command) as? Hello else {
        XCTFail("Failed to deserialize the Hello message")
        return
    }

    XCTAssertTrue(isEqual(msg1: message, msg2: msg), "Hello message deserialization failed")
}

class HelloMessageTest: XCTestCase {

    func testJSONSerializer() {
        let serializer = JSONSerializer()
        do {
            try testHelloMessage(serializerStr: "json", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testCBORSerializer() {
        let serializer = CBORSerializer()
        do {
            try testHelloMessage(serializerStr: "cbor", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testMsgPackSerializer() {
        let serializer = MsgPackSerializer()
        do {
            try testHelloMessage(serializerStr: "msgpack", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }
}
