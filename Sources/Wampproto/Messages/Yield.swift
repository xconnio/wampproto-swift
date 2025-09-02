import Foundation

public protocol IYieldFields: BinaryPayload, Sendable {
    var requestID: UInt64 { get }
    var args: [any Sendable]? { get }
    var kwargs: [String: any Sendable]? { get }
    var options: [String: any Sendable] { get }
}

public struct YieldFields: IYieldFields {
    public let requestID: UInt64
    public let args: [any Sendable]?
    public let kwargs: [String: any Sendable]?
    public let options: [String: any Sendable]
    public let payload: Data?
    public let payloadSerializer: UInt64
    public let payloadIsBinary: Bool

    public init(
        requestID: UInt64,
        args: [any Sendable]? = nil,
        kwargs: [String: any Sendable]? = nil,
        options: [String: any Sendable] = [:],
        payload: Data? = nil,
        payloadSerializer: UInt64 = 0
    ) {
        self.requestID = requestID
        self.args = args
        self.kwargs = kwargs
        self.options = options
        self.payload = payload
        self.payloadSerializer = payloadSerializer
        payloadIsBinary = payloadSerializer != 0
    }
}

public struct Yield: Message {
    private var yieldFields: IYieldFields

    public static let id: UInt64 = 70
    public static let text = "YIELD"

    static let validationSpec = ValidationSpec(
        minLength: 3,
        maxLength: 5,
        message: Yield.text,
        spec: [
            1: validateRequestID,
            2: validateOptions,
            3: validateArgs,
            4: validateKWArgs
        ]
    )

    public init(
        requestID: UInt64,
        args: [any Sendable]? = nil,
        kwargs: [String: any Sendable]? = nil,
        options: [String: any Sendable] = [:]
    ) {
        yieldFields = YieldFields(
            requestID: requestID,
            args: args,
            kwargs: kwargs,
            options: options
        )
    }

    public init(withFields yieldFields: IYieldFields) {
        self.yieldFields = yieldFields
    }

    public var requestID: UInt64 { yieldFields.requestID }
    public var args: [any Sendable]? { yieldFields.args }
    public var kwargs: [String: any Sendable]? { yieldFields.kwargs }
    public var options: [String: any Sendable] { yieldFields.options }
    public var payload: Data? { yieldFields.payload }
    public var payloadSerializer: UInt64 { yieldFields.payloadSerializer }
    public var payloadIsBinary: Bool { yieldFields.payloadIsBinary }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Yield(requestID: fields.requestID!, args: fields.args, kwargs: fields.kwArgs,
                     options: fields.options ?? [:])
    }

    public func marshal() -> [any Sendable] {
        var message: [any Sendable] = [Yield.id, requestID, options]

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
        Yield.id
    }
}
