import Foundation

protocol IPublishFields: BinaryPayload {
    var requestID: Int64 { get }
    var uri: String { get }
    var args: [Any]? { get }
    var kwargs: [String: Any]? { get }
    var options: [String: Any] { get }
}

class PublishFields: IPublishFields {
    let requestID: Int64
    let uri: String
    let args: [Any]?
    let kwargs: [String: Any]?
    let options: [String: Any]
    let payload: Data?
    let payloadSerializer: Int
    let payloadIsBinary: Bool

    init(
        requestID: Int64,
        uri: String,
        args: [Any]? = nil,
        kwargs: [String: Any]? = nil,
        options: [String: Any] = [:],
        payload: Data? = nil,
        payloadSerializer: Int = 0
    ) {
        self.requestID = requestID
        self.uri = uri
        self.args = args
        self.kwargs = kwargs
        self.options = options
        self.payload = payload
        self.payloadSerializer = payloadSerializer
        self.payloadIsBinary = payloadSerializer != 0
    }
}

class Publish: Message {
    private var publishFields: IPublishFields

    static let id: Int64 = 16
    static let text = "PUBLISH"

    static let validationSpec = ValidationSpec(
        minLength: 4,
        maxLength: 6,
        message: Publish.text,
        spec: [
            1: validateRequestID,
            2: validateOptions,
            3: validateURI,
            4: validateArgs,
            5: validateKWArgs
        ]
    )

    init(
        requestID: Int64,
        uri: String,
        args: [Any]? = nil,
        kwargs: [String: Any]? = nil,
        options: [String: Any] = [:]
    ) {
        self.publishFields = PublishFields(
            requestID: requestID,
            uri: uri,
            args: args,
            kwargs: kwargs,
            options: options
        )
    }

    init(withFields publishFields: IPublishFields) {
        self.publishFields = publishFields
    }

    var requestID: Int64 { return publishFields.requestID }
    var uri: String { return publishFields.uri }
    var args: [Any]? { return publishFields.args }
    var kwargs: [String: Any]? { return publishFields.kwargs }
    var options: [String: Any] { return publishFields.options }
    var payload: Data? { return publishFields.payload }
    var payloadSerializer: Int { return publishFields.payloadSerializer }
    var payloadIsBinary: Bool { return publishFields.payloadIsBinary }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Publish(requestID: fields.requestID!, uri: fields.uri!, args: fields.args,
                       kwargs: fields.kwArgs, options: fields.options ?? [:])
    }

    func marshal() -> [Any] {
        var message: [Any] = [Publish.id, requestID, options, uri]

        if let args = args {
            message.append(args)
        }
        if let kwargs = kwargs {
            if args == nil {
                message.append([])
            }
            message.append(kwargs)
        }

        return message
    }

    var type: Int64 {
        return Publish.id
    }
}
