import Foundation

public protocol IPublishFields: BinaryPayload, Sendable {
    var requestID: Int64 { get }
    var uri: String { get }
    var args: [any Sendable]? { get }
    var kwargs: [String: any Sendable]? { get }
    var options: [String: any Sendable] { get }
}

public struct PublishFields: IPublishFields {
    public let requestID: Int64
    public let uri: String
    public let args: [any Sendable]?
    public let kwargs: [String: any Sendable]?
    public let options: [String: any Sendable]
    public let payload: Data?
    public let payloadSerializer: Int
    public let payloadIsBinary: Bool

    public init(
        requestID: Int64,
        uri: String,
        args: [any Sendable]? = nil,
        kwargs: [String: any Sendable]? = nil,
        options: [String: any Sendable] = [:],
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
        payloadIsBinary = payloadSerializer != 0
    }
}

public struct Publish: Message {
    private var publishFields: IPublishFields

    public static let id: Int64 = 16
    public static let text = "PUBLISH"

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

    public init(
        requestID: Int64,
        uri: String,
        args: [any Sendable]? = nil,
        kwargs: [String: any Sendable]? = nil,
        options: [String: any Sendable] = [:]
    ) {
        publishFields = PublishFields(
            requestID: requestID,
            uri: uri,
            args: args,
            kwargs: kwargs,
            options: options
        )
    }

    public init(withFields publishFields: IPublishFields) {
        self.publishFields = publishFields
    }

    public var requestID: Int64 { publishFields.requestID }
    public var uri: String { publishFields.uri }
    public var args: [any Sendable]? { publishFields.args }
    public var kwargs: [String: any Sendable]? { publishFields.kwargs }
    public var options: [String: any Sendable] { publishFields.options }
    public var payload: Data? { publishFields.payload }
    public var payloadSerializer: Int { publishFields.payloadSerializer }
    public var payloadIsBinary: Bool { publishFields.payloadIsBinary }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Publish(requestID: fields.requestID!, uri: fields.uri!, args: fields.args,
                       kwargs: fields.kwArgs, options: fields.options ?? [:])
    }

    public func marshal() -> [any Sendable] {
        var message: [any Sendable] = [Publish.id, requestID, options, uri]

        if let args {
            message.append(args)
        }
        if let kwargs {
            if args == nil {
                message.append([])
            }
            message.append(kwargs)
        }

        return message
    }

    public var type: Int64 {
        Publish.id
    }
}
