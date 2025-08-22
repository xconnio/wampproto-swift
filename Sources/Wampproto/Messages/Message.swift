import Foundation

public protocol Message: Sendable {
    var type: Int64 { get }
    static func parse(message: [any Sendable]) throws -> Message
    func marshal() -> [any Sendable]
}

public protocol BinaryPayload {
    var payloadIsBinary: Bool { get }
    var payload: Data? { get }
    var payloadSerializer: Int { get }
}
