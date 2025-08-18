import Foundation

protocol IWelcomeFields {
    var sessionID: Int64 { get }
    var roles: [String: Any] { get }
    var authID: String { get }
    var authRole: String { get }
    var authMethod: String { get }
    var authExtra: [String: Any] { get }
}

class WelcomeFields: IWelcomeFields {
    let sessionID: Int64
    let roles: [String: Any]
    let authID: String
    let authRole: String
    let authMethod: String
    let authExtra: [String: Any]

    init(sessionID: Int64, roles: [String: Any], authID: String, authRole: String, authMethod: String,
         authExtra: [String: Any] = [:]) {
        self.sessionID = sessionID
        self.roles = roles
        self.authID = authID
        self.authRole = authRole
        self.authMethod = authMethod
        self.authExtra = authExtra
    }
}

class Welcome: Message {
    private var welcomeFields: IWelcomeFields

    static let id: Int64 = 2
    static let text = "WELCOME"

    static let validationSpec = ValidationSpec(
        minLength: 3,
        maxLength: 3,
        message: Welcome.text,
        spec: [
            1: validateSessionID,
            2: validateDetails
        ]
    )

    init(sessionID: Int64, roles: [String: Any], authID: String, authRole: String, authMethod: String,
         authExtra: [String: Any]? = nil) {
        welcomeFields = WelcomeFields(sessionID: sessionID, roles: roles, authID: authID, authRole: authRole,
                                      authMethod: authMethod, authExtra: authExtra ?? [:])
    }

    init(withFields fields: IWelcomeFields) {
        welcomeFields = fields
    }

    var sessionID: Int64 { welcomeFields.sessionID }
    var roles: [String: Any] { welcomeFields.roles }
    var authID: String { welcomeFields.authID }
    var authRole: String { welcomeFields.authRole }
    var authMethod: String { welcomeFields.authMethod }
    var authExtra: [String: Any] { welcomeFields.authExtra }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        let details = fields.details!

        guard let roles = details["roles"] as? [String: Any] else {
            throw ValidationError.missingField("roles")
        }

        guard let authID = details["authid"] as? String else {
            throw ValidationError.missingField("authid")
        }

        guard let authRole = details["authrole"] as? String else {
            throw ValidationError.missingField("authrole")
        }

        guard let authMethod = details["authmethod"] as? String else {
            throw ValidationError.missingField("authmethod")
        }

        let authExtra = details["authextra"] as? [String: Any] ?? [:]

        return Welcome(sessionID: fields.sessionID!, roles: roles, authID: authID,
                       authRole: authRole, authMethod: authMethod, authExtra: authExtra)
    }

    func marshal() -> [Any] {
        var details: [String: Any] = [:]
        details["roles"] = roles
        details["authid"] = authID
        details["authrole"] = authRole
        details["authmethod"] = authMethod
        details["authextra"] = authExtra

        return [Welcome.id, sessionID, details]
    }

    var type: Int64 {
        Welcome.id
    }
}
