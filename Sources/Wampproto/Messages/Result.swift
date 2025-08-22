import Foundation

public protocol IResultFields: BinaryPayload, Sendable {
    var requestID: Int64 { get }
    var args: [any Sendable]? { get }
    var kwargs: [String: any Sendable]? { get }
    var details: [String: any Sendable] { get }
}

public struct ResultFields: IResultFields {
    public let requestID: Int64
    public let args: [any Sendable]?
    public let kwargs: [String: any Sendable]?
    public let details: [String: any Sendable]
    public let payload: Data?
    public let payloadSerializer: Int
    public let payloadIsBinary: Bool

    public init(
        requestID: Int64,
        args: [any Sendable]? = nil,
        kwargs: [String: any Sendable]? = nil,
        details: [String: any Sendable] = [:],
        payload: Data? = nil,
        payloadSerializer: Int = 0
    ) {
        self.requestID = requestID
        self.args = args
        self.kwargs = kwargs
        self.details = details
        self.payload = payload
        self.payloadSerializer = payloadSerializer
        payloadIsBinary = payloadSerializer != 0
    }
}

public struct Result: Message {
    private var resultFields: IResultFields

    static let id: Int64 = 50
    static let text = "RESULT"

    static let validationSpec = ValidationSpec(
        minLength: 3,
        maxLength: 5,
        message: Result.text,
        spec: [
            1: validateRequestID,
            2: validateDetails,
            3: validateArgs,
            4: validateKWArgs
        ]
    )

    public init(
        requestID: Int64,
        args: [any Sendable]? = nil,
        kwargs: [String: any Sendable]? = nil,
        details: [String: any Sendable] = [:]
    ) {
        resultFields = ResultFields(
            requestID: requestID,
            args: args,
            kwargs: kwargs,
            details: details
        )
    }

    public init(withFields resultFields: IResultFields) {
        self.resultFields = resultFields
    }

    public var requestID: Int64 { resultFields.requestID }
    public var args: [any Sendable]? { resultFields.args }
    public var kwargs: [String: any Sendable]? { resultFields.kwargs }
    public var details: [String: any Sendable] { resultFields.details }
    public var payload: Data? { resultFields.payload }
    public var payloadSerializer: Int { resultFields.payloadSerializer }
    public var payloadIsBinary: Bool { resultFields.payloadIsBinary }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Result(requestID: fields.requestID!, args: fields.args,
                      kwargs: fields.kwArgs, details: fields.details ?? [:])
    }

    public func marshal() -> [any Sendable] {
        var message: [any Sendable] = [Result.id, requestID, details]

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
        Result.id
    }
}
