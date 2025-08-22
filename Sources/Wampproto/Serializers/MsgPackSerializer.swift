import Foundation
import SwiftMsgPack

public struct MsgPackSerializer: Serializer {
    public init() {}
    public func serialize(message: Message) throws -> SerializedMessage {
        var data = Data()
        let encodedMessage = try data.pack(message.marshal())
        return .data(encodedMessage)
    }

    public func deserialize(data: SerializedMessage) throws -> Message {
        guard case let .data(msg) = data else {
            throw SerializerError.invalidMessageFormat
        }

        guard let unpacked = try msg.unpack() as? [Any?] else {
            throw SerializerError.invalidMessageFormat
        }

        let deserializedArray = unpacked.compactMap(unwrapValue)

        do {
            return try toMessage(data: deserializedArray)
        } catch {
            throw SerializerError.deserializationError("Error decoding MsgPack: \(error)")
        }
    }
}

private func unwrapValue(_ value: Any?) -> Any {
    switch value {
    case let array as [Any?]:
        array.compactMap(unwrapValue)

    case let dict as [AnyHashable: Any?]:
        dict.reduce(into: [String: Any]()) { result, element in
            if let key = element.key as? String {
                result[key] = unwrapValue(element.value)
            }
        }

    case let number as NSNumber:
        if CFNumberIsFloatType(number) {
            number.doubleValue
        } else {
            number.int64Value // Converts all integer types to Int64
        }

    case let unwrapped as String:
        unwrapped

    case let unwrapped as Bool:
        unwrapped

    default:
        value ?? NSNull()
    }
}
