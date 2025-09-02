import Foundation

public protocol ISubscribedFields: Sendable {
    var requestID: UInt64 { get }
    var subscriptionID: UInt64 { get }
}

public struct SubscribedFields: ISubscribedFields {
    public let requestID: UInt64
    public let subscriptionID: UInt64

    public init(requestID: UInt64, subscriptionID: UInt64) {
        self.requestID = requestID
        self.subscriptionID = subscriptionID
    }
}

public struct Subscribed: Message {
    private var subscribedFields: ISubscribedFields

    public static let id: UInt64 = 33
    public static let text = "SUBSCRIBED"

    static let validationSpec = ValidationSpec(
        minLength: 3,
        maxLength: 3,
        message: Subscribed.text,
        spec: [
            1: validateRequestID,
            2: validateSubscriptionID
        ]
    )

    public init(requestID: UInt64, subscriptionID: UInt64) {
        subscribedFields = SubscribedFields(
            requestID: requestID,
            subscriptionID: subscriptionID
        )
    }

    public init(withFields subscribedFields: ISubscribedFields) {
        self.subscribedFields = subscribedFields
    }

    public var requestID: UInt64 { subscribedFields.requestID }
    public var subscriptionID: UInt64 { subscribedFields.subscriptionID }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Subscribed(requestID: fields.requestID!, subscriptionID: fields.subscriptionID!)
    }

    public func marshal() -> [any Sendable] {
        [Subscribed.id, requestID, subscriptionID]
    }

    public var type: UInt64 {
        Subscribed.id
    }
}
