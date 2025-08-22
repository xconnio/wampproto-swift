import Foundation

public struct SessionDetails: Sendable {
    public let sessionID: Int64
    public let realm: String
    public let authID: String
    public let authRole: String

    public init(sessionID: Int64, realm: String, authID: String, authRole: String) {
        self.sessionID = sessionID
        self.realm = realm
        self.authID = authID
        self.authRole = authRole
    }
}

let clientRoles: [String: [String: [String: Any]]] = [
    "caller": ["features": [:]],
    "callee": ["features": [:]],
    "publisher": ["features": [:]],
    "subscriber": ["features": [:]]
]

public struct Joiner {
    private let realm: String
    private let serializer: Serializer
    private let authenticator: ClientAuthenticator

    enum State {
        case none, helloSent, authenticateSent, joined
    }

    private var state = State.none
    private var sessionDetails: SessionDetails?

    public init(realm: String, serializer: Serializer = JSONSerializer(),
                authenticator: ClientAuthenticator = AnonymousAuthenticator(authID: "")) {
        self.realm = realm
        self.serializer = serializer
        self.authenticator = authenticator
    }

    public mutating func sendHello() throws -> SerializedMessage {
        let hello = Hello(realm: realm, roles: clientRoles, authID: authenticator.authID,
                          authMethods: [authenticator.authMethod], authExtra: authenticator.authExtra)
        state = .helloSent
        return try serializer.serialize(message: hello)
    }

    public mutating func receive(data: SerializedMessage) throws -> SerializedMessage? {
        let receivedMessage = try serializer.deserialize(data: data)
        if let toSend = try receiveMessage(msg: receivedMessage) {
            if let authenticate = toSend as? Authenticate {
                return try serializer.serialize(message: authenticate)
            }
        }
        return nil
    }

    private mutating func receiveMessage(msg: Message) throws -> Message? {
        if let welcome = msg as? Welcome {
            if state != .helloSent, state != .authenticateSent {
                throw ProtocolError(message: "received welcome when it was not expected")
            }
            sessionDetails = SessionDetails(sessionID: welcome.sessionID, realm: realm,
                                            authID: welcome.authID, authRole: welcome.authRole)
            state = .joined
            return nil
        } else if let challenge = msg as? Challenge {
            if state != .helloSent {
                throw ProtocolError(message: "received challenge when it was not expected")
            }
            let authenticate = try authenticator.authenticate(challenge: challenge)
            state = .authenticateSent
            return authenticate
        } else if let abort = msg as? Abort {
            throw ApplicationError(message: abort.reason, args: abort.args, kwargs: abort.kwargs)
        } else {
            throw ProtocolError(message: "received unknown message and session is not established yet")
        }
    }

    public func getSessionDetails() throws -> SessionDetails {
        if let session = sessionDetails {
            return session
        } else {
            throw SessionNotReady(message: "session is not set up yet")
        }
    }
}
