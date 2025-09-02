import Foundation

public protocol IPublishedFields: Sendable {
    var requestID: UInt64 { get }
    var publicationID: UInt64 { get }
}

public struct PublishedFields: IPublishedFields {
    public let requestID: UInt64
    public let publicationID: UInt64
}

public struct Published: Message {
    private var publishedFields: IPublishedFields

    public static let id: UInt64 = 17
    public static let text = "PUBLISHED"

    static let validationSpec = ValidationSpec(
        minLength: 3,
        maxLength: 3,
        message: Published.text,
        spec: [
            1: validateRequestID,
            2: validatePublicationID
        ]
    )

    public init(requestID: UInt64, publicationID: UInt64) {
        publishedFields = PublishedFields(requestID: requestID, publicationID: publicationID)
    }

    public init(withFields publishedFields: IPublishedFields) {
        self.publishedFields = publishedFields
    }

    public var requestID: UInt64 { publishedFields.requestID }
    public var publicationID: UInt64 { publishedFields.publicationID }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Published(requestID: fields.requestID!, publicationID: fields.publicationID!)
    }

    public func marshal() -> [any Sendable] {
        [Published.id, requestID, publicationID]
    }

    public var type: UInt64 {
        Published.id
    }
}
