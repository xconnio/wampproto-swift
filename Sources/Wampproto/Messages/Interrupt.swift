import Foundation

public protocol IInterruptFields: Sendable {
    var requestID: Int64 { get }
    var options: [String: any Sendable] { get }
}

public struct InterruptFields: IInterruptFields {
    public let requestID: Int64
    public let options: [String: any Sendable]

    init(requestID: Int64, options: [String: any Sendable] = [:]) {
        self.requestID = requestID
        self.options = options
    }
}

public struct Interrupt: Message {
    private var interruptFields: IInterruptFields

    static let id: Int64 = 69
    static let text = "INTERRUPT"

    static let validationSpec = ValidationSpec(
        minLength: 3,
        maxLength: 3,
        message: Interrupt.text,
        spec: [
            1: validateRequestID,
            2: validateOptions
        ]
    )

    public init(requestID: Int64, options: [String: any Sendable] = [:]) {
        interruptFields = InterruptFields(requestID: requestID, options: options)
    }

    public init(withFields interruptFields: IInterruptFields) {
        self.interruptFields = interruptFields
    }

    public var requestID: Int64 { interruptFields.requestID }
    public var options: [String: any Sendable] { interruptFields.options }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Interrupt(requestID: fields.requestID!, options: fields.options ?? [:])
    }

    public func marshal() -> [any Sendable] {
        [Interrupt.id, requestID, options]
    }

    public var type: Int64 {
        Interrupt.id
    }
}
