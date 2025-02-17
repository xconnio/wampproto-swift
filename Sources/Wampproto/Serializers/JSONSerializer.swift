import Foundation

class JSONSerializer: Serializer {
    func serialize(message: Message) throws -> Any {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: message.marshal())

            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw SerializerError.serializationError("Failed to convert JSON data to string.")
            }

            return jsonString
        } catch {
            throw SerializerError.serializationError("Error serializing message: \(error)")
        }
    }

    func deserialize(data: Any) throws -> Message {
        guard let msg = data as? String else {
            throw SerializerError.invalidMessageFormat
        }

        let data = Data(msg.utf8)
        do {
            guard let wampMessage = try JSONSerialization.jsonObject(with: data) as? [Any] else {
                throw SerializerError.deserializationError("Failed to deserialize JSON to Message")
            }
            return try toMessage(data: wampMessage)
        } catch {
            throw SerializerError.deserializationError("Error decoding JSON: \(error)")
        }
    }

}
