import Foundation

protocol ISubscribeFields {
    var requestID: Int64 { get }
    var topic: String { get }
    var options: [String: Any] { get }
}

class SubscribeFields: ISubscribeFields {
    let requestID: Int64
    let topic: String
    let options: [String: Any]

    init(
        requestID: Int64,
        topic: String,
        options: [String: Any] = [:]
    ) {
        self.requestID = requestID
        self.topic = topic
        self.options = options
    }
}

class Subscribe: Message {
    private var subscribeFields: ISubscribeFields

    static let id: Int64 = 32
    static let text = "SUBSCRIBE"

    static let validationSpec = ValidationSpec(
        minLength: 4,
        maxLength: 4,
        message: Subscribe.text,
        spec: [
            1: validateRequestID,
            2: validateOptions,
            3: validateURI
        ]
    )

    init(
        requestID: Int64,
        topic: String,
        options: [String: Any] = [:]
    ) {
        self.subscribeFields = SubscribeFields(
            requestID: requestID,
            topic: topic,
            options: options
        )
    }

    init(withFields subscribeFields: ISubscribeFields) {
        self.subscribeFields = subscribeFields
    }

    var requestID: Int64 { return subscribeFields.requestID }
    var topic: String { return subscribeFields.topic }
    var options: [String: Any] { return subscribeFields.options }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Subscribe(requestID: fields.requestID!, topic: fields.uri!, options: fields.options ?? [:])
    }

    func marshal() -> [Any] {
        return [Subscribe.id, requestID, options, topic]
    }

    var type: Int64 {
        return Subscribe.id
    }
}
