import Foundation

public class AnonymousAuthenticator: ClientAuthenticator {
    static let type = "anonymous"

    public let authID: String
    public let authExtra: [String: Any]
    public let authMethod: String = AnonymousAuthenticator.type

    public init(authID: String, authExtra: [String: Any] = [:]) {
        self.authID = authID
        self.authExtra = authExtra
    }

    public func authenticate(challenge _: Challenge) throws -> Authenticate {
        throw AuthenticationError.notSupported
    }
}
