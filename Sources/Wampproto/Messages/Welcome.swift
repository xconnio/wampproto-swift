import Foundation

public protocol IWelcomeFields: Sendable {
    var sessionID: UInt64 { get }
    var roles: [String: any Sendable] { get }
    var authID: String { get }
    var authRole: String { get }
    var authMethod: String { get }
    var authExtra: [String: any Sendable] { get }
}

public struct WelcomeFields: IWelcomeFields {
    public let sessionID: UInt64
    public let roles: [String: any Sendable]
    public let authID: String
    public let authRole: String
    public let authMethod: String
    public let authExtra: [String: any Sendable]

    public init(sessionID: UInt64, roles: [String: any Sendable], authID: String, authRole: String, authMethod: String,
                authExtra: [String: any Sendable] = [:]) {
        self.sessionID = sessionID
        self.roles = roles
        self.authID = authID
        self.authRole = authRole
        self.authMethod = authMethod
        self.authExtra = authExtra
    }
}

public struct Welcome: Message {
    private var welcomeFields: IWelcomeFields

    public static let id: UInt64 = 2
    public static let text = "WELCOME"

    static let validationSpec = ValidationSpec(
        minLength: 3,
        maxLength: 3,
        message: Welcome.text,
        spec: [
            1: validateSessionID,
            2: validateDetails
        ]
    )

    public init(sessionID: UInt64, roles: [String: any Sendable], authID: String, authRole: String, authMethod: String,
                authExtra: [String: any Sendable]? = nil) {
        welcomeFields = WelcomeFields(sessionID: sessionID, roles: roles, authID: authID, authRole: authRole,
                                      authMethod: authMethod, authExtra: authExtra ?? [:])
    }

    public init(withFields fields: IWelcomeFields) {
        welcomeFields = fields
    }

    public var sessionID: UInt64 { welcomeFields.sessionID }
    public var roles: [String: any Sendable] { welcomeFields.roles }
    public var authID: String { welcomeFields.authID }
    public var authRole: String { welcomeFields.authRole }
    public var authMethod: String { welcomeFields.authMethod }
    public var authExtra: [String: any Sendable] { welcomeFields.authExtra }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        let details = fields.details!

        guard let roles = details["roles"] as? [String: any Sendable] else {
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

        let authExtra = details["authextra"] as? [String: any Sendable] ?? [:]

        return Welcome(sessionID: fields.sessionID!, roles: roles, authID: authID,
                       authRole: authRole, authMethod: authMethod, authExtra: authExtra)
    }

    public func marshal() -> [any Sendable] {
        var details: [String: any Sendable] = [:]
        details["roles"] = roles
        details["authid"] = authID
        details["authrole"] = authRole
        details["authmethod"] = authMethod
        details["authextra"] = authExtra

        return [Welcome.id, sessionID, details]
    }

    public var type: UInt64 {
        Welcome.id
    }
}
