import Foundation

let maxID: Int64 = 1 << 53

public func generateSessionID() -> Int64 {
    Int64.random(in: 0 ..< maxID)
}

public struct SessionScopeIDGenerator: Sendable {
    var id: Int64 = 0

    public init() {}

    public mutating func next() -> Int64 {
        if id == maxID {
            id = 0
        }

        id += 1
        return id
    }
}
