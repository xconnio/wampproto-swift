import Foundation

protocol IRegisterFields {
    var requestID: Int64 { get }
    var uri: String { get }
    var options: [String: Any] { get }
}

class RegisterFields: IRegisterFields {
    let requestID: Int64
    let uri: String
    let options: [String: Any]

    init(requestID: Int64, uri: String, options: [String: Any] = [:]) {
        self.requestID = requestID
        self.uri = uri
        self.options = options
    }
}

class Register: Message {
    private var registerFields: IRegisterFields

    static let id: Int64 = 64
    static let text = "REGISTER"

    static let validationSpec = ValidationSpec(
        minLength: 4,
        maxLength: 4,
        message: Register.text,
        spec: [
            1: validateRequestID,
            2: validateOptions,
            3: validateURI
        ]
    )

    init(requestID: Int64, uri: String, options: [String: Any] = [:]) {
        self.registerFields = RegisterFields(requestID: requestID, uri: uri, options: options)
    }

    init(withFields registerFields: IRegisterFields) {
        self.registerFields = registerFields
    }

    var requestID: Int64 { return registerFields.requestID }
    var uri: String { return registerFields.uri }
    var options: [String: Any] { return registerFields.options }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Register(requestID: fields.requestID!, uri: fields.uri!, options: fields.options ?? [:])
    }

    func marshal() -> [Any] {
        return [Register.id, requestID, options, uri]
    }

    var type: Int64 {
        return Register.id
    }
}
