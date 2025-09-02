// swiftlint:disable identifier_name
func asUInt64(_ x: some BinaryInteger) -> UInt64 {
    UInt64(truncatingIfNeeded: x)
}

func asInt(_ x: some BinaryInteger) -> Int {
    Int(x)
}

func cast<T>(_ value: Any, to _: T.Type) -> T? {
    value as? T
}

public func toUInt64Strict(_ value: any Sendable) -> UInt64? {
    switch value {
    case let v as UInt64:
        v
    case let v as Int64:
        v >= 0 ? UInt64(v) : nil
    case let v as Int:
        v >= 0 ? UInt64(v) : nil
    case let v as UInt:
        UInt64(v)
    case let v as Double:
        // Check if the value is an integer and non-negative
        v >= 0 && v.rounded() == v ? UInt64(v) : nil
    case let v as Float:
        v >= 0 && v.rounded() == v ? UInt64(v) : nil
    case let v as String:
        UInt64(v) // Returns nil if the string is invalid or negative
    default:
        nil
    }
}

public func toIntStrict(_ value: any Sendable) -> Int? {
    switch value {
    case let v as Int:
        // Already an Int
        return v

    case let v as Int64:
        // Check if fits into Int range
        return v >= Int.min && v <= Int.max ? Int(v) : nil

    case let v as UInt64:
        // UInt64 must fit into Int.max
        return v <= UInt64(Int.max) ? Int(v) : nil

    case let v as UInt:
        return v <= UInt(Int.max) ? Int(v) : nil

    case let v as Double:
        // Accept only if it's an exact integer and fits in Int
        guard v.rounded() == v,
              v >= Double(Int.min),
              v <= Double(Int.max)
        else { return nil }
        return Int(v)

    case let v as Float:
        // Same as Double
        guard v.rounded() == v,
              v >= Float(Int.min),
              v <= Float(Int.max)
        else { return nil }
        return Int(v)

    case let v as String:
        // Accept valid string integers only
        return Int(v)

    default:
        return nil
    }
}
// swiftlint:enable identifier_name
