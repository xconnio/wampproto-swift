import Foundation

public protocol IUnsubscribeFields: Sendable {
    var requestID: Int64 { get }
    var subscriptionID: Int64 { get }
}

public struct UnsubscribeFields: IUnsubscribeFields {
    public let requestID: Int64
    public let subscriptionID: Int64

    public init(requestID: Int64, subscriptionID: Int64) {
        self.requestID = requestID
        self.subscriptionID = subscriptionID
    }
}

public struct Unsubscribe: Message {
    private var unsubscribeFields: IUnsubscribeFields

    static let id: Int64 = 34
    static let text = "UNSUBSCRIBE"

    static let validationSpec = ValidationSpec(
        minLength: 3,
        maxLength: 3,
        message: Unsubscribe.text,
        spec: [
            1: validateRequestID,
            2: validateSubscriptionID
        ]
    )

    public init(requestID: Int64, subscriptionID: Int64) {
        unsubscribeFields = UnsubscribeFields(
            requestID: requestID,
            subscriptionID: subscriptionID
        )
    }

    public init(withFields unsubscribeFields: IUnsubscribeFields) {
        self.unsubscribeFields = unsubscribeFields
    }

    public var requestID: Int64 { unsubscribeFields.requestID }
    public var subscriptionID: Int64 { unsubscribeFields.subscriptionID }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Unsubscribe(requestID: fields.requestID!, subscriptionID: fields.subscriptionID!)
    }

    public func marshal() -> [any Sendable] {
        [Unsubscribe.id, requestID, subscriptionID]
    }

    public var type: Int64 {
        Unsubscribe.id
    }
}
