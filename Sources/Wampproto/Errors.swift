import Foundation

public struct ApplicationError: Swift.Error, CustomStringConvertible {
    public let message: String
    public let args: [any Sendable]?
    public let kwargs: [String: any Sendable]?

    public init(message: String, args: [any Sendable]? = nil, kwargs: [String: any Sendable]? = nil) {
        self.message = message
        self.args = args
        self.kwargs = kwargs
    }

    public var description: String {
        var errStr = message
        if let args, !args.isEmpty {
            let argsStr = args.map { "\($0)" }.joined(separator: ", ")
            errStr += ": \(argsStr)"
        }
        if let kwargs, !kwargs.isEmpty {
            let kwargsStr = kwargs.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
            errStr += ": \(kwargsStr)"
        }
        return errStr
    }
}

public struct ProtocolError: Swift.Error {
    let message: String
    public init(message: String) {
        self.message = message
    }
}

public struct SessionNotReady: Swift.Error {
    let message: String
    public init(message: String) {
        self.message = message
    }
}
