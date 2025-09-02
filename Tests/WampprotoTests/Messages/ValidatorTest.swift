@testable import Wampproto
import XCTest

class ValidationTests: XCTestCase {
    func testSanityCheck_valid() throws {
        let message = [1, 2, 3]
        XCTAssertNoThrow(try sanityCheck(wampMsg: message, minLength: 1, maxLength: 5))

        let invalidMessage = [1, 2]
        XCTAssertThrowsError(try sanityCheck(wampMsg: invalidMessage, minLength: 3, maxLength: 5)) { error in
            XCTAssertEqual((error as? ValidationError)?.error,
                           "Unexpected message length, must be at least 3 and at most 5, but was 2")
        }
    }

    func testSanityCheck_invalid() throws {
        let message = [1, 2]
        XCTAssertThrowsError(try sanityCheck(wampMsg: message, minLength: 3, maxLength: 5)) { error in
            XCTAssertEqual((error as? ValidationError)?.error,
                           "Unexpected message length, must be at least 3 and at most 5, but was 2")
        }
    }

    func testValidateID_valid() throws {
        let message: [Any] = [12345 as UInt64]
        let result = try validateID(wampMsg: message, index: 0)
        XCTAssertEqual(result, 12345)
    }

    func testValidateID_invalid() {
        let message: [Any] = ["NotAnInt"]
        XCTAssertThrowsError(try validateID(wampMsg: message, index: 0)) { error in
            XCTAssertEqual((error as? ValidationError)?.error, "Item at index 0 must be of type UInt64 but was String")
        }
    }

    func testValidateString_valid() throws {
        let message: [Any] = ["validString"]
        let result = try validateString(wampMsg: message, index: 0)
        XCTAssertEqual(result, "validString")
    }

    func testValidateString_invalid() {
        let message: [Any] = [12345]
        XCTAssertThrowsError(try validateString(wampMsg: message, index: 0)) { error in
            XCTAssertEqual((error as? ValidationError)?.error, "Item at index 0 must be of type String but was Int")
        }
    }

    func testValidateArray_valid() throws {
        let message: [Any] = [[1, 2, 3]]
        let result = try validateArray(wampMsg: message, index: 0)
        XCTAssertEqual(result as? [Int], [1, 2, 3])
    }

    func testValidateArray_invalid() {
        let message: [Any] = [123]
        XCTAssertThrowsError(try validateArray(wampMsg: message, index: 0)) { error in
            XCTAssertEqual((error as? ValidationError)?.error, "Item at index 0 must be of type [Any] but was Int")
        }
    }

    func testValidateMap_valid() throws {
        let message: [Any] = [["key": "value"]]
        let result = try validateMap(wampMsg: message, index: 0)
        XCTAssertEqual(result as? [String: String], ["key": "value"])
    }

    func testValidateMap_invalid() {
        let message: [Any] = [123]
        XCTAssertThrowsError(try validateMap(wampMsg: message, index: 0)) { error in
            XCTAssertEqual((error as? ValidationError)?.error,
                           "Item at index 0 must be of type [String: Any] but was Int")
        }
    }

    func testValidateArgs() throws {
        let fields = Fields()
        let message: [Any] = [[], ["arg1", "arg2"]]

        try validateArgs(wampMsg: message, index: 1, fields: fields)
        XCTAssertEqual(fields.args as? [String], ["arg1", "arg2"])
    }

    func testValidateSessionID() throws {
        let fields = Fields()
        let message: [Any] = [1, Int64(12345)]

        try validateSessionID(wampMsg: message, index: 1, fields: fields)
        XCTAssertEqual(fields.sessionID, 12345)
    }

    func testValidateMessageType() throws {
        let fields = Fields()
        let message: [Any] = [Int64(99)]

        try validateMessageType(wampMsg: message, index: 0, fields: fields)
        XCTAssertEqual(fields.messageType, 99)
    }

    func testValidateRequestID() throws {
        let fields = Fields()
        let message: [Any] = [1, Int64(555)]

        try validateRequestID(wampMsg: message, index: 1, fields: fields)
        XCTAssertEqual(fields.requestID, 555)
    }

