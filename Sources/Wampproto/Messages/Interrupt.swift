import Foundation

public protocol IInterruptFields: Sendable {
    var requestID: UInt64 { get }
    var options: [String: any Sendable] { get }
}

public struct InterruptFields: IInterruptFields {
    public let requestID: UInt64
    public let options: [String: any Sendable]

    init(requestID: UInt64, options: [String: any Sendable] = [:]) {
        self.requestID = requestID
        self.options = options
    }
}

public struct Interrupt: Message {
    private var interruptFields: IInterruptFields

    public static let id: UInt64 = 69
    public static let text = "INTERRUPT"

    static let validationSpec = ValidationSpec(
        minLength: 3,
        maxLength: 3,
        message: Interrupt.text,
        spec: [
            1: validateRequestID,
            2: validateOptions
        ]
    )

    public init(requestID: UInt64, options: [String: any Sendable] = [:]) {
        interruptFields = InterruptFields(requestID: requestID, options: options)
    }

    public init(withFields interruptFields: IInterruptFields) {
        self.interruptFields = interruptFields
    }

    public var requestID: UInt64 { interruptFields.requestID }
    public var options: [String: any Sendable] { interruptFields.options }

    public static func parse(message: [any Sendable]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Interrupt(requestID: fields.requestID!, options: fields.options ?? [:])
    }

    public func marshal() -> [any Sendable] {
        [Interrupt.id, requestID, options]
    }

    public var type: UInt64 {
        Interrupt.id
    }
}
