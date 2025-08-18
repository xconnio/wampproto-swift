import Foundation

protocol IRegisteredFields {
    var requestID: Int64 { get }
    var registrationID: Int64 { get }
}

class RegisteredFields: IRegisteredFields {
    let requestID: Int64
    let registrationID: Int64

    init(requestID: Int64, registrationID: Int64) {
        self.requestID = requestID
        self.registrationID = registrationID
    }
}

class Registered: Message {
    private var registeredFields: IRegisteredFields

    static let id: Int64 = 65
    static let text = "REGISTERED"

    static let validationSpec = ValidationSpec(
        minLength: 3,
        maxLength: 3,
        message: Registered.text,
        spec: [
            1: validateRequestID,
            2: validateRegistrationID
        ]
    )

    init(requestID: Int64, registrationID: Int64) {
        registeredFields = RegisteredFields(requestID: requestID, registrationID: registrationID)
    }

    init(withFields registeredFields: IRegisteredFields) {
        self.registeredFields = registeredFields
    }

    var requestID: Int64 { registeredFields.requestID }
    var registrationID: Int64 { registeredFields.registrationID }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Registered(requestID: fields.requestID!, registrationID: fields.registrationID!)
    }

    func marshal() -> [Any] {
        [Registered.id, requestID, registrationID]
    }

    var type: Int64 {
        Registered.id
    }
}
