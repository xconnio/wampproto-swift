import Foundation

public enum SerializedMessage: Sendable {
    case string(String)
    case data(Data)
}

public protocol Serializer {
    func serialize(message: Message) throws -> SerializedMessage
    func deserialize(data: SerializedMessage) throws -> Message
}

public enum SerializerError: Swift.Error {
    case serializationError(String)
    case deserializationError(String)
    case invalidMessageFormat
}

enum MessageParsingError: Swift.Error {
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
    case Authenticate.id:
        return try Authenticate.parse(message: data)
    case Welcome.id:
        return try Welcome.parse(message: data)
    case Abort.id:
        return try Abort.parse(message: data)
    case Error.id:
        return try Error.parse(message: data)
    case Cancel.id:
        return try Cancel.parse(message: data)
    case Interrupt.id:
        return try Interrupt.parse(message: data)
    case Goodbye.id:
        return try Goodbye.parse(message: data)
    case Register.id:
        return try Register.parse(message: data)
    case Registered.id:
        return try Registered.parse(message: data)
    case Unregister.id:
        return try Unregister.parse(message: data)
    case Unregistered.id:
        return try Unregistered.parse(message: data)
    case Call.id:
        return try Call.parse(message: data)
    case Invocation.id:
        return try Invocation.parse(message: data)
    case Yield.id:
        return try Yield.parse(message: data)
    case Result.id:
        return try Result.parse(message: data)
    case Subscribe.id:
        return try Subscribe.parse(message: data)
    case Subscribed.id:
        return try Subscribed.parse(message: data)
    case Unsubscribe.id:
        return try Unsubscribe.parse(message: data)
    case Unsubscribed.id:
        return try Unsubscribed.parse(message: data)
    case Publish.id:
        return try Publish.parse(message: data)
    case Published.id:
        return try Published.parse(message: data)
    case Event.id:
        return try Event.parse(message: data)
    default:
        throw MessageParsingError.unsupportedType(type)
    }
}
