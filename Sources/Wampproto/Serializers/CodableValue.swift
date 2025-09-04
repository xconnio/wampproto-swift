import Foundation

/// A wrapper type that can handle various Sendable types for MessagePack encoding/decoding
enum CodableValue: Codable, Sendable {
    case null
    case bool(Bool)
    case int(Int)
    case int8(Int8)
    case int16(Int16)
    case int32(Int32)
    case int64(Int64)
    case uint(UInt)
    case uint8(UInt8)
    case uint16(UInt16)
    case uint32(UInt32)
    case uint64(UInt64)
    case float(Float)
    case double(Double)
    case string(String)
    case data(Data)
    case array([CodableValue])
    case dictionary([String: CodableValue])

    init(from value: (any Sendable)?) {
        guard let value else {
            self = .null
            return
        }

        switch value {
        case let bool as Bool:
            self = .bool(bool)
        case let int as Int:
            self = .int(int)
        case let int8 as Int8:
            self = .int8(int8)
        case let int16 as Int16:
            self = .int16(int16)
        case let int32 as Int32:
            self = .int32(int32)
        case let int64 as Int64:
            self = .int64(int64)
        case let uint as UInt:
            self = .uint(uint)
        case let uint8 as UInt8:
            self = .uint8(uint8)
        case let uint16 as UInt16:
            self = .uint16(uint16)
        case let uint32 as UInt32:
            self = .uint32(uint32)
        case let uint64 as UInt64:
            self = .uint64(uint64)
        case let float as Float:
            self = .float(float)
        case let double as Double:
            self = .double(double)
        case let string as String:
            self = .string(string)
        case let data as Data:
            self = .data(data)
        case let array as [any Sendable]:
            self = .array(array.map { CodableValue(from: $0) })
        case let array as [(any Sendable)?]:
            self = .array(array.map { CodableValue(from: $0) })
        case let dict as [String: any Sendable]:
            self = .dictionary(dict.mapValues { CodableValue(from: $0) })
        case let dict as [String: (any Sendable)?]:
            self = .dictionary(dict.mapValues { CodableValue(from: $0) })
        default:
            // For any other type, try to convert to string
            self = .string(String(describing: value))
        }
    }

    var extractedValue: any Sendable {
        switch self {
        case .null:
            nil as (any Sendable)?
        case let .bool(value):
            value
        case let .int(value):
            value
        case let .int8(value):
            value
        case let .int16(value):
            value
        case let .int32(value):
            value
        case let .int64(value):
            value
        case let .uint(value):
            value
        case let .uint8(value):
            value
        case let .uint16(value):
            value
        case let .uint32(value):
            value
        case let .uint64(value):
            value
        case let .float(value):
            value
        case let .double(value):
            value
        case let .string(value):
            value
        case let .data(value):
            value
        case let .array(values):
            values.map(\.extractedValue)
        case let .dictionary(dict):
            dict.mapValues { $0.extractedValue }
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let data = try? container.decode(Data.self) {
            self = .data(data)
        } else if let array = try? container.decode([CodableValue].self) {
            self = .array(array)
        } else if let dict = try? container.decode([String: CodableValue].self) {
            self = .dictionary(dict)
        } else {
            throw DecodingError.typeMismatch(
                CodableValue.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unable to decode SendableValue"
                )
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .null:
            try container.encodeNil()
        case let .bool(value):
            try container.encode(value)
        case let .int(value):
            try container.encode(value)
        case let .int8(value):
            try container.encode(value)
        case let .int16(value):
            try container.encode(value)
        case let .int32(value):
            try container.encode(value)
        case let .int64(value):
            try container.encode(value)
        case let .uint(value):
            try container.encode(value)
        case let .uint8(value):
            try container.encode(value)
        case let .uint16(value):
            try container.encode(value)
        case let .uint32(value):
            try container.encode(value)
        case let .uint64(value):
            try container.encode(value)
        case let .float(value):
            try container.encode(value)
        case let .double(value):
            try container.encode(value)
        case let .string(value):
            try container.encode(value)
        case let .data(value):
            try container.encode(value)
        case let .array(values):
            try container.encode(values)
        case let .dictionary(dict):
            try container.encode(dict)
        }
    }
}
