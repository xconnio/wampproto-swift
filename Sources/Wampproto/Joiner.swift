import Foundation

class SessionDetails {
    let sessionID: Int64
    let realm: String
    let authID: String
    let authRole: String

    init(sessionID: Int64, realm: String, authID: String, authRole: String) {
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

class Joiner {
    private let realm: String
    private let serializer: Serializer
    private let authenticator: ClientAuthenticator

    private let stateNone = 0
    private let stateHelloSent = 1
    private let stateAuthenticateSent = 2
    private let stateJoined = 3

    private var state = 0
    private var sessionDetails: SessionDetails?

    init(realm: String, serializer: Serializer = JSONSerializer(),
         authenticator: ClientAuthenticator = AnonymousAuthenticator(authID: "")) {
        self.realm = realm
        self.serializer = serializer
        self.authenticator = authenticator
    }

    func sendHello() throws -> Any {
        let hello = Hello(realm: realm, roles: clientRoles, authID: authenticator.authID,
                          authMethods: [authenticator.authMethod], authExtra: authenticator.authExtra)
        state = stateHelloSent
        return try serializer.serialize(message: hello)
    }

    func receive(data: Any) throws -> Any? {
        let receivedMessage = try serializer.deserialize(data: data)
        if let toSend = try receiveMessage(msg: receivedMessage) {
            if let authenticate = toSend as? Authenticate {
                return try serializer.serialize(message: authenticate)
            }
        }
        return nil
    }

    private func receiveMessage(msg: Message) throws -> Message? {
        if let welcome = msg as? Welcome {
            if state != stateHelloSent && state != stateAuthenticateSent {
                throw ProtocolError(message: "received welcome when it was not expected")
            }
            sessionDetails = SessionDetails(sessionID: welcome.sessionID, realm: realm,
                                            authID: welcome.authID, authRole: welcome.authRole)
            state = stateJoined
            return nil
        } else if let challenge = msg as? Challenge {
            if state != stateHelloSent {
                throw ProtocolError(message: "received challenge when it was not expected")
            }
            let authenticate = try authenticator.authenticate(challenge: challenge)
            state = stateAuthenticateSent
            return authenticate
        } else if let abort = msg as? Abort {
            throw ApplicationError(message: abort.reason, args: abort.args, kwargs: abort.kwargs)
        } else {
            throw ProtocolError(message: "received unknown message and session is not established yet")
        }
    }

    func getSessionDetails() throws -> SessionDetails {
        if let session = sessionDetails {
            return session
        } else {
            throw SessionNotReady(message: "session is not set up yet")
        }
    }
}
