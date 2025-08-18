import Foundation

class ApplicationError: Swift.Error, CustomStringConvertible {
    let message: String
    let args: [Any]?
    let kwargs: [String: Any]?

    init(message: String, args: [Any]? = nil, kwargs: [String: Any]? = nil) {
        self.message = message
        self.args = args
        self.kwargs = kwargs
    }

    var description: String {
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

class ProtocolError: Swift.Error {
    let message: String

    init(message: String) {
        self.message = message
    }
}

class SessionNotReady: Swift.Error {
    let message: String

    init(message: String) {
        self.message = message
    }
}
