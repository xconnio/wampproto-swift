import Foundation

public protocol IAbortFields: BinaryPayload, Sendable {
    var details: [String: any Sendable] { get }
    var reason: String { get }
    var args: [any Sendable]? { get }
    var kwargs: [String: any Sendable]? { get }
}

public struct AbortFields: IAbortFields {
    public var details: [String: any Sendable]
    public let reason: String
    public let args: [any Sendable]?
    public let kwargs: [String: any Sendable]?
    public let payload: Data?
    public let payloadSerializer: UInt64
    public let payloadIsBinary: Bool

    public init(
        details: [String: any Sendable],
        reason: String,
        args: [any Sendable]? = nil,
        kwargs: [String: any Sendable]? = nil,
        payload: Data? = nil,
        payloadSerializer: UInt64 = 0
    ) {
        self.details = details
        self.reason = reason
        self.args = args
        self.kwargs = kwargs
        self.payload = payload
        self.payloadSerializer = payloadSerializer
        payloadIsBinary = payloadSerializer != 0
    }
}

public struct Abort: Message {
    private var abortFields: IAbortFields

    public static let id: UInt64 = 3
    public static let text = "ABORT"

    static let validationSpec = ValidationSpec(
        minLength: 3,
        maxLength: 5,
        message: Abort.text,
        spec: [
            1: validateDetails,
            2: validateReason,
            3: validateArgs,
            4: validateKWArgs
        ]
    )

    public init(
        details: [String: any Sendable],
        reason: String,
        args: [any Sendable]? = nil,
        kwargs: [String: any Sendable]? = nil
    ) {
        abortFields = AbortFields(details: details, reason: reason, args: args, kwargs: kwargs)
    }

    public init(withFields abortFields: IAbortFields) {
        self.abortFields = abortFields
    }

    public var details: [String: any Sendable] { abortFields.details }
    public var reason: String { abortFields.reason }
    public var args: [any Sendable]? { abortFields.args }
    public var kwargs: [String: any Sendable]? { abortFields.kwargs }
    public var payload: Data? { abortFields.payload }
    var payloadSerializer: UInt64 { abortFields.payloadSerializer }
    var payloadIsBinary: Bool { abortFields.payloadIsBinary }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Abort(details: fields.details!, reason: fields.reason!, args: fields.args, kwargs: fields.kwArgs)
    }

    public func marshal() -> [any Sendable] {
        var message: [any Sendable] = [Abort.id, details, reason]

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
        Abort.id
    }
}
