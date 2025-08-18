import Foundation
import SwiftCBOR

public class CBORSerializer: Serializer {
    public init() {}
    public func serialize(message: Message) throws -> SerializedMessage {
        let cborData = CBOR.encode(toCBORArray(message.marshal()))
        return .data(Data(cborData))
    }

    public func deserialize(data: SerializedMessage) throws -> Message {
        guard case let .data(data) = data else {
            throw SerializerError.invalidMessageFormat
        }

        guard case let .array(unpacked) = try CBOR.decode([UInt8](data)) else {
            throw SerializerError.invalidMessageFormat
        }

        do {
            return try toMessage(data: unpacked.map(fromCBORValue))
        } catch {
            throw SerializerError.deserializationError("Error decoding CBOR: \(error)")
        }
    }
}

private func toCBORArray(_ array: [Any]) -> [CBOR] {
    array.compactMap { toCBORValue($0) }
}

private func toCBORMap(_ dict: [String: Any]) -> [CBOR: CBOR] {
    var result: [CBOR: CBOR] = [:]
    for (key, value) in dict {
        if let valueCBOR = toCBORValue(value) {
            result[CBOR.utf8String(key)] = valueCBOR
        }
    }
    return result
}

private func toCBORValue(_ value: Any) -> CBOR? {
    if let number = convertToUnsignedInt(value) {
        return number
    }

    switch value {
    case let str as String:
        return CBOR.utf8String(str)
    case let bool as Bool:
        return CBOR.boolean(bool)
    case let double as Double:
        return CBOR.double(double)
    case let array as [Any]:
        return CBOR.array(toCBORArray(array))
    case let dict as [String: Any]:
        return CBOR.map(toCBORMap(dict))
    default:
        return nil
    }
}

private func convertToUnsignedInt(_ value: Any) -> CBOR? {
    switch value {
    case let int as Int:
        return int >= 0 ? CBOR.unsignedInt(UInt64(int)) : CBOR.negativeInt(~UInt64(int))
    case let int32 as Int32:
         return int32 >= 0 ? CBOR.unsignedInt(UInt64(int32)) : CBOR.negativeInt(~UInt64(int32))
    case let int64 as Int64:
        return int64 >= 0 ? CBOR.unsignedInt(UInt64(int64)) : CBOR.negativeInt(~UInt64(int64))
    case let uint as UInt:
        return CBOR.unsignedInt(UInt64(uint))
    case let uint32 as UInt32:
        return CBOR.unsignedInt(UInt64(uint32))
    case let uint64 as UInt64:
        return CBOR.unsignedInt(uint64)
    default:
        return nil
    }
}

private func fromCBORArray(_ array: [CBOR]) -> [Any] {
    array.map { fromCBORValue($0) }
}

private func fromCBORMap(_ dict: [CBOR: CBOR]) -> [String: Any] {
    var result: [String: Any] = [:]
    for (key, value) in dict {
        if case let .utf8String(keyStr) = key {
            result[keyStr] = fromCBORValue(value)
        }
    }
    return result
}

private func fromCBORValue(_ value: CBOR) -> Any {
    switch value {
    case let .utf8String(str):
        str
    case let .unsignedInt(int):
        Int64(int)
    case let .negativeInt(int):
        Int64(int)
    case let .boolean(bool):
        bool
    case let .double(double):
        double
    case let .array(array):
        fromCBORArray(array)
    case let .map(dict):
        fromCBORMap(dict)
    default:
        NSNull()
    }
}