    func testValidateRegistrationID() throws {
        let fields = Fields()
        let message: [Any] = [1, Int64(555)]

        try validateRegistrationID(wampMsg: message, index: 1, fields: fields)
        XCTAssertEqual(fields.registrationID, 555)
    }

    func testValidatePublicationID() throws {
        let fields = Fields()
        let message: [Any] = [1, Int64(555)]

        try validatePublicationID(wampMsg: message, index: 1, fields: fields)
        XCTAssertEqual(fields.publicationID, 555)
    }

    func testValidateSubscriptionID() throws {
        let fields = Fields()
        let message: [Any] = [1, Int64(555)]

        try validateSubscriptionID(wampMsg: message, index: 1, fields: fields)
        XCTAssertEqual(fields.subscriptionID, 555)
    }

    func testValidateSignature() throws {
        let fields = Fields()
        let message: [Any] = [1, "Signature"]

        try validateSignature(wampMsg: message, index: 1, fields: fields)
        XCTAssertEqual(fields.signature, "Signature")
    }

    func testValidateURI() throws {
        let fields = Fields()
        let message: [Any] = ["io.xconn.topic"]

        try validateURI(wampMsg: message, index: 0, fields: fields)
        XCTAssertEqual(fields.uri, "io.xconn.topic")
    }

    func testValidateRealm() throws {
        let fields = Fields()
        let message: [Any] = ["io.xconn.realm1"]

        try validateRealm(wampMsg: message, index: 0, fields: fields)
        XCTAssertEqual(fields.realm, "io.xconn.realm1")
    }

    func testValidateAuthMethod() throws {
        let fields = Fields()
        let message: [Any] = ["anonymous"]

        try validateAuthMethod(wampMsg: message, index: 0, fields: fields)
        XCTAssertEqual(fields.authMethod, "anonymous")
    }

    func testValidateReason() throws {
        let fields = Fields()
        let message: [Any] = ["wamp.close.reason"]

        try validateReason(wampMsg: message, index: 0, fields: fields)
        XCTAssertEqual(fields.reason, "wamp.close.reason")
    }

    func testValidateExtra() throws {
        let fields = Fields()
        let message: [Any] = [["key": "value"]]

        try validateExtra(wampMsg: message, index: 0, fields: fields)
        XCTAssertEqual(fields.extra as? [String: String], ["key": "value"])
    }

    func testValidateOptions() throws {
        let fields = Fields()
        let message: [Any] = [["opt": true]]

        try validateOptions(wampMsg: message, index: 0, fields: fields)
        XCTAssertEqual(fields.options as? [String: Bool], ["opt": true])
    }

    func testValidateDetails() throws {
        let fields = Fields()
        let message: [Any] = [["detail": "info"]]

        try validateDetails(wampMsg: message, index: 0, fields: fields)
        XCTAssertEqual(fields.details as? [String: String], ["detail": "info"])
    }

    func testValidateKwargsD() throws {
        let fields = Fields()
        let message: [Any] = [1, ["foo": 1]]

        try validateKWArgs(wampMsg: message, index: 1, fields: fields)
        XCTAssertEqual(fields.kwArgs as? [String: Int], ["foo": 1])
    }

    func testValidateMessage_valid() throws {
        let message: [Any] = [12345 as Int64, "testURI"]
        let spec = ValidationSpec(minLength: 2, maxLength: 2, message: "Test", spec: [
            0: validateRequestID,
            1: validateURI
        ])

        let fields = try validateMessage(wampMsg: message, spec: spec)
        XCTAssertEqual(fields.requestID, 12345)
        XCTAssertEqual(fields.uri, "testURI")
    }

    func testValidateMessage_invalid() {
        let message: [Any] = ["invalid", "foo.bar"]
        let spec = ValidationSpec(minLength: 2, maxLength: 2, message: "Test", spec: [
            0: validateRequestID,
            1: validateURI
        ])

        XCTAssertThrowsError(try validateMessage(wampMsg: message, spec: spec)) { error in
            XCTAssertEqual((error as? ValidationError)?.error,
                           "Validation failed: \nItem at index 0 must be of type UInt64 but was String")
        }
    }
}
