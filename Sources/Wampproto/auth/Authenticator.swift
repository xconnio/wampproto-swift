import Foundation

protocol ClientAuthenticator {
    var authMethod: String { get }
    var authID: String { get }
    var authExtra: [String: Any] { get }

    func authenticate(challenge: Challenge) throws -> Authenticate
}

enum AuthenticationError: Swift.Error {
    case notSupported
    case missingChallenge
    case authenticationFailed
}
