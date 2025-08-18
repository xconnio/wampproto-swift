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
        payloadIsBinary = payloadSerializer != 0
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
        resultFields = ResultFields(
            requestID: requestID,
            args: args,
            kwargs: kwargs,
            details: details
        )
    }

    init(withFields resultFields: IResultFields) {
        self.resultFields = resultFields
    }

    var requestID: Int64 { resultFields.requestID }
    var args: [Any]? { resultFields.args }
    var kwargs: [String: Any]? { resultFields.kwargs }
    var details: [String: Any] { resultFields.details }
    var payload: Data? { resultFields.payload }
    var payloadSerializer: Int { resultFields.payloadSerializer }
    var payloadIsBinary: Bool { resultFields.payloadIsBinary }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Result(requestID: fields.requestID!, args: fields.args,
                      kwargs: fields.kwArgs, details: fields.details ?? [:])
    }

    func marshal() -> [Any] {
        var message: [Any] = [Result.id, requestID, details]

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
        Result.id
    }
}
