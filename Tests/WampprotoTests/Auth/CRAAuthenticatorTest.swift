import XCTest
@testable import Wampproto

final class CRAAuthenticatorTest: XCTestCase {
    private let sessionID = 123
    private let authID = "authID"
    private let authRole = "admin"
    private let provider = "provider"
    private let authExtra: [String: Any] = ["challenge": "data"]
    private let key = "6d9b906ad60d1f4dd796dbadcc2e2252310565ccdc6fe10b289df5684faf2a46"

    private lazy var authenticator = CRAAuthenticator(authID: authID, authExtra: authExtra, secret: key)

    private let validSignature = "DIVL3bKs/Ei91eQyYznzUqEsiTmX705BNEXuicNpi8A="
    private let craChallenge =  """
{"nonce":"cdcb3b12d56e12825be99f38f55ba43f","authprovider":"provider",\
"authid":"foo","authrole":"admin","authmethod":"wampcra","session":123,\
"timestamp":"2024-05-07T09:25:13.307Z"}
"""

    func testConstructor() {
        XCTAssertNotNil(authenticator)
        XCTAssertEqual(authenticator.authID, authID)
        XCTAssertEqual(authenticator.authExtra as NSDictionary, authExtra as NSDictionary)
        XCTAssertEqual(authenticator.authMethod, "wampcra")
    }

    func testAuthenticate() throws {
        let challenge = Challenge(authMethod: CRAAuthenticator.type, extra: ["challenge": craChallenge])
        let authenticate = try authenticator.authenticate(challenge: challenge)
        XCTAssertEqual(authenticate.signature, validSignature)
    }

    func testGenerateWAMPCRAChallenge() {
        let challenge = generateWAMPCRAChallenge(sessionID: sessionID, authID: authID, authRole: authRole,
                                                 provider: provider)
        XCTAssertNotNil(challenge)
        XCTAssertFalse(challenge!.isEmpty)
    }

    func testSignWampCRAChallenge() {
        let signature = signWampCRAChallenge(challenge: craChallenge, key: key.data(using: .utf8)!)
        XCTAssertFalse(signature.isEmpty)
    }

    func testVerifyWampCRASignature() {
        let isVerified = verifyWampCRASignature(signature: validSignature, challenge: craChallenge,
                                                key: key.data(using: .utf8)!)
        XCTAssertTrue(isVerified)
    }

    func testVerifyWampCRASignatureIncorrect() {
        let badSignature = "bad signature"
        let isVerified = verifyWampCRASignature(signature: badSignature, challenge: craChallenge,
                                                key: key.data(using: .utf8)!)
        XCTAssertFalse(isVerified)
    }
}
