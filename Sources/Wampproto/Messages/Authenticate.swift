import Foundation

protocol IAuthenticateFields {
    var signature: String { get }
    var extra: [String: Any] { get }
}

class AuthenticateFields: IAuthenticateFields {
    let signature: String
    let extra: [String: Any]

    init(signature: String, extra: [String: Any]) {
        self.signature = signature
        self.extra = extra
    }
}

class Authenticate: Message {
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
        self.authenticateFields = AuthenticateFields(signature: signature, extra: extra)
    }

    init(withFields authenticateFields: IAuthenticateFields) {
        self.authenticateFields = authenticateFields
    }

    var signature: String { return authenticateFields.signature }
    var extra: [String: Any] { return authenticateFields.extra }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Authenticate(signature: fields.signature!, extra: fields.extra!)
    }

    func marshal() -> [Any] {
        return [Authenticate.id, signature, extra]
    }

    var type: Int64 {
        return Authenticate.id
    }
}
