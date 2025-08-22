import Foundation

public protocol IUnregisteredFields: Sendable {
    var requestID: Int64 { get }
}

public struct UnregisteredFields: IUnregisteredFields {
    public let requestID: Int64

    public init(requestID: Int64) {
        self.requestID = requestID
    }
}

public struct Unregistered: Message {
    private var unregisteredFields: IUnregisteredFields

    static let id: Int64 = 67
    static let text = "UNREGISTERED"

    static let validationSpec = ValidationSpec(
        minLength: 2,
        maxLength: 2,
        message: Unregistered.text,
        spec: [
            1: validateRequestID
        ]
    )

    public init(requestID: Int64) {
        unregisteredFields = UnregisteredFields(requestID: requestID)
    }

    public init(withFields unregisteredFields: IUnregisteredFields) {
        self.unregisteredFields = unregisteredFields
    }

    public var requestID: Int64 { unregisteredFields.requestID }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Unregistered(requestID: fields.requestID!)
    }

    public func marshal() -> [any Sendable] {
        [Unregistered.id, requestID]
    }

    public var type: Int64 {
        Unregistered.id
    }
}
