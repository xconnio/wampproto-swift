import Foundation

class AnonymousAuthenticator: ClientAuthenticator {
    static let type = "anonymous"

    let authID: String
    let authExtra: [String: Any]
    let authMethod: String = AnonymousAuthenticator.type

    init(authID: String, authExtra: [String: Any] = [:]) {
        self.authID = authID
        self.authExtra = authExtra
    }

    func authenticate(challenge: Challenge) throws -> Authenticate {
        throw AuthenticationError.notSupported
    }
}
