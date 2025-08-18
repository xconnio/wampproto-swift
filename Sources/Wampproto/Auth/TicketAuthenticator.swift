import Foundation

public class TicketAuthenticator: ClientAuthenticator {
    static let type = "ticket"

    public let authID: String
    public let authExtra: [String: Any]
    public let authMethod: String = TicketAuthenticator.type
    private let ticket: String

    init(authID: String, authExtra: [String: Any] = [:], ticket: String) {
        self.authID = authID
        self.authExtra = authExtra
        self.ticket = ticket
    }

    public func authenticate(challenge _: Challenge) -> Authenticate {
        Authenticate(signature: ticket, extra: [:])
    }
}
