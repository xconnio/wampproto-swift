import Foundation

public protocol IRegisteredFields: Sendable {
    var requestID: UInt64 { get }
    var registrationID: UInt64 { get }
}

public struct RegisteredFields: IRegisteredFields {
    public let requestID: UInt64
    public let registrationID: UInt64

    public init(requestID: UInt64, registrationID: UInt64) {
        self.requestID = requestID
        self.registrationID = registrationID
    }
}

public struct Registered: Message {
    private var registeredFields: IRegisteredFields

    public static let id: UInt64 = 65
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

    public init(requestID: UInt64, registrationID: UInt64) {
        registeredFields = RegisteredFields(requestID: requestID, registrationID: registrationID)
    }

    public init(withFields registeredFields: IRegisteredFields) {
        self.registeredFields = registeredFields
    }

    public var requestID: UInt64 { registeredFields.requestID }
    public var registrationID: UInt64 { registeredFields.registrationID }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Registered(requestID: fields.requestID!, registrationID: fields.registrationID!)
    }

    public func marshal() -> [any Sendable] {
        [Registered.id, requestID, registrationID]
    }

    public var type: UInt64 {
        Registered.id
    }
}
