import CommonCrypto
import Foundation

public enum CRAAuthenticatorError: Swift.Error {
    case missingIterations
    case missingKeyLength
    case invalidSecret
    case invalidSalt
}

public struct CRAAuthenticator: ClientAuthenticator {
    static let type = "wampcra"
    static let defaultIteration = 1000
    static let defaultKeyLen = 256

    public let authID: String
    public let authExtra: [String: any Sendable]
    private let secret: String

    public var authMethod: String {
        CRAAuthenticator.type
    }

    public init(authID: String, authExtra: [String: Any] = [:], secret: String) {
        self.authID = authID
        self.authExtra = authExtra
        self.secret = secret
    }

    public func authenticate(challenge: Challenge) throws -> Authenticate {
        guard let challengeHex = challenge.extra["challenge"] as? String else {
            throw AuthenticationError.missingChallenge
        }

        guard var rawSecret = secret.data(using: .utf8) else {
            throw CRAAuthenticatorError.invalidSecret
        }

        let salt = challenge.extra["salt"] as? String

        if let salt, !salt.isEmpty {
            guard let iterations = challenge.extra["iterations"] as? Int else {
                throw CRAAuthenticatorError.missingIterations
            }
            guard let keylen = challenge.extra["keylen"] as? Int else {
                throw CRAAuthenticatorError.missingKeyLength
            }

            rawSecret = try deriveCRAKey(salt: salt, secret: secret, iterations: iterations, keyLength: keylen)
        }

        let signed = signWampCRAChallenge(challenge: challengeHex, key: rawSecret)
        return Authenticate(signature: signed, extra: [:])
    }
}

func deriveCRAKey(salt: String, secret: String, iterations: Int, keyLength: Int) throws -> Data {
    guard let saltData = salt.data(using: .utf8) else {
        throw CRAAuthenticatorError.invalidSalt
    }

    let effectiveIterations = iterations == 0 ? CRAAuthenticator.defaultIteration : iterations
    let effectiveKeyLength = keyLength == 0 ? CRAAuthenticator.defaultKeyLen : keyLength

    var derivedKey = [UInt8](repeating: 0, count: effectiveKeyLength)

    CCKeyDerivationPBKDF(
        CCPBKDFAlgorithm(kCCPBKDF2),
        secret, secret.utf8.count,
        [UInt8](saltData), saltData.count,
        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
        UInt32(effectiveIterations),
        &derivedKey,
        effectiveKeyLength
    )

    return Data(derivedKey).base64EncodedData()
}

func signWampCRAChallenge(challenge: String, key: Data) -> String {
    let keyBytes = [UInt8](key)
    let challengeBytes = [UInt8](challenge.utf8)

    var hmac = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))

    CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyBytes, keyBytes.count, challengeBytes, challengeBytes.count, &hmac)

    return Data(hmac).base64EncodedString()
}

func verifyWampCRASignature(signature: String, challenge: String, key: Data) -> Bool {
    let localSignature = signWampCRAChallenge(challenge: challenge, key: key)
    return signature == localSignature
}

func utcNow() -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.string(from: Date())
}

func generateRandomBytes(count: Int) -> Data {
    var bytes = [UInt8](repeating: 0, count: count)
    _ = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
    return Data(bytes)
}

func generateWAMPCRAChallenge(sessionID: Int, authID: String, authRole: String, provider: String) -> String? {
    let nonceRaw = generateRandomBytes(count: 16)
    let nonce = nonceRaw.map { String(format: "%02x", $0) }.joined()

    let data: [String: Any] = [
        "nonce": nonce,
        "authprovider": provider,
        "authid": authID,
        "authrole": authRole,
        "authmethod": CRAAuthenticator.type,
        "session": sessionID,
        "timestamp": utcNow()
    ]

    if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []),
       let jsonString = String(data: jsonData, encoding: .utf8) {
        return jsonString
    }
    return nil
}
