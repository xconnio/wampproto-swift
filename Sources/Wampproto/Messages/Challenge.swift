import Foundation

public protocol IChallengeFields {
    var authMethod: String { get }
    var extra: [String: Any] { get }
}

public class ChallengeFields: IChallengeFields {
    public let authMethod: String
    public let extra: [String: Any]

    public init(authMethod: String, extra: [String: Any]) {
        self.authMethod = authMethod
        self.extra = extra
    }
}

public class Challenge: Message {
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

    public init(authMethod: String, extra: [String: Any]) {
        challengeFields = ChallengeFields(authMethod: authMethod, extra: extra)
    }

    public init(withFields challengeFields: IChallengeFields) {
        self.challengeFields = challengeFields
    }

    var authMethod: String { challengeFields.authMethod }
    var extra: [String: Any] { challengeFields.extra }

    public static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)
        return Challenge(authMethod: fields.authMethod!, extra: fields.extra!)
    }

    public func marshal() -> [Any] {
        [Challenge.id, authMethod, extra]
    }

    public var type: Int64 {
        Challenge.id
    }
}
