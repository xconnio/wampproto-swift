import Foundation

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
