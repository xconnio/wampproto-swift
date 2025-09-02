import Foundation

let maxID: UInt64 = 1 << 53

public func generateSessionID() -> UInt64 {
    UInt64.random(in: 0 ..< maxID)
}

public struct SessionScopeIDGenerator: Sendable {
    var id: UInt64 = 0

    public init() {}

    public mutating func next() -> UInt64 {
        if id == maxID {
            id = 0
        }

        id += 1
        return id
    }
}
