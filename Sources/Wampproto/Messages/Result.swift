import Foundation

protocol IResultFields: BinaryPayload {
    var requestID: Int64 { get }
    var args: [Any]? { get }
    var kwargs: [String: Any]? { get }
    var details: [String: Any] { get }
}

class ResultFields: IResultFields {
    let requestID: Int64
    let args: [Any]?
    let kwargs: [String: Any]?
    let details: [String: Any]
    let payload: Data?
    let payloadSerializer: Int
    let payloadIsBinary: Bool

    init(
        requestID: Int64,
        args: [Any]? = nil,
        kwargs: [String: Any]? = nil,
        details: [String: Any] = [:],
        payload: Data? = nil,
        payloadSerializer: Int = 0
    ) {
        self.requestID = requestID
        self.args = args
        self.kwargs = kwargs
        self.details = details
        self.payload = payload
        self.payloadSerializer = payloadSerializer
        self.payloadIsBinary = payloadSerializer != 0
    }
}

class Result: Message {
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

    init(
        requestID: Int64,
        args: [Any]? = nil,
        kwargs: [String: Any]? = nil,
        details: [String: Any] = [:]
    ) {
        self.resultFields = ResultFields(
            requestID: requestID,
            args: args,
            kwargs: kwargs,
            details: details
        )
    }

    init(withFields resultFields: IResultFields) {
        self.resultFields = resultFields
    }

    var requestID: Int64 { return resultFields.requestID }
    var args: [Any]? { return resultFields.args }
    var kwargs: [String: Any]? { return resultFields.kwargs }
    var details: [String: Any] { return resultFields.details }
    var payload: Data? { return resultFields.payload }
    var payloadSerializer: Int { return resultFields.payloadSerializer }
    var payloadIsBinary: Bool { return resultFields.payloadIsBinary }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Result(requestID: fields.requestID!, args: fields.args,
                      kwargs: fields.kwArgs, details: fields.details ?? [:])
    }

    func marshal() -> [Any] {
        var message: [Any] = [Result.id, requestID, details]

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
        return Result.id
    }
}
