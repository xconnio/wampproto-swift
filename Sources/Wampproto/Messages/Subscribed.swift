import Foundation

protocol ISubscribedFields {
    var requestID: Int64 { get }
    var subscriptionID: Int64 { get }
}

class SubscribedFields: ISubscribedFields {
    let requestID: Int64
    let subscriptionID: Int64

    init(requestID: Int64, subscriptionID: Int64) {
        self.requestID = requestID
        self.subscriptionID = subscriptionID
    }
}

class Subscribed: Message {
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

    init(requestID: Int64, subscriptionID: Int64) {
        subscribedFields = SubscribedFields(
            requestID: requestID,
            subscriptionID: subscriptionID
        )
    }

    init(withFields subscribedFields: ISubscribedFields) {
        self.subscribedFields = subscribedFields
    }

    var requestID: Int64 { subscribedFields.requestID }
    var subscriptionID: Int64 { subscribedFields.subscriptionID }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Subscribed(requestID: fields.requestID!, subscriptionID: fields.subscriptionID!)
    }

    func marshal() -> [Any] {
        [Subscribed.id, requestID, subscriptionID]
    }

    var type: Int64 {
        Subscribed.id
    }
}
