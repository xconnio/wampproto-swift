import Foundation

protocol ICancelFields {
    var requestID: Int64 { get }
    var options: [String: Any] { get }
}

class CancelFields: ICancelFields {
    let requestID: Int64
    let options: [String: Any]

    init(requestID: Int64, options: [String: Any] = [:]) {
        self.requestID = requestID
        self.options = options
    }
}

class Cancel: Message {
    private var cancelFields: ICancelFields

    static let id: Int64 = 49
    static let text = "CANCEL"

    static let validationSpec = ValidationSpec(
        minLength: 3,
        maxLength: 3,
        message: Cancel.text,
        spec: [
            1: validateRequestID,
            2: validateOptions
        ]
    )

    init(requestID: Int64, options: [String: Any] = [:]) {
        cancelFields = CancelFields(requestID: requestID, options: options)
    }

    init(withFields cancelFields: ICancelFields) {
        self.cancelFields = cancelFields
    }

    var requestID: Int64 { cancelFields.requestID }
    var options: [String: Any] { cancelFields.options }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Cancel(requestID: fields.requestID!, options: fields.options ?? [:])
    }

    func marshal() -> [Any] {
        [Cancel.id, requestID, options]
    }

    var type: Int64 {
        Cancel.id
    }
}
