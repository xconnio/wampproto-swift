import XCTest

@testable import Wampproto

class SessionScopeIDGeneratorTests: XCTestCase {

    func testGenerateSessionID() {
        let sessionID = generateSessionID()
        XCTAssertTrue(sessionID >= 0 && sessionID < maxID)
    }

    func testSessionScopeIDGeneratorIncrementsCorrectly() {
        let generator = SessionScopeIDGenerator()

        let firstID = generator.next()
        let secondID = generator.next()
        let thirdID = generator.next()

        XCTAssertEqual(firstID + 1, secondID)
        XCTAssertEqual(secondID + 1, thirdID)
    }

    func testSessionScopeIDGeneratorResetsAfterMaxScope() {
        let generator = SessionScopeIDGenerator()

        generator.id = maxID - 1

        let idAtMax = generator.next()
        let idAfterReset = generator.next()

        XCTAssertEqual(idAtMax, maxID)
        XCTAssertEqual(idAfterReset, 1)
    }
}
