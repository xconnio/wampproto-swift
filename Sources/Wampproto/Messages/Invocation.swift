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
        payloadIsBinary = payloadSerializer != 0
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
        invocationFields = InvocationFields(
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

    var requestID: Int64 { invocationFields.requestID }
    var registrationID: Int64 { invocationFields.registrationID }
    var args: [Any]? { invocationFields.args }
    var kwargs: [String: Any]? { invocationFields.kwargs }
    var details: [String: Any] { invocationFields.details }
    var payload: Data? { invocationFields.payload }
    var payloadSerializer: Int { invocationFields.payloadSerializer }
    var payloadIsBinary: Bool { invocationFields.payloadIsBinary }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Invocation(requestID: fields.requestID!, registrationID: fields.registrationID!,
                          args: fields.args, kwargs: fields.kwArgs, details: fields.details ?? [:])
    }

    func marshal() -> [Any] {
        var message: [Any] = [Invocation.id, requestID, registrationID, details]

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

    var type: Int64 {
        Invocation.id
    }
}
