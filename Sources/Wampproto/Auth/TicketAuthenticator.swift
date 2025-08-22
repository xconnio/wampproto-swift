import Foundation

public struct TicketAuthenticator: ClientAuthenticator {
    static let type = "ticket"

    public let authID: String
    public let authExtra: [String: any Sendable]
    public let authMethod: String = TicketAuthenticator.type
    private let ticket: String

    public init(authID: String, authExtra: [String: Any] = [:], ticket: String) {
        self.authID = authID
        self.authExtra = authExtra
        self.ticket = ticket
    }

    public func authenticate(challenge _: Challenge) -> Authenticate {
        Authenticate(signature: ticket, extra: [:])
    }
}
