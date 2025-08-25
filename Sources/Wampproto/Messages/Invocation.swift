import Foundation

public protocol IInvocationFields: BinaryPayload, Sendable {
    var requestID: Int64 { get }
    var registrationID: Int64 { get }
    var args: [any Sendable]? { get }
    var kwargs: [String: any Sendable]? { get }
    var details: [String: any Sendable] { get }
}

public struct InvocationFields: IInvocationFields {
    public let requestID: Int64
    public let registrationID: Int64
    public let args: [any Sendable]?
    public let kwargs: [String: any Sendable]?
    public let details: [String: any Sendable]
    public let payload: Data?
    public let payloadSerializer: Int
    public let payloadIsBinary: Bool

    public init(
        requestID: Int64,
        registrationID: Int64,
        args: [any Sendable]? = nil,
        kwargs: [String: any Sendable]? = nil,
        details: [String: any Sendable] = [:],
        payload: Data? = nil,
        payloadSerializer: Int = 0
    ) {
        self.requestID = requestID
        self.registrationID = registrationID
        self.args = args
        self.kwargs = kwargs
        self.details = details
        self.payload = payload
        self.payloadSerializer = payloadSerializer
        payloadIsBinary = payloadSerializer != 0
    }
}

public struct Invocation: Message {
    private var invocationFields: IInvocationFields

    public static let id: Int64 = 68
    public static let text = "INVOCATION"

    static let validationSpec = ValidationSpec(
        minLength: 4,
        maxLength: 6,
        message: Invocation.text,
        spec: [
            1: validateRequestID,
            2: validateRegistrationID,
            3: validateDetails,
            4: validateArgs,
            5: validateKWArgs
        ]
    )

    public init(
        requestID: Int64,
        registrationID: Int64,
        args: [any Sendable]? = nil,
        kwargs: [String: any Sendable]? = nil,
        details: [String: any Sendable] = [:]
    ) {
        invocationFields = InvocationFields(
            requestID: requestID,
            registrationID: registrationID,
            args: args,
            kwargs: kwargs,
            details: details
        )
    }

    public init(withFields invocationFields: IInvocationFields) {
        self.invocationFields = invocationFields
    }

    public var requestID: Int64 { invocationFields.requestID }
    public var registrationID: Int64 { invocationFields.registrationID }
    public var args: [any Sendable]? { invocationFields.args }
    public var kwargs: [String: any Sendable]? { invocationFields.kwargs }
    public var details: [String: any Sendable] { invocationFields.details }
    public var payload: Data? { invocationFields.payload }
    public var payloadSerializer: Int { invocationFields.payloadSerializer }
    public var payloadIsBinary: Bool { invocationFields.payloadIsBinary }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Invocation(requestID: fields.requestID!, registrationID: fields.registrationID!,
                          args: fields.args, kwargs: fields.kwArgs, details: fields.details ?? [:])
    }

    public func marshal() -> [any Sendable] {
        var message: [any Sendable] = [Invocation.id, requestID, registrationID, details]

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
        Invocation.id
    }
}
