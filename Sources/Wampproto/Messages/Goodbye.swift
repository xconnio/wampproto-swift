import Foundation

protocol IGoodbyeFields {
    var details: [String: Any] { get }
    var reason: String { get }
}

class GoodbyeFields: IGoodbyeFields {
    let details: [String: Any]
    let reason: String

    init(details: [String: Any], reason: String) {
        self.details = details
        self.reason = reason
    }
}

class Goodbye: Message {
    private var goodbyeFields: IGoodbyeFields

    static let id: Int64 = 6
    static let text = "GOODBYE"

    static let validationSpec = ValidationSpec(
        minLength: 3,
        maxLength: 3,
        message: Goodbye.text,
        spec: [
            1: validateDetails,
            2: validateReason
        ]
    )

    init(details: [String: Any], reason: String) {
        self.goodbyeFields = GoodbyeFields(details: details, reason: reason)
    }

    init(withFields goodbyeFields: IGoodbyeFields) {
        self.goodbyeFields = goodbyeFields
    }

    var details: [String: Any] { return goodbyeFields.details }
    var reason: String { return goodbyeFields.reason }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Goodbye(details: fields.details ?? [:], reason: fields.reason!)
    }

    func marshal() -> [Any] {
        return [Goodbye.id, details, reason]
    }

    var type: Int64 {
        return Goodbye.id
    }
}
