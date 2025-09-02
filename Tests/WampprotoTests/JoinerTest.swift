@testable import Wampproto
import XCTest

extension SerializedMessage {
    func webSocketMessage() -> URLSessionWebSocketTask.Message {
        switch self {
        case let .string(string):
            .string(string)
        case let .data(data):
            .data(data)
        }
    }
}

extension URLSessionWebSocketTask.Message {
    func serializedMessage() -> SerializedMessage {
        switch self {
        case let .string(string):
            return .string(string)
        case let .data(data):
            return .data(data)
        @unknown default:
            fatalError()
        }
    }
}

class JoinerTest: XCTestCase {
    private let testRealm = "test.realm"
    private let testSessionID: UInt64 = 12345
    private let testAuthID = "test_authid"
    private let testAuthRole = "test_role"
    private let testAuthMethod = "anonymous"

    func testSendHello() throws {
        var joiner = Joiner(realm: testRealm)
        let serializedHello = try joiner.sendHello()

        let deserializedHello = try JSONSerializer().deserialize(data: serializedHello)
        XCTAssertTrue(deserializedHello is Hello)

        let helloMessage = deserializedHello as? Hello
        XCTAssertEqual(helloMessage!.realm, testRealm)
        XCTAssertEqual(helloMessage!.authMethods.first, testAuthMethod)
        XCTAssertEqual(helloMessage!.authID, "")
        XCTAssertEqual(helloMessage!.roles as NSDictionary, clientRoles as NSDictionary)
    }

    func testReceiveWelcomeMessage() throws {
        var joiner = Joiner(realm: testRealm)
        _ = try joiner.sendHello()

        let welcomeMessage = Welcome(sessionID: testSessionID, roles: clientRoles, authID: testAuthID,
                                     authRole: testAuthRole, authMethod: testAuthMethod)
        let serializedWelcome = try JSONSerializer().serialize(message: welcomeMessage)

        let result = try joiner.receive(data: serializedWelcome)
        XCTAssertNil(result) // No further message expected after Welcome

        let sessionDetails = try joiner.getSessionDetails()
        XCTAssertEqual(sessionDetails.sessionID, testSessionID)
        XCTAssertEqual(sessionDetails.realm, testRealm)
        XCTAssertEqual(sessionDetails.authID, testAuthID)
        XCTAssertEqual(sessionDetails.authRole, testAuthRole)
    }

    func testReceiveChallengeMessage() throws {
        var joiner = Joiner(realm: testRealm, authenticator: TicketAuthenticator(authID: testAuthID, ticket: "test"))
        _ = try joiner.sendHello()

        let challengeMessage = Challenge(authMethod: "cryptosign", extra: ["challenge": "123456"])
        let serializedChallenge = try JSONSerializer().serialize(message: challengeMessage)

        let result = try joiner.receive(data: serializedChallenge)
        XCTAssertNotNil(result) // Authenticate message expected after Challenge

        let deserializedResult = try JSONSerializer().deserialize(data: result!)
        XCTAssertTrue(deserializedResult is Authenticate)

        XCTAssertThrowsError(try joiner.getSessionDetails()) { error in
            XCTAssertTrue(error is SessionNotReady)
        }

        let welcomeMessage = Welcome(sessionID: testSessionID, roles: clientRoles, authID: testAuthID,
                                     authRole: testAuthRole, authMethod: testAuthMethod)
        let serializedWelcome = try JSONSerializer().serialize(message: welcomeMessage)

        let finalResult = try joiner.receive(data: serializedWelcome)
        XCTAssertNil(finalResult) // No further message expected after Welcome

        let sessionDetails = try joiner.getSessionDetails()
        XCTAssertEqual(sessionDetails.sessionID, testSessionID)
        XCTAssertEqual(sessionDetails.realm, testRealm)
        XCTAssertEqual(sessionDetails.authID, testAuthID)
        XCTAssertEqual(sessionDetails.authRole, testAuthRole)
    }

