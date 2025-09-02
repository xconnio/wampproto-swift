import Foundation

public protocol IChallengeFields: Sendable {
    var authMethod: String { get }
    var extra: [String: any Sendable] { get }
}

public struct ChallengeFields: IChallengeFields {
    public let authMethod: String
    public let extra: [String: any Sendable]

    public init(authMethod: String, extra: [String: any Sendable]) {
        self.authMethod = authMethod
        self.extra = extra
    }
}

public struct Challenge: Message {
    private var challengeFields: IChallengeFields

    public static let id: UInt64 = 4
    public static let text = "CHALLENGE"

    static let validationSpec = ValidationSpec(
        minLength: 3,
        maxLength: 3,
        message: Challenge.text,
        spec: [
            1: validateAuthMethod,
            2: validateExtra
        ]
    )

    public init(authMethod: String, extra: [String: any Sendable]) {
        challengeFields = ChallengeFields(authMethod: authMethod, extra: extra)
    }

    public init(withFields challengeFields: IChallengeFields) {
        self.challengeFields = challengeFields
    }

    public var authMethod: String { challengeFields.authMethod }
    public var extra: [String: any Sendable] { challengeFields.extra }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)
        return Challenge(authMethod: fields.authMethod!, extra: fields.extra!)
    }

    public func marshal() -> [any Sendable] {
        [Challenge.id, authMethod, extra]
    }

    public var type: UInt64 {
        Challenge.id
    }
}
