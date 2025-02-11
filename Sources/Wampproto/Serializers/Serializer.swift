import Foundation

protocol Serializer {
    func serialize(message: Message) throws -> Any
    func deserialize(data: Any) throws -> Message
}

enum SerializerError: Error {
    case serializationError(String)
    case deserializationError(String)
    case invalidMessageFormat
}

enum MessageParsingError: Error {
    case unsupportedType(Int64)
    case parseFailure(String)
}

func toMessage(data: [Any]) throws -> Message {
    guard let type = data.first as? Int64 else {
        throw MessageParsingError.parseFailure("Data is not in the expected format")
    }

    switch type {
    case Hello.id:
        return try Hello.parse(message: data)
    case Challenge.id:
        return try Challenge.parse(message: data)
    default:
        throw MessageParsingError.unsupportedType(type)
    }
}
