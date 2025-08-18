import Foundation

public protocol Message {
    var type: Int64 { get }
    static func parse(message: [Any]) throws -> Message
    func marshal() -> [Any]
}

public protocol BinaryPayload {
    var payloadIsBinary: Bool { get }
    var payload: Data? { get }
    var payloadSerializer: Int { get }
}
