import Foundation

public protocol IErrorFields: BinaryPayload, Sendable {
    var messageType: Int64 { get }
    var requestID: Int64 { get }
    var uri: String { get }
    var args: [any Sendable]? { get }
    var kwargs: [String: any Sendable]? { get }
    var details: [String: any Sendable] { get }
}

public struct ErrorFields: IErrorFields {
    public let messageType: Int64
    public let requestID: Int64
    public let uri: String
    public let args: [any Sendable]?
    public let kwargs: [String: any Sendable]?
    public let details: [String: any Sendable]
    public let payload: Data?
    public let payloadSerializer: Int
    public let payloadIsBinary: Bool

    public init(
        messageType: Int64,
        requestID: Int64,
        uri: String,
        args: [any Sendable]? = nil,
        kwargs: [String: any Sendable]? = nil,
        details: [String: Any] = [:],
        payload: Data? = nil,
        payloadSerializer: Int = 0
    ) {
        self.messageType = messageType
        self.requestID = requestID
        self.uri = uri
        self.args = args
        self.kwargs = kwargs
        self.details = details
        self.payload = payload
        self.payloadSerializer = payloadSerializer
        payloadIsBinary = payloadSerializer != 0
    }
}

public struct Error: Message {
    private var errorFields: IErrorFields

    static let id: Int64 = 8
    static let text = "ERROR"

    static let validationSpec = ValidationSpec(
        minLength: 5,
        maxLength: 7,
        message: Error.text,
        spec: [
            1: validateMessageType,
            2: validateRequestID,
            3: validateDetails,
            4: validateURI,
            5: validateArgs,
            6: validateKWArgs
        ]
    )

    public init(
        messageType: Int64,
        requestID: Int64,
        uri: String,
        args: [any Sendable]? = nil,
        kwargs: [String: any Sendable]? = nil,
        details: [String: any Sendable] = [:]
    ) {
        errorFields = ErrorFields(messageType: messageType, requestID: requestID, uri: uri,
                                  args: args, kwargs: kwargs, details: details)
    }

    public init(withFields errorFields: IErrorFields) {
        self.errorFields = errorFields
    }

    var messageType: Int64 { errorFields.messageType }
    var requestID: Int64 { errorFields.requestID }
    var uri: String { errorFields.uri }
    var args: [any Sendable]? { errorFields.args }
    var kwargs: [String: any Sendable]? { errorFields.kwargs }
    var details: [String: any Sendable] { errorFields.details }
    var payload: Data? { errorFields.payload }
    var payloadSerializer: Int { errorFields.payloadSerializer }
    var payloadIsBinary: Bool { errorFields.payloadIsBinary }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Error(messageType: fields.messageType!, requestID: fields.requestID!, uri: fields.uri!,
                     args: fields.args, kwargs: fields.kwArgs, details: fields.details ?? [:])
    }

    public func marshal() -> [any Sendable] {
        var message: [any Sendable] = [Error.id, messageType, requestID, details, uri]

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
        Error.id
    }
}
