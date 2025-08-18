@testable import Wampproto
import XCTest

class TicketAuthenticatorTest: XCTestCase {
    let authID = "authID"
    let authExtra: [String: Any] = ["extra": "data"]
    let ticket = "new ticket"
    let authenticator = TicketAuthenticator(authID: "authID", authExtra: ["extra": "data"], ticket: "new ticket")

    func testConstructor() {
        XCTAssertNotNil(authenticator)
        XCTAssertEqual(authID, authenticator.authID)
        XCTAssertEqual(authExtra as NSDictionary, authenticator.authExtra as NSDictionary)
        XCTAssertEqual("ticket", authenticator.authMethod)
    }

    func testAuthenticate() {
        let challenge = Challenge(authMethod: authenticator.authMethod, extra: ["challenge": "test"])
        let authenticate = authenticator.authenticate(challenge: challenge)
        XCTAssertEqual(authenticate.signature, ticket)
    }
}
