import Foundation

public protocol ISubscribedFields: Sendable {
    var requestID: Int64 { get }
    var subscriptionID: Int64 { get }
}

public struct SubscribedFields: ISubscribedFields {
    public let requestID: Int64
    public let subscriptionID: Int64

    public init(requestID: Int64, subscriptionID: Int64) {
        self.requestID = requestID
        self.subscriptionID = subscriptionID
    }
}

public struct Subscribed: Message {
    private var subscribedFields: ISubscribedFields

    static let id: Int64 = 33
    static let text = "SUBSCRIBED"

    static let validationSpec = ValidationSpec(
        minLength: 3,
        maxLength: 3,
        message: Subscribed.text,
        spec: [
            1: validateRequestID,
            2: validateSubscriptionID
        ]
    )

    public init(requestID: Int64, subscriptionID: Int64) {
        subscribedFields = SubscribedFields(
            requestID: requestID,
            subscriptionID: subscriptionID
        )
    }

    public init(withFields subscribedFields: ISubscribedFields) {
        self.subscribedFields = subscribedFields
    }

    public var requestID: Int64 { subscribedFields.requestID }
    public var subscriptionID: Int64 { subscribedFields.subscriptionID }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Subscribed(requestID: fields.requestID!, subscriptionID: fields.subscriptionID!)
    }

    public func marshal() -> [any Sendable] {
        [Subscribed.id, requestID, subscriptionID]
    }

    public var type: Int64 {
        Subscribed.id
    }
}
