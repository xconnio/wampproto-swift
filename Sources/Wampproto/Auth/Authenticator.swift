import Foundation

public protocol ClientAuthenticator: Sendable {
    var authMethod: String { get }
    var authID: String { get }
    var authExtra: [String: any Sendable] { get }

    func authenticate(challenge: Challenge) throws -> Authenticate
}

public enum AuthenticationError: Swift.Error {
    case notSupported
    case missingChallenge
    case authenticationFailed
}
