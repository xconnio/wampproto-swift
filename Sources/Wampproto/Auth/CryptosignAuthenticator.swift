import Foundation
import Sodium

public struct CryptoSignAuthenticator: ClientAuthenticator {
    static let type = "cryptosign"

    public let authID: String
    private let privateKey: String
    public var authExtra: [String: any Sendable]

    public var authMethod: String {
        CryptoSignAuthenticator.type
    }

    public init(authID: String, privateKey: String, authExtra: [String: Any] = [:]) throws {
        self.authID = authID
        self.privateKey = privateKey
        var extra = authExtra

        if extra["pubkey"] == nil {
            let publicKeyBytes = try getPublicKey(privateKey: privateKey)
            extra["pubkey"] = publicKeyBytes.hexEncodedString()
        }

        self.authExtra = extra
    }

    public func authenticate(challenge: Challenge) throws -> Authenticate {
        guard let challengeHex = challenge.extra["challenge"] as? String else {
            throw AuthenticationError.missingChallenge
        }

        let signed = try signCryptoSignChallenge(challenge: challengeHex, privateKey: privateKey)

        return Authenticate(signature: signed + challengeHex, extra: [:])
    }
}

enum CryptosignError: Swift.Error {
    case keyGenerationFailed
    case invalidHexString
    case signingFailed
}

let sodium = Sodium()

func generateCryptoSignChallenge() -> String {
    let bytes = sodium.randomBytes.buf(length: 32)!
    return bytes.hexEncodedString()
}

func generateCryptoSignKeyPair() throws -> (publicKey: String, privateKey: String) {
    guard let keyPair = sodium.sign.keyPair() else {
        throw CryptosignError.keyGenerationFailed
    }
    return (keyPair.publicKey.hexEncodedString(), keyPair.secretKey.hexEncodedString())
}

func getPublicKey(privateKey: String) throws -> [UInt8] {
    let privateKeyBytes = try privateKey.hexDecodedBytes()

    switch privateKeyBytes.count {
    case 32:
        guard let keyPair = sodium.sign.keyPair(seed: privateKeyBytes) else {
            throw CryptosignError.keyGenerationFailed
        }
        return keyPair.publicKey

    case 64:
        return Array(privateKeyBytes.suffix(32))

    default:
        throw CryptosignError.invalidHexString
    }
}

func signCryptoSignChallenge(challenge: String, privateKey: String) throws -> String {
    var privateKeyBytes = try privateKey.hexDecodedBytes()
    let challengeBytes = try challenge.hexDecodedBytes()

    if privateKeyBytes.count == 32 {
        let publicKeyBytes = try getPublicKey(privateKey: privateKey)
        privateKeyBytes += publicKeyBytes
    }

    guard let signature = sodium.sign.signature(message: challengeBytes, secretKey: privateKeyBytes) else {
        throw CryptosignError.signingFailed
    }

    return signature.hexEncodedString()
}

func verifyCryptoSignSignature(signature: String, publicKey: [UInt8]) throws -> Bool {
    guard signature.count >= 128 else {
        throw AuthenticationError.authenticationFailed
    }

    let sigData = try String(signature.prefix(128)).hexDecodedBytes()
    let challengeData = try String(signature.dropFirst(128)).hexDecodedBytes()

    return sodium.sign.verify(message: challengeData, publicKey: publicKey, signature: sigData)
}

extension [UInt8] {
    func hexEncodedString() -> String {
        map { String(format: "%02x", $0) }.joined()
    }
}

extension String {
    func hexDecodedBytes() throws -> [UInt8] {
        guard count % 2 == 0 else { throw CryptosignError.invalidHexString }

        return stride(from: 0, to: count, by: 2).compactMap { hexIndex in
            let start = index(startIndex, offsetBy: hexIndex)
            let end = index(start, offsetBy: 2)
            return UInt8(self[start ..< end], radix: 16)
        }
    }
}
