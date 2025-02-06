import XCTest
@testable import Wampproto

class SerializerTests: XCTestCase {

    func testSerializer(serializer: Serializer, name: String) {
        testSerializeAndDeserialize(serializer: serializer, name: name)
        testInvalidMessage(serializer: serializer, name: name)
        testInvalidData(serializer: serializer, name: name)
    }

    func testSerializeAndDeserialize(serializer: Serializer, name: String) {
        let hello = Hello(realm: "realm1", roles: ["callee": ["allow_call": true]], authID: "test",
                          authMethods: ["anonymous"])

        do {
            let serializedData = try serializer.serialize(message: hello)
            let deserializedMessage = try serializer.deserialize(data: serializedData)

            guard let deserializedHello = deserializedMessage as? Hello else {
                XCTFail("\(name): Deserialized object should be a Hello message")
                return
            }

            XCTAssertEqual(deserializedHello.realm, hello.realm)
            XCTAssertEqual(deserializedHello.authID, hello.authID)
            XCTAssertEqual(deserializedHello.roles as NSDictionary, hello.roles as NSDictionary)
            XCTAssertEqual(deserializedHello.authExtra as NSDictionary, hello.authExtra as NSDictionary)
            XCTAssertEqual(deserializedHello.authMethods, hello.authMethods)
        } catch {
            XCTFail("\(name): Serialization/Deserialization failed with error: \(error)")
        }
    }

    func testInvalidMessage(serializer: Serializer, name: String) {
        let invalidMessage: Any = 123
        XCTAssertThrowsError(try serializer.deserialize(data: invalidMessage),
                             "\(name): Should throw error on invalid message")
    }

    func testInvalidData(serializer: Serializer, name: String) {
        let invalidData: Any = "invalid"
        XCTAssertThrowsError(try serializer.deserialize(data: invalidData),
                             "\(name): Should throw error on invalid data")
    }

    func testAllSerializers() {
        testSerializer(serializer: JSONSerializer(), name: "JsonSerializer")
    }
}
