import Foundation

public protocol IUnsubscribedFields: Sendable {
    var requestID: Int64 { get }
}

public struct UnsubscribedFields: IUnsubscribedFields {
    public let requestID: Int64
}

public struct Unsubscribed: Message {
    private var unsubscribedFields: IUnsubscribedFields

    public static let id: Int64 = 35
    public static let text = "UNSUBSCRIBED"

    static let validationSpec = ValidationSpec(
        minLength: 2,
        maxLength: 2,
        message: Unsubscribed.text,
        spec: [
            1: validateRequestID
        ]
    )

    public init(requestID: Int64) {
        unsubscribedFields = UnsubscribedFields(requestID: requestID)
    }

    public init(withFields unsubscribedFields: IUnsubscribedFields) {
        self.unsubscribedFields = unsubscribedFields
    }

    public var requestID: Int64 { unsubscribedFields.requestID }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Unsubscribed(requestID: fields.requestID!)
    }

    public func marshal() -> [any Sendable] {
        [Unsubscribed.id, requestID]
    }

    public var type: Int64 {
        Unsubscribed.id
    }
}
