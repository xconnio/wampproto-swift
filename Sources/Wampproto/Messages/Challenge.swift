import Foundation

protocol IChallengeFields {
    var authMethod: String { get }
    var extra: [String: Any] { get }
}

class ChallengeFields: IChallengeFields {
    let authMethod: String
    let extra: [String: Any]

    init(authMethod: String, extra: [String: Any]) {
        self.authMethod = authMethod
        self.extra = extra
    }
}

class Challenge: Message {
    private var challengeFields: IChallengeFields

    static let id: Int64 = 4
    static let text = "CHALLENGE"

    static let validationSpec = ValidationSpec(
        minLength: 3,
        maxLength: 3,
        message: Challenge.text,
        spec: [
            1: validateAuthMethod,
            2: validateExtra
        ]
    )

    init(authMethod: String, extra: [String: Any]) {
        self.challengeFields = ChallengeFields(authMethod: authMethod, extra: extra)
    }

    init(withFields challengeFields: IChallengeFields) {
        self.challengeFields = challengeFields
    }

    var authMethod: String { return challengeFields.authMethod }
    var extra: [String: Any] { return challengeFields.extra }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)
        return Challenge(authMethod: fields.authMethod!, extra: fields.extra!)
    }

    func marshal() -> [Any] {
        return [Challenge.id, authMethod, extra]
    }

    var type: Int64 {
        return Challenge.id
    }
}
