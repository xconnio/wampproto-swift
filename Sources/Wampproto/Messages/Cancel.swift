import Foundation

public protocol ICancelFields: Sendable {
    var requestID: Int64 { get }
    var options: [String: any Sendable] { get }
}

public struct CancelFields: ICancelFields {
    public var requestID: Int64
    public var options: [String: any Sendable]

    public init(requestID: Int64, options: [String: any Sendable] = [:]) {
        self.requestID = requestID
        self.options = options
    }
}

public struct Cancel: Message {
    private var cancelFields: ICancelFields

    public static let id: Int64 = 49
    public static let text = "CANCEL"

    static let validationSpec = ValidationSpec(
        minLength: 3,
        maxLength: 3,
        message: Cancel.text,
        spec: [
            1: validateRequestID,
            2: validateOptions
        ]
    )

    public init(requestID: Int64, options: [String: any Sendable] = [:]) {
        cancelFields = CancelFields(requestID: requestID, options: options)
    }

    public init(withFields cancelFields: ICancelFields) {
        self.cancelFields = cancelFields
    }

    public var requestID: Int64 { cancelFields.requestID }
    public var options: [String: any Sendable] { cancelFields.options }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Cancel(requestID: fields.requestID!, options: fields.options ?? [:])
    }

    public func marshal() -> [any Sendable] {
        [Cancel.id, requestID, options]
    }

    public var type: Int64 {
        Cancel.id
    }
}
