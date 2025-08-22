import Foundation

public protocol IGoodbyeFields: Sendable {
    var details: [String: any Sendable] { get }
    var reason: String { get }
}

public struct GoodbyeFields: IGoodbyeFields {
    public let details: [String: any Sendable]
    public let reason: String

    public init(details: [String: any Sendable], reason: String) {
        self.details = details
        self.reason = reason
    }
}

public struct Goodbye: Message {
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

    public init(details: [String: any Sendable], reason: String) {
        goodbyeFields = GoodbyeFields(details: details, reason: reason)
    }

    public init(withFields goodbyeFields: IGoodbyeFields) {
        self.goodbyeFields = goodbyeFields
    }

    public var details: [String: any Sendable] { goodbyeFields.details }
    public var reason: String { goodbyeFields.reason }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Goodbye(details: fields.details ?? [:], reason: fields.reason!)
    }

    public func marshal() -> [any Sendable] {
        [Goodbye.id, details, reason]
    }

    public var type: Int64 {
        Goodbye.id
    }
}
