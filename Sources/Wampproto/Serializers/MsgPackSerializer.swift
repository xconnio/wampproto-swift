import Foundation
import MessagePack

public struct MsgPackSerializer: Serializer {
    private let handler: MessagePackHandler = .init()
    public init() {}
    public func serialize(message: Message) throws -> SerializedMessage {
        let encodedMessage = try handler.encode(message.marshal())
        return .data(encodedMessage)
    }

    public func deserialize(data: SerializedMessage) throws -> Message {
        guard case let .data(msg) = data else {
            throw SerializerError.invalidMessageFormat
        }

        do {
            let deserializedArray = try handler.decodeArray(msg)
            return try toMessage(data: deserializedArray)
        } catch {
            throw SerializerError.deserializationError("Error decoding MsgPack: \(error)")
        }
    }
}

class MessagePackHandler: @unchecked Sendable {
    private let encoder: MessagePackEncoder
    private let decoder: MessagePackDecoder

    init() {
        encoder = MessagePackEncoder()
        decoder = MessagePackDecoder()
    }

    func encode(_ value: (any Sendable)?) throws -> Data {
        let wrappedValue = CodableValue(from: value)
        return try encoder.encode(wrappedValue)
    }

    func encode(_ values: [(any Sendable)?]) throws -> Data {
        let wrappedValues = values.map { CodableValue(from: $0) }
        return try encoder.encode(wrappedValues)
    }

    func encode(_ dictionary: [String: (any Sendable)?]) throws -> Data {
        let wrappedDict = dictionary.mapValues { CodableValue(from: $0) }
        return try encoder.encode(wrappedDict)
    }

    func decode(_ data: Data) throws -> any Sendable {
        let wrappedValue = try decoder.decode(CodableValue.self, from: data)
        return wrappedValue.extractedValue
    }

    func decodeArray(_ data: Data) throws -> [any Sendable] {
        let wrappedValues = try decoder.decode([CodableValue].self, from: data)
        return wrappedValues.map(\.extractedValue)
    }

    func decodeDictionary(_ data: Data) throws -> [String: any Sendable] {
        let wrappedDict = try decoder.decode([String: CodableValue].self, from: data)
        return wrappedDict.mapValues { $0.extractedValue }
    }

    func decodeAuto(_ data: Data) throws -> any Sendable {
        if let array = try? decodeArray(data) {
            return array
        }
        if let dict = try? decodeDictionary(data) {
            return dict
        }
        return try decode(data)
    }
}
