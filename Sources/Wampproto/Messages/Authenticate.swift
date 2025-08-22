import Foundation

public protocol IAuthenticateFields: Sendable {
    var signature: String { get }
    var extra: [String: any Sendable] { get }
}

public struct AuthenticateFields: IAuthenticateFields {
    public let signature: String
    public let extra: [String: any Sendable]

    public init(signature: String, extra: [String: any Sendable]) {
        self.signature = signature
        self.extra = extra
    }
}

public struct Authenticate: Message {
    private var authenticateFields: IAuthenticateFields

    static let id: Int64 = 5
    static let text = "AUTHENTICATE"

    static let validationSpec = ValidationSpec(
        minLength: 3,
        maxLength: 3,
        message: Authenticate.text,
        spec: [
            1: validateSignature,
            2: validateExtra
        ]
    )

    public init(signature: String, extra: [String: any Sendable]) {
        authenticateFields = AuthenticateFields(signature: signature, extra: extra)
    }

    public init(withFields authenticateFields: IAuthenticateFields) {
        self.authenticateFields = authenticateFields
    }

    var signature: String { authenticateFields.signature }
    var extra: [String: any Sendable] { authenticateFields.extra }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Authenticate(signature: fields.signature!, extra: fields.extra!)
    }

    public func marshal() -> [any Sendable] {
        [Authenticate.id, signature, extra]
    }

    public var type: Int64 {
        Authenticate.id
    }
}
