import XCTest
@testable import Wampproto

class JoinerTest: XCTestCase {
    private let testRealm = "test.realm"
    private let testSessionID: Int64 = 12345
    private let testAuthID = "test_authid"
    private let testAuthRole = "test_role"
    private let testAuthMethod = "anonymous"

    func testSendHello() throws {
        let joiner = Joiner(realm: testRealm)
        let serializedHello = try joiner.sendHello() as? String

        let deserializedHello = try JSONSerializer().deserialize(data: serializedHello!)
        XCTAssertTrue(deserializedHello is Hello)

        let helloMessage = deserializedHello as? Hello
        XCTAssertEqual(helloMessage!.realm, testRealm)
        XCTAssertEqual(helloMessage!.authMethods.first, testAuthMethod)
        XCTAssertEqual(helloMessage!.authID, "")
        XCTAssertEqual(helloMessage!.roles as NSDictionary, clientRoles as NSDictionary)

    }

    func testReceiveWelcomeMessage() throws {
        let joiner = Joiner(realm: testRealm)
        _ = try joiner.sendHello()

        let welcomeMessage = Welcome(sessionID: testSessionID, roles: clientRoles, authID: testAuthID,
                                     authRole: testAuthRole, authMethod: testAuthMethod)
        let serializedWelcome = try JSONSerializer().serialize(message: welcomeMessage)

        let result = try joiner.receive(data: serializedWelcome)
        XCTAssertNil(result) // No further message expected after Welcome

        let sessionDetails = try joiner.getSessionDetails()
        XCTAssertEqual(sessionDetails.sessionID, testSessionID)
        XCTAssertEqual(sessionDetails.realm, testRealm)
        XCTAssertEqual(sessionDetails.authID, testAuthID)
        XCTAssertEqual(sessionDetails.authRole, testAuthRole)
    }

    func testReceiveChallengeMessage() throws {
        let joiner = Joiner(realm: testRealm, authenticator: TicketAuthenticator(authID: testAuthID, ticket: "test"))
        _ = try joiner.sendHello()

        let challengeMessage = Challenge(authMethod: "cryptosign", extra: ["challenge": "123456"])
        let serializedChallenge = try JSONSerializer().serialize(message: challengeMessage)

        let result = try joiner.receive(data: serializedChallenge) as? String
        XCTAssertNotNil(result) // Authenticate message expected after Challenge

        let deserializedResult = try JSONSerializer().deserialize(data: result!)
        XCTAssertTrue(deserializedResult is Authenticate)

        XCTAssertThrowsError(try joiner.getSessionDetails()) { error in
            XCTAssertTrue(error is SessionNotReady)
        }

        let welcomeMessage = Welcome(sessionID: testSessionID, roles: clientRoles, authID: testAuthID,
                                     authRole: testAuthRole, authMethod: testAuthMethod)
        let serializedWelcome = try JSONSerializer().serialize(message: welcomeMessage)

        let finalResult = try joiner.receive(data: serializedWelcome)
        XCTAssertNil(finalResult) // No further message expected after Welcome

        let sessionDetails = try joiner.getSessionDetails()
        XCTAssertEqual(sessionDetails.sessionID, testSessionID)
        XCTAssertEqual(sessionDetails.realm, testRealm)
        XCTAssertEqual(sessionDetails.authID, testAuthID)
        XCTAssertEqual(sessionDetails.authRole, testAuthRole)
    }

    func testReceiveAbortMessage() throws {
        let joiner = Joiner(realm: testRealm)
        _ = try joiner.sendHello()

        let abortMessage = Abort(details: [:], reason: "some.message")
        let serializedAbort = try JSONSerializer().serialize(message: abortMessage)

        XCTAssertThrowsError(try joiner.receive(data: serializedAbort)) { error in
            XCTAssertEqual(error.localizedDescription, "received abort")
        }
    }
}
