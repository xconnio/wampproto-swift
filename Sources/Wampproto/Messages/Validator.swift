import Foundation

enum ValidationError: Swift.Error {
    case invalidType(index: Int, expected: String, actual: String)
    case unexpectedLength(min: Int, max: Int, actual: Int)
    case missingField(String)
    case multipleErrors([ValidationError])

    var error: String {
        switch self {
        case .invalidType(let index, let expected, let actual):
            return "Item at index \(index) must be of type \(expected) but was \(actual)"
        case .unexpectedLength(let min, let max, let actual):
            return "Unexpected message length, must be at least \(min) and at most \(max), but was \(actual)"
        case .missingField(let field):
            return "Missing required field: \(field)"
        case .multipleErrors(let errors):
            let errorMessages = errors.map { $0.error }
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
    var requestID: Int64?
    var uri: String?
    var args: [Any]?
    var kwArgs: [String: Any]?
    var sessionID: Int64?
    var realm: String?
    var authID: String?
    var authRole: String?
    var authMethod: String?
    var authMethods: [String]?
    var authExtra: [String: Any]?
    var roles: [String: Any]?
    var messageType: Int64?
    var signature: String?
    var reason: String?
    var topic: String?
    var extra: [String: Any]?
    var options: [String: Any]?
    var details: [String: Any]?
    var subscriptionID: Int64?
    var publicationID: Int64?
    var registrationID: Int64?
}

func sanityCheck(wampMsg: [Any], minLength: Int, maxLength: Int) throws {
    let length = wampMsg.count
    if length < minLength || length > maxLength {
        throw ValidationError.unexpectedLength(min: minLength, max: maxLength, actual: length)
    }
}

func validateID(wampMsg: [Any], index: Int) throws -> Int64 {
    guard let value = wampMsg[index] as? Int64 else {
        throw ValidationError.invalidType(index: index, expected: "Int64", actual: "\(type(of: wampMsg[index]))")
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
    fields.args = try validateArray(wampMsg: wampMsg, index: index)
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

func validateTopic(wampMsg: [Any], index: Int, fields: Fields) throws {
    fields.topic = try validateString(wampMsg: wampMsg, index: index)
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
    fields.kwArgs = try validateMap(wampMsg: wampMsg, index: index)
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
