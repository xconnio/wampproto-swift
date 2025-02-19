import Foundation
import SwiftMsgPack

class MsgPackSerializer: Serializer {
    func serialize(message: Message) throws -> Any {
        var data = Data()
        return try data.pack(message.marshal())
    }

    func deserialize(data: Any) throws -> Message {
            guard let msg = data as? Data,
                  let unpacked = try msg.unpack() as? [Any?] else {
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
        return array.compactMap(unwrapValue)

    case let dict as [AnyHashable: Any?]:
        return dict.reduce(into: [String: Any]()) { result, element in
            if let key = element.key as? String {
                result[key] = unwrapValue(element.value)
            }
        }

    case let number as NSNumber:
        if CFNumberIsFloatType(number) {
            return number.doubleValue
        } else {
            return number.int64Value  // Converts all integer types to Int64
        }

    case let unwrapped as String:
        return unwrapped

    case let unwrapped as Bool:
        return unwrapped

    default:
        return value ?? NSNull()
    }
}