    func testReceiveAbortMessage() throws {
        var joiner = Joiner(realm: testRealm)
        _ = try joiner.sendHello()

        let abortMessage = Abort(details: [:], reason: "some.message")
        let serializedAbort = try JSONSerializer().serialize(message: abortMessage)

        XCTAssertThrowsError(try joiner.receive(data: serializedAbort)) { error in
            XCTAssertTrue(error is ApplicationError)
        }
    }

    private func getSubProtocol(serializer: Serializer) throws -> [String] {
        switch serializer {
        case is JSONSerializer: return ["wamp.2.json"]
        case is CBORSerializer: return ["wamp.2.cbor"]
        case is MsgPackSerializer: return ["wamp.2.msgpack"]
        default: throw URLError(.unsupportedURL)
        }
    }

    private func send(data: URLSessionWebSocketTask.Message, webSocketTask: URLSessionWebSocketTask) async throws {
        switch data {
        case let .string(text):
            try await webSocketTask.send(.string(text))
        case let .data(binary):
            try await webSocketTask.send(.data(binary))
        default:
            throw URLError(.badServerResponse)
        }
    }

    private func receive(webSocketTask: URLSessionWebSocketTask) async throws -> URLSessionWebSocketTask.Message {
        switch try await webSocketTask.receive() {
        case let .string(text):
            return .string(text)
        case let .data(data):
            return .data(data)
        @unknown default:
            throw URLError(.badServerResponse)
        }
    }

    func join(joiner: inout Joiner, serializer: Serializer) async throws -> Message {
        let url = URL(string: "ws://localhost:8080/ws")!
        let protocols = try getSubProtocol(serializer: serializer)

        let webSocketTask = URLSession.shared.webSocketTask(with: url, protocols: protocols)
        webSocketTask.resume()

        try await send(data: joiner.sendHello().webSocketMessage(), webSocketTask: webSocketTask)

        let receivedData = try await receive(webSocketTask: webSocketTask)
        guard let authenticate = try joiner.receive(data: receivedData.serializedMessage()) else {
            return try serializer.deserialize(data: receivedData.serializedMessage())
        }

        try await send(data: authenticate.webSocketMessage(), webSocketTask: webSocketTask)

        return try await serializer.deserialize(data: receive(webSocketTask: webSocketTask).serializedMessage())
    }

    func testAnonymous() async throws {
        let jsonSerializer = JSONSerializer()
        var joiner = Joiner(realm: "realm1", serializer: jsonSerializer)
        let welcome = try await join(joiner: &joiner, serializer: jsonSerializer)
        XCTAssertTrue(welcome is Welcome)
    }

    func testTicket() async throws {
        let cborSerializer = CBORSerializer()
        var joiner = Joiner(realm: "realm1", serializer: cborSerializer,
                            authenticator: TicketAuthenticator(authID: "ticket-user", ticket: "ticket-pass"))
        let welcome = try await join(joiner: &joiner, serializer: cborSerializer)
        XCTAssertTrue(welcome is Welcome)
    }

    func testCRA() async throws {
        let msgPackSerializer = MsgPackSerializer()
        var joiner = Joiner(realm: "realm1", serializer: msgPackSerializer,
                            authenticator: CRAAuthenticator(authID: "wamp-cra-user", secret: "cra-secret"))
        let welcome = try await join(joiner: &joiner, serializer: msgPackSerializer)
        XCTAssertTrue(welcome is Welcome)
    }

    func testCryptosign() async throws {
        let jsonSerializer = JSONSerializer()
        let cryptosignAuthenticator = try CryptoSignAuthenticator(
            authID: "cryptosign-user",
            privateKey: "150085398329d255ad69e82bf47ced397bcec5b8fbeecd28a80edbbd85b49081"
        )
        var joiner = Joiner(realm: "realm1", serializer: jsonSerializer, authenticator: cryptosignAuthenticator)
        let welcome = try await join(joiner: &joiner, serializer: jsonSerializer)
        XCTAssertTrue(welcome is Welcome)
    }
}
