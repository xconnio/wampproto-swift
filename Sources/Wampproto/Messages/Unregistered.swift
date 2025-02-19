import Foundation

protocol IUnregisteredFields {
    var requestID: Int64 { get }
}

class UnregisteredFields: IUnregisteredFields {
    let requestID: Int64

    init(requestID: Int64) {
        self.requestID = requestID
    }
}

class Unregistered: Message {
    private var unregisteredFields: IUnregisteredFields

    static let id: Int64 = 67
    static let text = "UNREGISTERED"

    static let validationSpec = ValidationSpec(
        minLength: 2,
        maxLength: 2,
        message: Unregistered.text,
        spec: [
            1: validateRequestID
        ]
    )

    init(requestID: Int64) {
        self.unregisteredFields = UnregisteredFields(requestID: requestID)
    }

    init(withFields unregisteredFields: IUnregisteredFields) {
        self.unregisteredFields = unregisteredFields
    }

    var requestID: Int64 { return unregisteredFields.requestID }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Unregistered(requestID: fields.requestID!)
    }

    func marshal() -> [Any] {
        return [Unregistered.id, requestID]
    }

    var type: Int64 {
        return Unregistered.id
    }
}
