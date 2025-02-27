import Foundation

protocol ICallFields: BinaryPayload {
    var requestID: Int64 { get }
    var uri: String { get }
    var args: [Any]? { get }
    var kwargs: [String: Any]? { get }
    var options: [String: Any] { get }
}

class CallFields: ICallFields {
    let requestID: Int64
    let uri: String
    let args: [Any]?
    let kwargs: [String: Any]?
    let options: [String: Any]
    let payload: Data?
    let payloadSerializer: Int
    let payloadIsBinary: Bool

    init(
        requestID: Int64,
        uri: String,
        args: [Any]? = nil,
        kwargs: [String: Any]? = nil,
        options: [String: Any] = [:],
        payload: Data? = nil,
        payloadSerializer: Int = 0
    ) {
        self.requestID = requestID
        self.uri = uri
        self.args = args
        self.kwargs = kwargs
        self.options = options
        self.payload = payload
        self.payloadSerializer = payloadSerializer
        self.payloadIsBinary = payloadSerializer != 0
    }
}

class Call: Message {
    private var callFields: ICallFields

    static let id: Int64 = 48
    static let text = "CALL"

    static let validationSpec = ValidationSpec(
        minLength: 4,
        maxLength: 6,
        message: Call.text,
        spec: [
            1: validateRequestID,
            2: validateOptions,
            3: validateURI,
            4: validateArgs,
            5: validateKWArgs
        ]
    )

    init(
        requestID: Int64,
        uri: String,
        args: [Any]? = nil,
        kwargs: [String: Any]? = nil,
        options: [String: Any] = [:]
    ) {
        self.callFields = CallFields(
            requestID: requestID,
            uri: uri,
            args: args,
            kwargs: kwargs,
            options: options
        )
    }

    init(withFields callFields: ICallFields) {
        self.callFields = callFields
    }

    var requestID: Int64 { return callFields.requestID }
    var uri: String { return callFields.uri }
    var args: [Any]? { return callFields.args }
    var kwargs: [String: Any]? { return callFields.kwargs }
    var options: [String: Any] { return callFields.options }
    var payload: Data? { return callFields.payload }
    var payloadSerializer: Int { return callFields.payloadSerializer }
    var payloadIsBinary: Bool { return callFields.payloadIsBinary }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Call(requestID: fields.requestID!, uri: fields.uri!, args: fields.args,
                    kwargs: fields.kwArgs, options: fields.options ?? [:])
    }

    func marshal() -> [Any] {
        var message: [Any] = [Call.id, requestID, options, uri]

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
        return Call.id
    }
}
