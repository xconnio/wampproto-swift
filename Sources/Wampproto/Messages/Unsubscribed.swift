import Foundation

protocol IUnsubscribedFields {
    var requestID: Int64 { get }
}

class UnsubscribedFields: IUnsubscribedFields {
    let requestID: Int64

    init(requestID: Int64) {
        self.requestID = requestID
    }
}

class Unsubscribed: Message {
    private var unsubscribedFields: IUnsubscribedFields

    static let id: Int64 = 35
    static let text = "UNSUBSCRIBED"

    static let validationSpec = ValidationSpec(
        minLength: 2,
        maxLength: 2,
        message: Unsubscribed.text,
        spec: [
            1: validateRequestID
        ]
    )

    init(requestID: Int64) {
        self.unsubscribedFields = UnsubscribedFields(requestID: requestID)
    }

    init(withFields unsubscribedFields: IUnsubscribedFields) {
        self.unsubscribedFields = unsubscribedFields
    }

    var requestID: Int64 { return unsubscribedFields.requestID }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Unsubscribed(requestID: fields.requestID!)
    }

    func marshal() -> [Any] {
        return [Unsubscribed.id, requestID]
    }

    var type: Int64 {
        return Unsubscribed.id
    }
}
