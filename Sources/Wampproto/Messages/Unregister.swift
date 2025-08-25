import Foundation

public protocol IUnregisterFields: Sendable {
    var requestID: Int64 { get }
    var registrationID: Int64 { get }
}

public struct UnregisterFields: IUnregisterFields {
    public let requestID: Int64
    public let registrationID: Int64

    public init(requestID: Int64, registrationID: Int64) {
        self.requestID = requestID
        self.registrationID = registrationID
    }
}

public struct Unregister: Message {
    private var unregisterFields: IUnregisterFields

    public static let id: Int64 = 66
    public static let text = "UNREGISTER"

    static let validationSpec = ValidationSpec(
        minLength: 3,
        maxLength: 3,
        message: Unregister.text,
        spec: [
            1: validateRequestID,
            2: validateRegistrationID
        ]
    )

    public init(requestID: Int64, registrationID: Int64) {
        unregisterFields = UnregisterFields(requestID: requestID, registrationID: registrationID)
    }

    public init(withFields unregisterFields: IUnregisterFields) {
        self.unregisterFields = unregisterFields
    }

    public var requestID: Int64 { unregisterFields.requestID }
    public var registrationID: Int64 { unregisterFields.registrationID }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Unregister(requestID: fields.requestID!, registrationID: fields.registrationID!)
    }

    public func marshal() -> [any Sendable] {
        [Unregister.id, requestID, registrationID]
    }

    public var type: Int64 {
        Unregister.id
    }
}
