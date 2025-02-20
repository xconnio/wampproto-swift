import Foundation

protocol IAbortFields: BinaryPayload {
    var details: [String: Any] { get }
    var reason: String { get }
    var args: [Any]? { get }
    var kwargs: [String: Any]? { get }
}

class AbortFields: IAbortFields {
    let details: [String: Any]
    let reason: String
    let args: [Any]?
    let kwargs: [String: Any]?
    let payload: Data?
    let payloadSerializer: Int
    let payloadIsBinary: Bool

    init(details: [String: Any], reason: String, args: [Any]? = nil, kwargs: [String: Any]? = nil,
         payload: Data? = nil, payloadSerializer: Int = 0) {
        self.details = details
        self.reason = reason
        self.args = args
        self.kwargs = kwargs
        self.payload = payload
        self.payloadSerializer = payloadSerializer
        self.payloadIsBinary = payloadSerializer != 0
    }
}

class Abort: Message {
    private var abortFields: IAbortFields

    static let id: Int64 = 3
    static let text = "ABORT"

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

    init(details: [String: Any], reason: String, args: [Any]? = nil, kwargs: [String: Any]? = nil) {
        self.abortFields = AbortFields(details: details, reason: reason, args: args, kwargs: kwargs)
    }

    init(withFields abortFields: IAbortFields) {
        self.abortFields = abortFields
    }

    var details: [String: Any] { return abortFields.details }
    var reason: String { return abortFields.reason }
    var args: [Any]? { return abortFields.args }
    var kwargs: [String: Any]? { return abortFields.kwargs }
    var payload: Data? { return abortFields.payload }
    var payloadSerializer: Int { return abortFields.payloadSerializer }
    var payloadIsBinary: Bool { return abortFields.payloadIsBinary }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Abort(details: fields.details!, reason: fields.reason!, args: fields.args, kwargs: fields.kwArgs)
    }

    func marshal() -> [Any] {
        var message: [Any] = [Abort.id, details, reason]

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
        return Abort.id
    }
}
