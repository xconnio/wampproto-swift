import XCTest
@testable import Wampproto

class CryptoSignAuthenticatorTests: XCTestCase {
    private let authID = "authID"
    private let privateKeyHex = "c7e8c1f8f16ec37f53ed153f8afb7f18469b051f1d24dbea2097a2a104b2e9db"
    private let publicKeyHex = "c53e4f2756a52ca1ed5cd00da108b3ed7bcffe6294e78283521e5102824f52d3"

    private let challenge = "a1d483092ec08960fedbaed2bc1d411568a59077b794210e251bd3abb1563f7c"
    private let signature =
        "01d4b7a515b1023196e2bbb57c5202da72088f99a17eaeed62ba97ebf93381b92a3e843" +
        "0154667e194d971fb41b090a9338b92021c39271e910a8ea072fe950c"

    func testConstructor() throws {
        let authenticator = try CryptoSignAuthenticator(authID: authID, privateKey: privateKeyHex)
        XCTAssertNotNil(authenticator)
        XCTAssertEqual(authenticator.authID, authID)
        XCTAssertEqual(authenticator.authMethod, "cryptosign")
        XCTAssertEqual(authenticator.authExtra["pubkey"] as? String, publicKeyHex)
    }

    func testAuthenticate() throws {
        let authenticator = try CryptoSignAuthenticator(authID: authID, privateKey: privateKeyHex)
        let challengeObject = Challenge(authMethod: "cryptosign", extra: ["challenge": challenge])

        let authenticate = try authenticator.authenticate(challenge: challengeObject)

        XCTAssertEqual(authenticate.signature, signature + challenge)
    }

    func testGenerateCryptoSignChallenge() {
        let challenge = generateCryptoSignChallenge()
        XCTAssertEqual(challenge.count, 64)
    }

    func testSignCryptoSignChallenge() throws {
        let sig = try signCryptoSignChallenge(challenge: challenge, privateKey: privateKeyHex)
        XCTAssertEqual(sig, signature)
    }

    func testVerifyCryptoSignSignature() throws {
        let publicKeyData = try publicKeyHex.hexDecodedBytes()
        let isVerified = try verifyCryptoSignSignature(signature: signature + challenge, publicKey: publicKeyData)
        XCTAssertTrue(isVerified)
    }
}
