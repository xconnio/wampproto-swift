import Foundation

public protocol IHelloFields: Sendable {
    var realm: String { get }
    var roles: [String: any Sendable] { get }
    var authID: String { get }
    var authMethods: [String] { get }
    var authExtra: [String: any Sendable] { get }
}

public struct HelloFields: IHelloFields {
    public let realm: String
    public let roles: [String: any Sendable]
    public let authID: String
    public let authMethods: [String]
    public let authExtra: [String: any Sendable]

    public init(
        realm: String,
        roles: [String: any Sendable],
        authID: String,
        authMethods: [String],
        authExtra: [String: any Sendable] = [:]
    ) {
        self.realm = realm
        self.roles = roles
        self.authID = authID
        self.authMethods = authMethods
        self.authExtra = authExtra
    }
}

public struct Hello: Message {
    private var helloFields: IHelloFields

    public static let id: Int64 = 1
    public static let text = "HELLO"

    static let validationSpec = ValidationSpec(
        minLength: 3,
        maxLength: 3,
        message: Hello.text,
        spec: [
            1: validateRealm,
            2: validateDetails
        ]
    )

    public init(
        realm: String,
        roles: [String: any Sendable],
        authID: String,
        authMethods: [String],
        authExtra: [String: any Sendable]? = nil
    ) {
        helloFields = HelloFields(realm: realm, roles: roles, authID: authID, authMethods: authMethods,
                                  authExtra: authExtra ?? [:])
    }

    public init(withFields helloFields: IHelloFields) {
        self.helloFields = helloFields
    }

    public var realm: String { helloFields.realm }
    public var roles: [String: any Sendable] { helloFields.roles }
    public var authID: String { helloFields.authID }
    public var authMethods: [String] { helloFields.authMethods }
    public var authExtra: [String: any Sendable] { helloFields.authExtra }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        let roles = fields.details?["roles"] as? [String: any Sendable] ?? [:]

        let authID = fields.details?["authid"] as? String ?? ""
        let authMethods = fields.details?["authmethods"] as? [String] ?? []
        let authExtra = fields.details?["authextra"] as? [String: any Sendable] ?? [:]

        return Hello(realm: fields.realm!, roles: roles, authID: authID, authMethods: authMethods, authExtra: authExtra)
    }

    public func marshal() -> [any Sendable] {
        var details: [String: any Sendable] = [:]
        details["roles"] = roles
        details["authid"] = authID
        details["authmethods"] = authMethods
        details["authextra"] = authExtra

        return [Hello.id, realm, details]
    }

    public var type: Int64 {
        Hello.id
    }
}
