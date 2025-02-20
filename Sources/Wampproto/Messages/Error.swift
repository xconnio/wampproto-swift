import Foundation

protocol IErrorFields: BinaryPayload {
    var messageType: Int64 { get }
    var requestID: Int64 { get }
    var uri: String { get }
    var args: [Any]? { get }
    var kwargs: [String: Any]? { get }
    var details: [String: Any] { get }
}

class ErrorFields: IErrorFields {
    let messageType: Int64
    let requestID: Int64
    let uri: String
    let args: [Any]?
    let kwargs: [String: Any]?
    let details: [String: Any]
    let payload: Data?
    let payloadSerializer: Int
    let payloadIsBinary: Bool

    init(messageType: Int64, requestID: Int64, uri: String, args: [Any]? = nil, kwargs: [String: Any]? = nil,
         details: [String: Any] = [:], payload: Data? = nil, payloadSerializer: Int = 0) {
        self.messageType = messageType
        self.requestID = requestID
        self.uri = uri
        self.args = args
        self.kwargs = kwargs
        self.details = details
        self.payload = payload
        self.payloadSerializer = payloadSerializer
        self.payloadIsBinary = payloadSerializer != 0
    }
}

class Error: Message {
    private var errorFields: IErrorFields

    static let id: Int64 = 8
    static let text = "ERROR"

    static let validationSpec = ValidationSpec(
        minLength: 5,
        maxLength: 7,
        message: Error.text,
        spec: [
            1: validateMessageType,
            2: validateRequestID,
            3: validateDetails,
            4: validateURI,
            5: validateArgs,
            6: validateKWArgs
        ]
    )

    init(messageType: Int64, requestID: Int64, uri: String, args: [Any]? = nil, kwargs: [String: Any]? = nil,
         details: [String: Any] = [:]) {
        self.errorFields = ErrorFields(messageType: messageType, requestID: requestID, uri: uri,
                                       args: args, kwargs: kwargs, details: details)
    }

    init(withFields errorFields: IErrorFields) {
        self.errorFields = errorFields
    }

    var messageType: Int64 { return errorFields.messageType }
    var requestID: Int64 { return errorFields.requestID }
    var uri: String { return errorFields.uri }
    var args: [Any]? { return errorFields.args }
    var kwargs: [String: Any]? { return errorFields.kwargs }
    var details: [String: Any] { return errorFields.details }
    var payload: Data? { return errorFields.payload }
    var payloadSerializer: Int { return errorFields.payloadSerializer }
    var payloadIsBinary: Bool { return errorFields.payloadIsBinary }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Error(messageType: fields.messageType!, requestID: fields.requestID!, uri: fields.uri!,
                     args: fields.args, kwargs: fields.kwArgs, details: fields.details ?? [:])
    }

    func marshal() -> [Any] {
        var message: [Any] = [Error.id, messageType, requestID, details, uri]

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
        return Error.id
    }
}
