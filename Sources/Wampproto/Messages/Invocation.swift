import Foundation

protocol IInvocationFields: BinaryPayload {
    var requestID: Int64 { get }
    var registrationID: Int64 { get }
    var args: [Any]? { get }
    var kwargs: [String: Any]? { get }
    var details: [String: Any] { get }
}

class InvocationFields: IInvocationFields {
    let requestID: Int64
    let registrationID: Int64
    let args: [Any]?
    let kwargs: [String: Any]?
    let details: [String: Any]
    let payload: Data?
    let payloadSerializer: Int
    let payloadIsBinary: Bool

    init(
        requestID: Int64,
        registrationID: Int64,
        args: [Any]? = nil,
        kwargs: [String: Any]? = nil,
        details: [String: Any] = [:],
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
        self.payloadIsBinary = payloadSerializer != 0
    }
}

class Invocation: Message {
    private var invocationFields: IInvocationFields

    static let id: Int64 = 68
    static let text = "INVOCATION"

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

    init(
        requestID: Int64,
        registrationID: Int64,
        args: [Any]? = nil,
        kwargs: [String: Any]? = nil,
        details: [String: Any] = [:]
    ) {
        self.invocationFields = InvocationFields(
            requestID: requestID,
            registrationID: registrationID,
            args: args,
            kwargs: kwargs,
            details: details
        )
    }

    init(withFields invocationFields: IInvocationFields) {
        self.invocationFields = invocationFields
    }

    var requestID: Int64 { return invocationFields.requestID }
    var registrationID: Int64 { return invocationFields.registrationID }
    var args: [Any]? { return invocationFields.args }
    var kwargs: [String: Any]? { return invocationFields.kwargs }
    var details: [String: Any] { return invocationFields.details }
    var payload: Data? { return invocationFields.payload }
    var payloadSerializer: Int { return invocationFields.payloadSerializer }
    var payloadIsBinary: Bool { return invocationFields.payloadIsBinary }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Invocation(requestID: fields.requestID!, registrationID: fields.registrationID!,
                          args: fields.args, kwargs: fields.kwArgs, details: fields.details ?? [:])
    }

    func marshal() -> [Any] {
        var message: [Any] = [Invocation.id, requestID, registrationID, details]

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
        return Invocation.id
    }
}
