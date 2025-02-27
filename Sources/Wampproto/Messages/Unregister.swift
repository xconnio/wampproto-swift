import Foundation

protocol IUnregisterFields {
    var requestID: Int64 { get }
    var registrationID: Int64 { get }
}

class UnregisterFields: IUnregisterFields {
    let requestID: Int64
    let registrationID: Int64

    init(requestID: Int64, registrationID: Int64) {
        self.requestID = requestID
        self.registrationID = registrationID
    }
}

class Unregister: Message {
    private var unregisterFields: IUnregisterFields

    static let id: Int64 = 66
    static let text = "UNREGISTER"

    static let validationSpec = ValidationSpec(
        minLength: 3,
        maxLength: 3,
        message: Unregister.text,
        spec: [
            1: validateRequestID,
            2: validateRegistrationID
        ]
    )

    init(requestID: Int64, registrationID: Int64) {
        self.unregisterFields = UnregisterFields(requestID: requestID, registrationID: registrationID)
    }

    init(withFields unregisterFields: IUnregisterFields) {
        self.unregisterFields = unregisterFields
    }

    var requestID: Int64 { return unregisterFields.requestID }
    var registrationID: Int64 { return unregisterFields.registrationID }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Unregister(requestID: fields.requestID!, registrationID: fields.registrationID!)
    }

    func marshal() -> [Any] {
        return [Unregister.id, requestID, registrationID]
    }

    var type: Int64 {
        return Unregister.id
    }
}
