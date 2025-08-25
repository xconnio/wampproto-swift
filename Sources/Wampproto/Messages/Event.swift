import Foundation

public protocol IEventFields: BinaryPayload, Sendable {
    var subscriptionID: Int64 { get }
    var publicationID: Int64 { get }
    var args: [any Sendable]? { get }
    var kwargs: [String: any Sendable]? { get }
    var details: [String: any Sendable] { get }
}

public struct EventFields: IEventFields {
    public let subscriptionID: Int64
    public let publicationID: Int64
    public let args: [any Sendable]?
    public let kwargs: [String: any Sendable]?
    public let details: [String: any Sendable]
    public let payload: Data?
    public let payloadSerializer: Int
    public let payloadIsBinary: Bool

    public init(
        subscriptionID: Int64,
        publicationID: Int64,
        args: [any Sendable]? = nil,
        kwargs: [String: any Sendable]? = nil,
        details: [String: any Sendable] = [:],
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

public struct Event: Message {
    private var eventFields: IEventFields

    public static let id: Int64 = 36
    public static let text = "EVENT"

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

    public init(
        subscriptionID: Int64,
        publicationID: Int64,
        args: [any Sendable]? = nil,
        kwargs: [String: any Sendable]? = nil,
        details: [String: any Sendable] = [:]
    ) {
        eventFields = EventFields(
            subscriptionID: subscriptionID,
            publicationID: publicationID,
            args: args,
            kwargs: kwargs,
            details: details
        )
    }

    public init(withFields eventFields: IEventFields) {
        self.eventFields = eventFields
    }

    public var subscriptionID: Int64 { eventFields.subscriptionID }
    public var publicationID: Int64 { eventFields.publicationID }
    public var args: [any Sendable]? { eventFields.args }
    public var kwargs: [String: any Sendable]? { eventFields.kwargs }
    public var details: [String: any Sendable] { eventFields.details }
    public var payload: Data? { eventFields.payload }
    public var payloadSerializer: Int { eventFields.payloadSerializer }
    public var payloadIsBinary: Bool { eventFields.payloadIsBinary }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Event(subscriptionID: fields.subscriptionID!, publicationID: fields.publicationID!,
                     args: fields.args, kwargs: fields.kwArgs, details: fields.details ?? [:])
    }

    public func marshal() -> [any Sendable] {
        var message: [any Sendable] = [Event.id, subscriptionID, publicationID, details]

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

    public var type: Int64 {
        Event.id
    }
}
