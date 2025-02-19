import Foundation

protocol IUnsubscribeFields {
    var requestID: Int64 { get }
    var subscriptionID: Int64 { get }
}

class UnsubscribeFields: IUnsubscribeFields {
    let requestID: Int64
    let subscriptionID: Int64

    init(requestID: Int64, subscriptionID: Int64) {
        self.requestID = requestID
        self.subscriptionID = subscriptionID
    }
}

class Unsubscribe: Message {
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

    init(requestID: Int64, subscriptionID: Int64) {
        self.unsubscribeFields = UnsubscribeFields(
            requestID: requestID,
            subscriptionID: subscriptionID
        )
    }

    init(withFields unsubscribeFields: IUnsubscribeFields) {
        self.unsubscribeFields = unsubscribeFields
    }

    var requestID: Int64 { return unsubscribeFields.requestID }
    var subscriptionID: Int64 { return unsubscribeFields.subscriptionID }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Unsubscribe(requestID: fields.requestID!, subscriptionID: fields.subscriptionID!)
    }

    func marshal() -> [Any] {
        return [Unsubscribe.id, requestID, subscriptionID]
    }

    var type: Int64 {
        return Unsubscribe.id
    }
}
