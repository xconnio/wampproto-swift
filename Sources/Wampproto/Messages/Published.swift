import Foundation

public protocol IPublishedFields: Sendable {
    var requestID: Int64 { get }
    var publicationID: Int64 { get }
}

public struct PublishedFields: IPublishedFields {
    public let requestID: Int64
    public let publicationID: Int64
}

public struct Published: Message {
    private var publishedFields: IPublishedFields

    static let id: Int64 = 17
    static let text = "PUBLISHED"

    static let validationSpec = ValidationSpec(
        minLength: 3,
        maxLength: 3,
        message: Published.text,
        spec: [
            1: validateRequestID,
            2: validatePublicationID
        ]
    )

    public init(requestID: Int64, publicationID: Int64) {
        publishedFields = PublishedFields(requestID: requestID, publicationID: publicationID)
    }

    public init(withFields publishedFields: IPublishedFields) {
        self.publishedFields = publishedFields
    }

    public var requestID: Int64 { publishedFields.requestID }
    public var publicationID: Int64 { publishedFields.publicationID }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Published(requestID: fields.requestID!, publicationID: fields.publicationID!)
    }

    public func marshal() -> [any Sendable] {
        [Published.id, requestID, publicationID]
    }

    public var type: Int64 {
        Published.id
    }
}
