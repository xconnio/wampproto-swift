import Foundation

public struct JSONSerializer: Serializer {
    public init() {}
    public func serialize(message: Message) throws -> SerializedMessage {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: message.marshal())

            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw SerializerError.serializationError("Failed to convert JSON data to string.")
            }

            return .string(jsonString)
        } catch {
            throw SerializerError.serializationError("Error serializing message: \(error)")
        }
    }

    public func deserialize(data: SerializedMessage) throws -> Message {
        guard case let .string(jsonString) = data else {
            throw SerializerError.invalidMessageFormat
        }

        guard let jsonString = jsonString.data(using: .utf8) else {
            throw SerializerError.invalidMessageFormat
        }

        do {
            guard let wampMessage = try JSONSerialization.jsonObject(with: jsonString) as? [Any] else {
                throw SerializerError.deserializationError("Failed to deserialize JSON to Message")
            }
            return try toMessage(data: wampMessage)
        } catch {
            throw SerializerError.deserializationError("Error decoding JSON: \(error)")
        }
    }
}
