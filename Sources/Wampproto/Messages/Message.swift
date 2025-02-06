import Foundation

protocol Message {
    var type: Int { get }
    static func parse(message: [Any])throws -> Message
    func marshal() -> [Any]
}
