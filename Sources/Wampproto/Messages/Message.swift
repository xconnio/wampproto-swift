import Foundation

protocol Message {
    var type: Int64 { get }
    static func parse(message: [Any])throws -> Message
    func marshal() -> [Any]
}
