@testable import Wampproto
import XCTest

func isEqual(msg1: Challenge, msg2: Challenge) -> Bool {
    msg1.authMethod == msg2.authMethod &&
        (msg1.extra as NSDictionary).isEqual(to: msg2.extra as NSDictionary)
}

func testChallengeMessage(serializerStr: String, serializer: Serializer) throws {
    let authMethod = "ticket"
    let extra = ["ticket": "abc"]

    let message = Challenge(authMethod: authMethod, extra: extra)

    let command = "message challenge \(authMethod) -e ticket=abc --serializer \(serializerStr) --output hex"

    guard let msg = runCommandAndDeserialize(serializer: serializer, command: command) as? Challenge else {
        XCTFail("Failed to deserialize the Challenge message")
        return
    }

    XCTAssertTrue(isEqual(msg1: message, msg2: msg), "Challenge message deserialization failed")
}

class ChallengeMessageTest: XCTestCase {
    func testJSONSerializer() {
        let serializer = JSONSerializer()
        do {
            try testChallengeMessage(serializerStr: "json", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testMsgPackSerializer() {
        let serializer = MsgPackSerializer()
        do {
            try testChallengeMessage(serializerStr: "msgpack", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }

    func testCBORSerializer() {
        let serializer = CBORSerializer()
        do {
            try testChallengeMessage(serializerStr: "cbor", serializer: serializer)
        } catch {
            XCTFail("Test failed with error: \(error.localizedDescription)")
        }
    }
}
