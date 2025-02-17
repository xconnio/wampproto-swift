import Foundation

protocol IPublishedFields {
    var requestID: Int64 { get }
    var publicationID: Int64 { get }
}

class PublishedFields: IPublishedFields {
    let requestID: Int64
    let publicationID: Int64

    init(requestID: Int64, publicationID: Int64) {
        self.requestID = requestID
        self.publicationID = publicationID
    }
}

class Published: Message {
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

    init(requestID: Int64, publicationID: Int64) {
        self.publishedFields = PublishedFields(requestID: requestID, publicationID: publicationID)
    }

    init(withFields publishedFields: IPublishedFields) {
        self.publishedFields = publishedFields
    }

    var requestID: Int64 { return publishedFields.requestID }
    var publicationID: Int64 { return publishedFields.publicationID }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Published(requestID: fields.requestID!, publicationID: fields.publicationID!)
    }

    func marshal() -> [Any] {
        return [Published.id, requestID, publicationID]
    }

    var type: Int64 {
        return Published.id
    }
}
