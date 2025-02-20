import Foundation
import XCTest
@testable import Wampproto

class CRATest: XCTestCase {
    private let sessionID = 123
    private let authID = "foo"
    private let authRole = "admin"
    private let provider = "provider"
    private let testSecret = "secret"
    private let salt = "salt"
    private let keylength = 32
    private let iterations = 1000
    private let craChallenge =  """
{"nonce":"cdcb3b12d56e12825be99f38f55ba43f","authprovider":"provider",\
"authid":"foo","authrole":"admin","authmethod":"wampcra","session":123,\
"timestamp":"2024-05-07T09:25:13.307Z"}
"""
    private func authExtra() -> [String: Any] {
            return [
                "challenge": craChallenge,
                "salt": salt,
                "iterations": iterations,
                "keylen": keylength
            ]
        }

    func testGenerateChallenge() {
        let challenge = generateWAMPCRAChallenge(sessionID: sessionID, authID: authID, authRole: authRole,
                                                 provider: provider)

        let signature = runCommand(command: "auth cra sign-challenge \(challenge!) \(testSecret)")

        _ = runCommand(command: "auth cra verify-signature \(challenge!) "
                       + "\(signature!.trimmingCharacters(in: .whitespacesAndNewlines)) \(testSecret)")
    }

    func testSignWAMPCRAChallenge() {
        let challenge = runCommand(command: "auth cra generate-challenge \(sessionID) \(authID) " +
                                   "\(authRole) \(provider)")

        let signature = signWampCRAChallenge(challenge: challenge!.trimmingCharacters(in: .whitespacesAndNewlines),
                                             key: testSecret.data(using: .utf8)!)

        _ = runCommand(command: "auth cra verify-signature \(challenge!) \(signature) \(testSecret)")
    }

    func testVerifyWAMPCRASignature() {
        let challenge = runCommand(command: "auth cra generate-challenge \(sessionID) \(authID) " +
                                   "\(authRole) \(provider)")

        let signature = runCommand(command: "auth cra sign-challenge " +
                                   "\(challenge!.trimmingCharacters(in: .whitespacesAndNewlines)) \(testSecret)")

        let isVerified = verifyWampCRASignature(signature: signature!.trimmingCharacters(in: .whitespacesAndNewlines),
                                                challenge: challenge!.trimmingCharacters(in: .whitespacesAndNewlines),
                                                key: testSecret.data(using: .utf8)!)
        XCTAssertTrue(isVerified)
    }

    func testSignWAMPCRASignatureWithSalt() throws {
        let challenge = Challenge(authMethod: CRAAuthenticator.type, extra: authExtra())
        let authenticator = CRAAuthenticator(authID: authID, authExtra: authExtra(), secret: testSecret)
        let authenticate = try authenticator.authenticate(challenge: challenge)

        let saltSecret = runCommand(command: "auth cra derive-key \(salt) \(testSecret)" +
                                    " -i \(iterations) -l \(keylength)")

        _ = runCommand(command: "auth cra verify-signature \(craChallenge) " +
                       "\(authenticate.signature) \(saltSecret!.trimmingCharacters(in: .whitespacesAndNewlines))")
    }

    func testVerifyWAMPCRASignatureWithSalt() {
        let challenge = runCommand(command: "auth cra generate-challenge \(sessionID) " +
                                   "\(authID) \(authRole) \(provider)")

        let saltSecret = runCommand(command: "auth cra derive-key \(salt) \(testSecret)" +
                                    " -i \(iterations) -l \(keylength)")
        let signature = runCommand(command: "auth cra sign-challenge " +
                                   "\(challenge!.trimmingCharacters(in: .whitespacesAndNewlines))" +
                                   " \(saltSecret!.trimmingCharacters(in: .whitespacesAndNewlines))")

        let isVerified = verifyWampCRASignature(signature: signature!.trimmingCharacters(in: .whitespacesAndNewlines),
                                                challenge: challenge!.trimmingCharacters(in: .whitespacesAndNewlines),
                                                key: saltSecret!.trimmingCharacters(in: .whitespacesAndNewlines)
            .data(using: .utf8)!)
        XCTAssertTrue(isVerified)
    }
}
