import Foundation

public protocol IUnsubscribeFields: Sendable {
    var requestID: UInt64 { get }
    var subscriptionID: UInt64 { get }
}

public struct UnsubscribeFields: IUnsubscribeFields {
    public let requestID: UInt64
    public let subscriptionID: UInt64

    public init(requestID: UInt64, subscriptionID: UInt64) {
        self.requestID = requestID
        self.subscriptionID = subscriptionID
    }
}

public struct Unsubscribe: Message {
    private var unsubscribeFields: IUnsubscribeFields

    public static let id: UInt64 = 34
    public static let text = "UNSUBSCRIBE"

    static let validationSpec = ValidationSpec(
        minLength: 3,
        maxLength: 3,
        message: Unsubscribe.text,
        spec: [
            1: validateRequestID,
            2: validateSubscriptionID
        ]
    )

    public init(requestID: UInt64, subscriptionID: UInt64) {
        unsubscribeFields = UnsubscribeFields(
            requestID: requestID,
            subscriptionID: subscriptionID
        )
    }

    public init(withFields unsubscribeFields: IUnsubscribeFields) {
        self.unsubscribeFields = unsubscribeFields
    }

    public var requestID: UInt64 { unsubscribeFields.requestID }
    public var subscriptionID: UInt64 { unsubscribeFields.subscriptionID }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Unsubscribe(requestID: fields.requestID!, subscriptionID: fields.subscriptionID!)
    }

    public func marshal() -> [any Sendable] {
        [Unsubscribe.id, requestID, subscriptionID]
    }

    public var type: UInt64 {
        Unsubscribe.id
    }
}
