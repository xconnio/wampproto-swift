import Foundation

public protocol IRegisterFields: Sendable {
    var requestID: Int64 { get }
    var uri: String { get }
    var options: [String: any Sendable] { get }
}

public struct RegisterFields: IRegisterFields {
    public let requestID: Int64
    public let uri: String
    public let options: [String: any Sendable]

    public init(requestID: Int64, uri: String, options: [String: any Sendable] = [:]) {
        self.requestID = requestID
        self.uri = uri
        self.options = options
    }
}

public struct Register: Message {
    private var registerFields: IRegisterFields

    static let id: Int64 = 64
    static let text = "REGISTER"

    static let validationSpec = ValidationSpec(
        minLength: 4,
        maxLength: 4,
        message: Register.text,
        spec: [
            1: validateRequestID,
            2: validateOptions,
            3: validateURI
        ]
    )

    public init(requestID: Int64, uri: String, options: [String: any Sendable] = [:]) {
        registerFields = RegisterFields(requestID: requestID, uri: uri, options: options)
    }

    public init(withFields registerFields: IRegisterFields) {
        self.registerFields = registerFields
    }

    public var requestID: Int64 { registerFields.requestID }
    public var uri: String { registerFields.uri }
    public var options: [String: any Sendable] { registerFields.options }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Register(requestID: fields.requestID!, uri: fields.uri!, options: fields.options ?? [:])
    }

    public func marshal() -> [any Sendable] {
        [Register.id, requestID, options, uri]
    }

    public var type: Int64 {
        Register.id
    }
}
