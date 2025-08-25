import Foundation

public protocol IRegisteredFields: Sendable {
    var requestID: Int64 { get }
    var registrationID: Int64 { get }
}

public struct RegisteredFields: IRegisteredFields {
    public let requestID: Int64
    public let registrationID: Int64

    public init(requestID: Int64, registrationID: Int64) {
        self.requestID = requestID
        self.registrationID = registrationID
    }
}

public struct Registered: Message {
    private var registeredFields: IRegisteredFields

    public static let id: Int64 = 65
    public static let text = "REGISTERED"

    static let validationSpec = ValidationSpec(
        minLength: 3,
        maxLength: 3,
        message: Registered.text,
        spec: [
            1: validateRequestID,
            2: validateRegistrationID
        ]
    )

    public init(requestID: Int64, registrationID: Int64) {
        registeredFields = RegisteredFields(requestID: requestID, registrationID: registrationID)
    }

    public init(withFields registeredFields: IRegisteredFields) {
        self.registeredFields = registeredFields
    }

    public var requestID: Int64 { registeredFields.requestID }
    public var registrationID: Int64 { registeredFields.registrationID }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Registered(requestID: fields.requestID!, registrationID: fields.registrationID!)
    }

    public func marshal() -> [any Sendable] {
        [Registered.id, requestID, registrationID]
    }

    public var type: Int64 {
        Registered.id
    }
}
