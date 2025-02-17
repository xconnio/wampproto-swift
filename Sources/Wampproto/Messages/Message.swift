import Foundation

protocol Message {
    var type: Int64 { get }
    static func parse(message: [Any])throws -> Message
    func marshal() -> [Any]
}

protocol BinaryPayload {
    var payloadIsBinary: Bool { get }
    var payload: Data? { get }
    var payloadSerializer: Int { get }
}
