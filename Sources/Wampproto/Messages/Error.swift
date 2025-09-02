import Foundation

public protocol IErrorFields: BinaryPayload, Sendable {
    var messageType: UInt64 { get }
    var requestID: UInt64 { get }
    var uri: String { get }
    var args: [any Sendable]? { get }
    var kwargs: [String: any Sendable]? { get }
    var details: [String: any Sendable] { get }
}

public struct ErrorFields: IErrorFields {
    public let messageType: UInt64
    public let requestID: UInt64
    public let uri: String
    public let args: [any Sendable]?
    public let kwargs: [String: any Sendable]?
    public let details: [String: any Sendable]
    public let payload: Data?
    public let payloadSerializer: UInt64
    public let payloadIsBinary: Bool

    public init(
        messageType: UInt64,
        requestID: UInt64,
        uri: String,
        args: [any Sendable]? = nil,
        kwargs: [String: any Sendable]? = nil,
        details: [String: Any] = [:],
        payload: Data? = nil,
        payloadSerializer: UInt64 = 0
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

    public static let id: UInt64 = 8
    public static let text = "ERROR"

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
        messageType: UInt64,
        requestID: UInt64,
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

    public var messageType: UInt64 { errorFields.messageType }
    public var requestID: UInt64 { errorFields.requestID }
    public var uri: String { errorFields.uri }
    public var args: [any Sendable]? { errorFields.args }
    public var kwargs: [String: any Sendable]? { errorFields.kwargs }
    public var details: [String: any Sendable] { errorFields.details }
    public var payload: Data? { errorFields.payload }
    public var payloadSerializer: UInt64 { errorFields.payloadSerializer }
    public var payloadIsBinary: Bool { errorFields.payloadIsBinary }

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

    public var type: UInt64 {
        Error.id
    }
}
