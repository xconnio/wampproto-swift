import Foundation

let maxID: Int64 = 1 << 53

func generateSessionID() -> Int64 {
    Int64.random(in: 0 ..< maxID)
}

class SessionScopeIDGenerator {
    var id: Int64 = 0

    func next() -> Int64 {
        if id == maxID {
            id = 0
        }

        id += 1
        return id
    }
}
