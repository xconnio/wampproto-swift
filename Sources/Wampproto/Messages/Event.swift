import Foundation

protocol IEventFields: BinaryPayload {
    var subscriptionID: Int64 { get }
    var publicationID: Int64 { get }
    var args: [Any]? { get }
    var kwargs: [String: Any]? { get }
    var details: [String: Any] { get }
}

class EventFields: IEventFields {
    let subscriptionID: Int64
    let publicationID: Int64
    let args: [Any]?
    let kwargs: [String: Any]?
    let details: [String: Any]
    let payload: Data?
    let payloadSerializer: Int
    let payloadIsBinary: Bool

    init(
        subscriptionID: Int64,
        publicationID: Int64,
        args: [Any]? = nil,
        kwargs: [String: Any]? = nil,
        details: [String: Any] = [:],
        payload: Data? = nil,
        payloadSerializer: Int = 0
    ) {
        self.subscriptionID = subscriptionID
        self.publicationID = publicationID
        self.args = args
        self.kwargs = kwargs
        self.details = details
        self.payload = payload
        self.payloadSerializer = payloadSerializer
        payloadIsBinary = payloadSerializer != 0
    }
}

class Event: Message {
    private var eventFields: IEventFields

    static let id: Int64 = 36
    static let text = "EVENT"

    static let validationSpec = ValidationSpec(
        minLength: 4,
        maxLength: 6,
        message: Event.text,
        spec: [
            1: validateSubscriptionID,
            2: validatePublicationID,
            3: validateDetails,
            4: validateArgs,
            5: validateKWArgs
        ]
    )

    init(
        subscriptionID: Int64,
        publicationID: Int64,
        args: [Any]? = nil,
        kwargs: [String: Any]? = nil,
        details: [String: Any] = [:]
    ) {
        eventFields = EventFields(
            subscriptionID: subscriptionID,
            publicationID: publicationID,
            args: args,
            kwargs: kwargs,
            details: details
        )
    }

    init(withFields eventFields: IEventFields) {
        self.eventFields = eventFields
    }

    var subscriptionID: Int64 { eventFields.subscriptionID }
    var publicationID: Int64 { eventFields.publicationID }
    var args: [Any]? { eventFields.args }
    var kwargs: [String: Any]? { eventFields.kwargs }
    var details: [String: Any] { eventFields.details }
    var payload: Data? { eventFields.payload }
    var payloadSerializer: Int { eventFields.payloadSerializer }
    var payloadIsBinary: Bool { eventFields.payloadIsBinary }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Event(subscriptionID: fields.subscriptionID!, publicationID: fields.publicationID!,
                     args: fields.args, kwargs: fields.kwArgs, details: fields.details ?? [:])
    }

    func marshal() -> [Any] {
        var message: [Any] = [Event.id, subscriptionID, publicationID, details]

        if let args {
            message.append(args)
        }

        if let kwargs {
            if args == nil {
                message.append([])
            }
            message.append(kwargs)
        }

        return message
    }

    var type: Int64 {
        Event.id
    }
}
