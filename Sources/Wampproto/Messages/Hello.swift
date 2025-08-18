import Foundation

protocol IHelloFields {
    var realm: String { get }
    var roles: [String: Any] { get }
    var authID: String { get }
    var authMethods: [String] { get }
    var authExtra: [String: Any] { get }
}

class HelloFields: IHelloFields {
    let realm: String
    let roles: [String: Any]
    let authID: String
    let authMethods: [String]
    let authExtra: [String: Any]

    init(realm: String, roles: [String: Any], authID: String, authMethods: [String], authExtra: [String: Any] = [:]) {
        self.realm = realm
        self.roles = roles
        self.authID = authID
        self.authMethods = authMethods
        self.authExtra = authExtra
    }
}

class Hello: Message {
    private var helloFields: IHelloFields

    static let id: Int64 = 1
    static let text = "HELLO"

    static let validationSpec = ValidationSpec(
        minLength: 3,
        maxLength: 3,
        message: Hello.text,
        spec: [
            1: validateRealm,
            2: validateDetails
        ]
    )

    init(realm: String, roles: [String: Any], authID: String, authMethods: [String], authExtra: [String: Any]? = nil) {
        helloFields = HelloFields(realm: realm, roles: roles, authID: authID, authMethods: authMethods,
                                  authExtra: authExtra ?? [:])
    }

    init(withFields helloFields: IHelloFields) {
        self.helloFields = helloFields
    }

    var realm: String { helloFields.realm }
    var roles: [String: Any] { helloFields.roles }
    var authID: String { helloFields.authID }
    var authMethods: [String] { helloFields.authMethods }
    var authExtra: [String: Any] { helloFields.authExtra }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        let roles = fields.details?["roles"] as? [String: Any] ?? [:]

        let authID = fields.details?["authid"] as? String ?? ""
        let authMethods = fields.details?["authmethods"] as? [String] ?? []
        let authExtra = fields.details?["authextra"] as? [String: Any] ?? [:]

        return Hello(realm: fields.realm!, roles: roles, authID: authID, authMethods: authMethods, authExtra: authExtra)
    }

    func marshal() -> [Any] {
        var details: [String: Any] = [:]
        details["roles"] = roles
        details["authid"] = authID
        details["authmethods"] = authMethods
        details["authextra"] = authExtra

        return [Hello.id, realm, details]
    }

    var type: Int64 {
        Hello.id
    }
}
