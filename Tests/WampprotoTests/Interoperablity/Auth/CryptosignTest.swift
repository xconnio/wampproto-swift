import XCTest
@testable import Wampproto

class CryptosignTest: XCTestCase {
    private let testPublicKey = "2b7ec216daa877c7f4c9439db8a722ea2340eacad506988db2564e258284f895"
    private let testPrivateKey = "022b089bed5ab78808365e82dd12c796c835aeb98b4a5a9e099d3e72cb719516"

    func testGenerateChallenge() {
        let challenge = generateCryptoSignChallenge()

        let signature = runCommand(command: "auth cryptosign sign-challenge \(challenge) \(testPrivateKey)")

        _ = runCommand(command: "auth cryptosign verify-signature " +
                       "\(signature!.trimmingCharacters(in: .whitespacesAndNewlines)) \(testPublicKey)")
    }

    func testSignCrytosignChallenge() throws {
        let challenge = runCommand(command: "auth cryptosign generate-challenge")

        var signature = try signCryptoSignChallenge(challenge:
                                                        challenge!.trimmingCharacters(in: .whitespacesAndNewlines),
                                                    privateKey: testPrivateKey)

        if try signature.hexDecodedBytes().count == 64 {
            signature += challenge!.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        _ = runCommand(command: "auth cryptosign verify-signature \(signature) \(testPublicKey)")
    }

    func testVerifyCryptosignSignature() throws {
        let challenge = runCommand(command: "auth cryptosign generate-challenge")

        let signature = runCommand(command: "auth cryptosign sign-challenge" +
                                   " \(challenge!.trimmingCharacters(in: .whitespacesAndNewlines)) \(testPrivateKey)")

        let isVerified = try verifyCryptoSignSignature(
            signature: signature!.trimmingCharacters(in: .whitespacesAndNewlines),
            publicKey: testPublicKey.hexDecodedBytes())
        XCTAssertTrue(isVerified)
    }
}
