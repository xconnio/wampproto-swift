import Foundation

enum ValidationError: Swift.Error {
    case invalidType(index: Int, expected: String, actual: String)
    case unexpectedLength(min: Int, max: Int, actual: Int)
    case missingField(String)
    case multipleErrors([ValidationError])

    var error: String {
        switch self {
        case let .invalidType(index, expected, actual):
            return "Item at index \(index) must be of type \(expected) but was \(actual)"
        case let .unexpectedLength(min, max, actual):
            return "Unexpected message length, must be at least \(min) and at most \(max), but was \(actual)"
        case let .missingField(field):
            return "Missing required field: \(field)"
        case let .multipleErrors(errors):
            let errorMessages = errors.map(\.error)
            return "Validation failed: \n" + errorMessages.joined(separator: "\n")
        }
    }
}

typealias Validator = ([Any], Int, Fields) throws -> Void

typealias Spec = [Int: Validator]

struct ValidationSpec {
    var minLength: Int
    var maxLength: Int
    var message: String
    var spec: Spec
}

class Fields {
    var requestID: UInt64?
    var uri: String?
    var args: [any Sendable]?
    var kwArgs: [String: any Sendable]?
    var sessionID: UInt64?
    var realm: String?
    var authID: String?
    var authRole: String?
    var authMethod: String?
    var authMethods: [String]?
    var authExtra: [String: any Sendable]?
    var roles: [String: any Sendable]?
    var messageType: UInt64?
    var signature: String?
    var reason: String?
    var extra: [String: any Sendable]?
    var options: [String: any Sendable]?
    var details: [String: any Sendable]?
    var subscriptionID: UInt64?
    var publicationID: UInt64?
    var registrationID: UInt64?
}

func sanityCheck(wampMsg: [Any], minLength: Int, maxLength: Int) throws {
    let length = wampMsg.count
    if length < minLength || length > maxLength {
        throw ValidationError.unexpectedLength(min: minLength, max: maxLength, actual: length)
    }
}

func validateID(wampMsg: [Any], index: Int) throws -> UInt64 {
    guard let value = toUInt64Strict(wampMsg[index]) else {
        throw ValidationError.invalidType(index: index, expected: "UInt64", actual: "\(type(of: wampMsg[index]))")
    }
    return value
}

func validateString(wampMsg: [Any], index: Int) throws -> String {
    guard let value = wampMsg[index] as? String else {
        throw ValidationError.invalidType(index: index, expected: "String", actual: "\(type(of: wampMsg[index]))")
    }
    return value
}

func validateArray(wampMsg: [Any], index: Int) throws -> [Any] {
    guard let value = wampMsg[index] as? [Any] else {
        throw ValidationError.invalidType(index: index, expected: "[Any]", actual: "\(type(of: wampMsg[index]))")
    }
    return value
}

func validateMap(wampMsg: [Any], index: Int) throws -> [String: Any] {
    guard let value = wampMsg[index] as? [String: Any] else {
        throw ValidationError.invalidType(index: index, expected: "[String: Any]",
                                          actual: "\(type(of: wampMsg[index]))")
    }
    return value
}

func validateArgs(wampMsg: [Any], index: Int, fields: Fields) throws {
    if wampMsg.count > index {
        fields.args = try validateArray(wampMsg: wampMsg, index: index)
    }
}

func validateSessionID(wampMsg: [Any], index: Int, fields: Fields) throws {
    fields.sessionID = try validateID(wampMsg: wampMsg, index: index)
}

func validateMessageType(wampMsg: [Any], index: Int, fields: Fields) throws {
    fields.messageType = try validateID(wampMsg: wampMsg, index: index)
}

func validateRequestID(wampMsg: [Any], index: Int, fields: Fields) throws {
    fields.requestID = try validateID(wampMsg: wampMsg, index: index)
}

func validateRegistrationID(wampMsg: [Any], index: Int, fields: Fields) throws {
    fields.registrationID = try validateID(wampMsg: wampMsg, index: index)
}

func validatePublicationID(wampMsg: [Any], index: Int, fields: Fields) throws {
    fields.publicationID = try validateID(wampMsg: wampMsg, index: index)
}

func validateSubscriptionID(wampMsg: [Any], index: Int, fields: Fields) throws {
    fields.subscriptionID = try validateID(wampMsg: wampMsg, index: index)
}

func validateSignature(wampMsg: [Any], index: Int, fields: Fields) throws {
    fields.signature = try validateString(wampMsg: wampMsg, index: index)
}

func validateURI(wampMsg: [Any], index: Int, fields: Fields) throws {
    fields.uri = try validateString(wampMsg: wampMsg, index: index)
}

func validateRealm(wampMsg: [Any], index: Int, fields: Fields) throws {
    fields.realm = try validateString(wampMsg: wampMsg, index: index)
}

func validateAuthMethod(wampMsg: [Any], index: Int, fields: Fields) throws {
    fields.authMethod = try validateString(wampMsg: wampMsg, index: index)
}

func validateReason(wampMsg: [Any], index: Int, fields: Fields) throws {
    fields.reason = try validateString(wampMsg: wampMsg, index: index)
}

func validateExtra(wampMsg: [Any], index: Int, fields: Fields) throws {
    fields.extra = try validateMap(wampMsg: wampMsg, index: index)
}

func validateOptions(wampMsg: [Any], index: Int, fields: Fields) throws {
    fields.options = try validateMap(wampMsg: wampMsg, index: index)
}

func validateDetails(wampMsg: [Any], index: Int, fields: Fields) throws {
    fields.details = try validateMap(wampMsg: wampMsg, index: index)
}

func validateKWArgs(wampMsg: [Any], index: Int, fields: Fields) throws {
    if wampMsg.count > index {
        fields.kwArgs = try validateMap(wampMsg: wampMsg, index: index)
    }
}

func validateMessage(wampMsg: [Any], spec: ValidationSpec) throws -> Fields {
    try sanityCheck(wampMsg: wampMsg, minLength: spec.minLength, maxLength: spec.maxLength)

    let fields = Fields()
    var errors: [ValidationError] = []

    for (index, validator) in spec.spec {
        do {
            try validator(wampMsg, index, fields)
        } catch let validationError as ValidationError {
            errors.append(validationError)
        }
    }

    if !errors.isEmpty {
        throw ValidationError.multipleErrors(errors)
    }

    return fields
}
