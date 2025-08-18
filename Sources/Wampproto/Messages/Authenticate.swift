import Foundation

public protocol IAuthenticateFields {
    var signature: String { get }
    var extra: [String: Any] { get }
}

public class AuthenticateFields: IAuthenticateFields {
    public let signature: String
    public let extra: [String: Any]

    public init(signature: String, extra: [String: Any]) {
        self.signature = signature
        self.extra = extra
    }
}

public class Authenticate: Message {
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

    init(signature: String, extra: [String: Any]) {
        authenticateFields = AuthenticateFields(signature: signature, extra: extra)
    }

    init(withFields authenticateFields: IAuthenticateFields) {
        self.authenticateFields = authenticateFields
    }

    var signature: String { authenticateFields.signature }
    var extra: [String: Any] { authenticateFields.extra }

    public static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Authenticate(signature: fields.signature!, extra: fields.extra!)
    }

    public func marshal() -> [Any] {
        [Authenticate.id, signature, extra]
    }

    public var type: Int64 {
        Authenticate.id
    }
}
