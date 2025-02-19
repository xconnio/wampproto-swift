import Foundation

class TicketAuthenticator: ClientAuthenticator {
    static let type = "ticket"

    let authID: String
    let authExtra: [String: Any]
    let authMethod: String = TicketAuthenticator.type
    private let ticket: String

    init(authID: String, authExtra: [String: Any] = [:], ticket: String) {
        self.authID = authID
        self.authExtra = authExtra
        self.ticket = ticket
    }

    func authenticate(challenge: Challenge) -> Authenticate {
        return Authenticate(signature: ticket, extra: [:])
    }
}
