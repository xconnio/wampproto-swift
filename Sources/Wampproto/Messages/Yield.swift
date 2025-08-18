import Foundation

protocol IYieldFields: BinaryPayload {
    var requestID: Int64 { get }
    var args: [Any]? { get }
    var kwargs: [String: Any]? { get }
    var options: [String: Any] { get }
}

class YieldFields: IYieldFields {
    let requestID: Int64
    let args: [Any]?
    let kwargs: [String: Any]?
    let options: [String: Any]
    let payload: Data?
    let payloadSerializer: Int
    let payloadIsBinary: Bool

    init(
        requestID: Int64,
        args: [Any]? = nil,
        kwargs: [String: Any]? = nil,
        options: [String: Any] = [:],
        payload: Data? = nil,
        payloadSerializer: Int = 0
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

class Yield: Message {
    private var yieldFields: IYieldFields

    static let id: Int64 = 70
    static let text = "YIELD"

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

    init(
        requestID: Int64,
        args: [Any]? = nil,
        kwargs: [String: Any]? = nil,
        options: [String: Any] = [:]
    ) {
        yieldFields = YieldFields(
            requestID: requestID,
            args: args,
            kwargs: kwargs,
            options: options
        )
    }

    init(withFields yieldFields: IYieldFields) {
        self.yieldFields = yieldFields
    }

    var requestID: Int64 { yieldFields.requestID }
    var args: [Any]? { yieldFields.args }
    var kwargs: [String: Any]? { yieldFields.kwargs }
    var options: [String: Any] { yieldFields.options }
    var payload: Data? { yieldFields.payload }
    var payloadSerializer: Int { yieldFields.payloadSerializer }
    var payloadIsBinary: Bool { yieldFields.payloadIsBinary }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Yield(requestID: fields.requestID!, args: fields.args, kwargs: fields.kwArgs,
                     options: fields.options ?? [:])
    }

    func marshal() -> [Any] {
        var message: [Any] = [Yield.id, requestID, options]

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
        Yield.id
    }
}
