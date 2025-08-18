import Foundation

protocol IInterruptFields {
    var requestID: Int64 { get }
    var options: [String: Any] { get }
}

class InterruptFields: IInterruptFields {
    let requestID: Int64
    let options: [String: Any]

    init(requestID: Int64, options: [String: Any] = [:]) {
        self.requestID = requestID
        self.options = options
    }
}

class Interrupt: Message {
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

    init(requestID: Int64, options: [String: Any] = [:]) {
        interruptFields = InterruptFields(requestID: requestID, options: options)
    }

    init(withFields interruptFields: IInterruptFields) {
        self.interruptFields = interruptFields
    }

    var requestID: Int64 { interruptFields.requestID }
    var options: [String: Any] { interruptFields.options }

    static func parse(message: [Any]) throws -> Message {
        let fields = try validateMessage(wampMsg: message, spec: validationSpec)

        return Interrupt(requestID: fields.requestID!, options: fields.options ?? [:])
    }

    func marshal() -> [Any] {
        [Interrupt.id, requestID, options]
    }

    var type: Int64 {
        Interrupt.id
    }
}
