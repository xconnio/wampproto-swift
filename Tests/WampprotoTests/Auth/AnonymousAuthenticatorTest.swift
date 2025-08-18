@testable import Wampproto
import XCTest

class AnonymousAuthenticatorTest: XCTestCase {
    let authID = "authID"
    let authExtra: [String: Any] = ["extra": "data"]
    let authenticator = AnonymousAuthenticator(authID: "authID", authExtra: ["extra": "data"])

    func testConstructor() {
        XCTAssertNotNil(authenticator)
        XCTAssertEqual(authID, authenticator.authID)
        XCTAssertEqual(authExtra as NSDictionary, authenticator.authExtra as NSDictionary)
        XCTAssertEqual("anonymous", authenticator.authMethod)
    }

    func testAuthenticate() {
        let challenge = Challenge(authMethod: authenticator.authMethod, extra: ["challenge": "test"])
        XCTAssertThrowsError(try authenticator.authenticate(challenge: challenge)) { error in
            XCTAssertEqual(error as? AuthenticationError, AuthenticationError.notSupported)
        }
    }
}
