import Foundation

public struct Session {
    private let serializer: Serializer
    // data structures for RPC
    private var callRequests = [Int64: Int64]()
    private var registerRequests = [Int64: Int64]()
    private var registrations = [Int64: Int64]()
    private var invocationRequests = [Int64: Int64]()
    private var unregisterRequests = [Int64: Int64]()

    // data structures for PubSub
    private var publishRequests = [Int64: Int64]()
    private var subscribeRequests = [Int64: Int64]()
    private var subscriptions = [Int64: Int64]()
    private var unsubscribeRequests = [Int64: Int64]()

    public init(serializer: Serializer = JSONSerializer()) {
        self.serializer = serializer
    }

    public mutating func sendMessage(msg: Message) throws -> SerializedMessage {
        switch msg {
        case let msg as Call:
            callRequests[msg.requestID] = msg.requestID
            return try serializer.serialize(message: msg)

        case let msg as Register:
            registerRequests[msg.requestID] = msg.requestID
            return try serializer.serialize(message: msg)

        case let msg as Unregister:
            unregisterRequests[msg.requestID] = msg.registrationID
            return try serializer.serialize(message: msg)

        case let msg as Yield:
            if !invocationRequests.keys.contains(msg.requestID) {
                throw ProtocolError(message: "cannot yield for unknown invocation request")
            }

            invocationRequests.removeValue(forKey: msg.requestID)
            return try serializer.serialize(message: msg)

        case let msg as Publish:
            if let acknowledge = msg.options["acknowledge"] as? Bool, acknowledge {
                publishRequests[msg.requestID] = msg.requestID
            }

            return try serializer.serialize(message: msg)

        case let msg as Subscribe:
            subscribeRequests[msg.requestID] = msg.requestID
            return try serializer.serialize(message: msg)

        case let msg as Unsubscribe:
            unsubscribeRequests[msg.requestID] = msg.subscriptionID
            return try serializer.serialize(message: msg)

        case let msg as Error:
            if msg.messageType != Invocation.id {
                throw ProtocolError(message: "Send only supported for invocation error")
            }

            invocationRequests.removeValue(forKey: msg.requestID)
            return try serializer.serialize(message: msg)

        case let msg as Goodbye:
            return try serializer.serialize(message: msg)

        default:
            throw ProtocolError(message: "Unknown message \(msg)")
        }
    }

    public mutating func receive(data: SerializedMessage) throws -> Message {
        let msg = try serializer.deserialize(data: data)
        return try receiveMessage(msg: msg)
    }

    private mutating func receiveMessage(msg: Message) throws -> Message {
        switch msg {
        case let msg as Result:
            guard callRequests.keys.contains(msg.requestID) else {
                throw ProtocolError(message: "Received RESULT for invalid request ID \(msg.requestID)")
            }
            callRequests.removeValue(forKey: msg.requestID)
            return msg

        case let msg as Registered:
            guard registerRequests.keys.contains(msg.requestID) else {
                throw ProtocolError(message: "Received REGISTERED for invalid request ID \(msg.requestID)")
            }
            registerRequests.removeValue(forKey: msg.requestID)
            registrations[msg.registrationID] = msg.registrationID
            return msg

        case let msg as Unregistered:
            guard unregisterRequests.keys.contains(msg.requestID) else {
                throw ProtocolError(message: "Received UNREGISTERED for invalid request ID \(msg.requestID)")
            }
            let registrationID = unregisterRequests.removeValue(forKey: msg.requestID)!
            guard registrations.keys.contains(registrationID) else {
                throw ProtocolError(message: "Received UNREGISTERED for invalid registration ID \(registrationID)")
            }
            registrations.removeValue(forKey: registrationID)
            return msg

        case let msg as Invocation:
            guard registrations.keys.contains(msg.registrationID) else {
                throw ProtocolError(message: "Received INVOCATION for invalid registration ID \(msg.registrationID)")
            }
            invocationRequests[msg.requestID] = msg.requestID
            return msg

        case let msg as Published:
            guard publishRequests.keys.contains(msg.requestID) else {
                throw ProtocolError(message: "Received PUBLISHED for invalid request ID \(msg.requestID)")
            }
            publishRequests.removeValue(forKey: msg.requestID)
            return msg

        case let msg as Subscribed:
            guard subscribeRequests.keys.contains(msg.requestID) else {
                throw ProtocolError(message: "Received SUBSCRIBED for invalid request ID \(msg.requestID)")
            }
            subscribeRequests.removeValue(forKey: msg.requestID)
            subscriptions[msg.subscriptionID] = msg.subscriptionID
            return msg

        case let msg as Unsubscribed:
            guard unsubscribeRequests.keys.contains(msg.requestID) else {
                throw ProtocolError(message: "Received UNSUBSCRIBED for invalid request ID \(msg.requestID)")
            }
            let subscriptionID = unsubscribeRequests.removeValue(forKey: msg.requestID)!
            guard subscriptions.keys.contains(subscriptionID) else {
                throw ProtocolError(message: "Received UNSUBSCRIBED for invalid subscription ID \(subscriptionID)")
            }
            subscriptions.removeValue(forKey: subscriptionID)
            return msg

        case let msg as Event:
            guard subscriptions.keys.contains(msg.subscriptionID) else {
                throw ProtocolError(message: "Received EVENT for invalid subscription ID \(msg.subscriptionID)")
            }
            return msg

        case let msg as Error:
            switch msg.messageType {
            case Call.id:
                guard callRequests.keys.contains(msg.requestID) else {
                    throw ProtocolError(message: "Received ERROR for invalid call request")
                }
                callRequests.removeValue(forKey: msg.requestID)

            case Register.id:
                guard registerRequests.keys.contains(msg.requestID) else {
                    throw ProtocolError(message: "Received ERROR for invalid register request")
                }
                registerRequests.removeValue(forKey: msg.requestID)

            case Unregister.id:
                guard unregisterRequests.keys.contains(msg.requestID) else {
                    throw ProtocolError(message: "Received ERROR for invalid unregister request")
                }
                unregisterRequests.removeValue(forKey: msg.requestID)

            case Subscribe.id:
                guard subscribeRequests.keys.contains(msg.requestID) else {
                    throw ProtocolError(message: "Received ERROR for invalid subscribe request")
                }
                subscribeRequests.removeValue(forKey: msg.requestID)

            case Unsubscribe.id:
                guard unsubscribeRequests.keys.contains(msg.requestID) else {
                    throw ProtocolError(message: "Received ERROR for invalid unsubscribe request")
                }
                unsubscribeRequests.removeValue(forKey: msg.requestID)

            case Publish.id:
                guard publishRequests.keys.contains(msg.requestID) else {
                    throw ProtocolError(message: "Received ERROR for invalid publish request")
                }
                publishRequests.removeValue(forKey: msg.requestID)

            default:
                throw ProtocolError(message: "Unknown error message type \(msg)")
            }
            return msg

        case let msg as Goodbye:
            return msg

        default:
            throw ProtocolError(message: "Unknown message \(msg)")
        }
    }
}
