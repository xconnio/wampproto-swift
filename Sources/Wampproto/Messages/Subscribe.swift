import Foundation

public protocol ISubscribeFields: Sendable {
    var requestID: Int64 { get }
    var topic: String { get }
    var options: [String: any Sendable] { get }
}

public struct SubscribeFields: ISubscribeFields {
    public let requestID: Int64
    public let topic: String
    public let options: [String: any Sendable]

    public init(
        requestID: Int64,
        topic: String,
        options: [String: any Sendable] = [:]
    ) {
        self.requestID = requestID
        self.topic = topic
        self.options = options
    }
}

public struct Subscribe: Message {
    private var subscribeFields: ISubscribeFields

    public static let id: Int64 = 32
    public static let text = "SUBSCRIBE"

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

    public init(
        requestID: Int64,
        topic: String,
        options: [String: any Sendable] = [:]
    ) {
        subscribeFields = SubscribeFields(
            requestID: requestID,
            topic: topic,
            options: options
        )
    }

    public init(withFields subscribeFields: ISubscribeFields) {
        self.subscribeFields = subscribeFields
    }

    public var requestID: Int64 { subscribeFields.requestID }
    public var topic: String { subscribeFields.topic }
    public var options: [String: any Sendable] { subscribeFields.options }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Subscribe(requestID: fields.requestID!, topic: fields.uri!, options: fields.options ?? [:])
    }

    public func marshal() -> [any Sendable] {
        [Subscribe.id, requestID, options, topic]
    }

    public var type: Int64 {
        Subscribe.id
    }
}
