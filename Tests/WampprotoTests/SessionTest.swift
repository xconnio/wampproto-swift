@testable import Wampproto
import XCTest

class SessionTests: XCTestCase {
    private var serializer: Serializer = JSONSerializer()
    private lazy var session: Session = .init(serializer: serializer)

    func testSendRegister() throws {
        let register = Register(requestID: 2, uri: "io.xconn.test")
        let toSend = try session.sendMessage(msg: register)

        XCTAssertEqual(toSend.asString, "[\(Register.id),\(register.requestID),{},\"\(register.uri)\"]")

        let registered = Registered(requestID: 2, registrationID: 3)
        let received = try session.receive(data: serializer.serialize(message: registered)) as? Registered
        XCTAssertEqual(registered.requestID, received!.requestID)
        XCTAssertEqual(registered.registrationID, received!.registrationID)
    }

    func testSendCall() throws {
        let call = Call(requestID: 10, uri: "io.xconn.test")
        let toSend = try session.sendMessage(msg: call)
        XCTAssertEqual(toSend.asString, "[\(Call.id),\(call.requestID),{},\"\(call.uri)\"]")

        let result = Result(requestID: 10)
        let received = try session.receive(data: serializer.serialize(message: result)) as? Result
        XCTAssertEqual(result.requestID, received!.requestID)
    }

    func testReceiveInvocation() throws {
        _ = try session.sendMessage(msg: Register(requestID: 2, uri: "io.xconn.test"))
        _ = try session.receive(data: serializer.serialize(message: Registered(requestID: 2, registrationID: 3)))

        let invocation = Invocation(requestID: 4, registrationID: 3)
        let toSend = try session.receive(data: serializer.serialize(message: invocation)) as? Invocation
        XCTAssertEqual(invocation.requestID, toSend?.requestID)
        XCTAssertEqual(invocation.registrationID, toSend?.registrationID)

        let yield = Yield(requestID: 4)
        let received = try session.sendMessage(msg: yield)
        XCTAssertEqual(received.asString, "[70,4,{}]")
    }

    func testSendUnregister() throws {
        _ = try session.sendMessage(msg: Register(requestID: 2, uri: "io.xconn.test"))
        _ = try session.receive(data: serializer.serialize(message: Registered(requestID: 2, registrationID: 3)))

        let unregister = Unregister(requestID: 3, registrationID: 3)
        let toSend = try session.sendMessage(msg: unregister)
        XCTAssertEqual(toSend.asString, "[\(Unregister.id),\(unregister.requestID),\(unregister.registrationID)]")

        let unregistered = Unregistered(requestID: 3)
        let received = try session.receive(data: serializer.serialize(message: unregistered)) as? Unregistered
        XCTAssertEqual(unregistered.requestID, received?.requestID)
    }

    func testSendPublishWithAcknowledge() throws {
        let publish = Publish(requestID: 6, uri: "topic", options: ["acknowledge": true])
        let toSend = try session.sendMessage(msg: publish)
        XCTAssertEqual(toSend.asString,
                       "[\(Publish.id),\(publish.requestID),{\"acknowledge\":true},\"\(publish.uri)\"]")

        let published = Published(requestID: 6, publicationID: 6)
        let received = try session.receive(data: serializer.serialize(message: published)) as? Wampproto.Published
        XCTAssertEqual(published.requestID, received?.requestID)
        XCTAssertEqual(published.publicationID, received?.publicationID)
    }

    func testSendSubscribe() throws {
        let subscribe = Subscribe(requestID: 7, topic: "topic")
        let toSend = try session.sendMessage(msg: subscribe)
        XCTAssertEqual(toSend.asString, "[\(Subscribe.id),\(subscribe.requestID),{},\"\(subscribe.topic)\"]")

        let subscribed = Subscribed(requestID: 7, subscriptionID: 8)
        let received = try session.receive(data: serializer.serialize(message: subscribed)) as? Subscribed
        XCTAssertEqual(subscribed.requestID, received?.requestID)
        XCTAssertEqual(subscribed.subscriptionID, received?.subscriptionID)

        let event = Event(subscriptionID: 8, publicationID: 6)
        let receivedEvent = try session.receive(data: serializer.serialize(message: event)) as? Event
        XCTAssertEqual(event.publicationID, receivedEvent?.publicationID)
        XCTAssertEqual(event.subscriptionID, receivedEvent?.subscriptionID)
    }

    func testSendUnsubscribe() throws {
        _ = try session.sendMessage(msg: Subscribe(requestID: 7, topic: "topic"))
        _ = try session.receive(data: serializer.serialize(message: Subscribed(requestID: 7, subscriptionID: 8)))

        let unsubscribe = Unsubscribe(requestID: 8, subscriptionID: 8)
        let toSend = try session.sendMessage(msg: unsubscribe)
        XCTAssertEqual(toSend.asString, "[\(Unsubscribe.id),\(unsubscribe.requestID),\(unsubscribe.subscriptionID)]")

        let unsubscribed = Unsubscribed(requestID: 8)
        let received = try session.receive(data: serializer.serialize(message: unsubscribed)) as? Unsubscribed
        XCTAssertEqual(unsubscribed.requestID, received?.requestID)
    }

    func testSendError() throws {
        let error = Error(messageType: Invocation.id, requestID: 10, uri: "io.xconn.failed")
        let toSend = try session.sendMessage(msg: error)
        XCTAssertEqual(toSend.asString, "[\(Error.id),\(Invocation.id),\(error.requestID),{},\"\(error.uri)\"]")
    }

    func testReceiveError() throws {
        // send Call message and receive Error for that Call
        let call = Call(requestID: 1, uri: "io.xconn.test")
        _ = try session.sendMessage(msg: call)

        let callErr = Error(messageType: Call.id, requestID: call.requestID, uri: errInvalidArgument)
        let receivedCallErr = try session.receive(data: serializer.serialize(message: callErr)) as? Error
        XCTAssertEqual(callErr.messageType, receivedCallErr?.messageType)
        XCTAssertEqual(callErr.requestID, receivedCallErr?.requestID)
        XCTAssertEqual(callErr.uri, receivedCallErr?.uri)

        // send Register message and receive Error for that Register
        let register = Register(requestID: 2, uri: "io.xconn.test")
        _ = try session.sendMessage(msg: register)

        let registerErr = Error(messageType: Register.id, requestID: register.requestID,
                                uri: errInvalidArgument)
        let receivedRegisterErr = try session.receive(
            data: serializer.serialize(message: registerErr)) as? Error
        XCTAssertEqual(registerErr.messageType, receivedRegisterErr?.messageType)
        XCTAssertEqual(registerErr.requestID, receivedRegisterErr?.requestID)
        XCTAssertEqual(registerErr.uri, receivedRegisterErr?.uri)

        // send Unregister message and receive Error for that Unregister
        let unregister = Unregister(requestID: 3, registrationID: 3)
        _ = try session.sendMessage(msg: unregister)

        let unregisterErr = Error(messageType: Unregister.id, requestID: unregister.requestID,
                                  uri: errInvalidArgument)
        let receivedUnregisterErr = try session.receive(data: serializer.serialize(message: unregisterErr)) as? Error
        XCTAssertEqual(unregisterErr.messageType, receivedUnregisterErr?.messageType)
        XCTAssertEqual(unregisterErr.requestID, receivedUnregisterErr?.requestID)
        XCTAssertEqual(unregisterErr.uri, receivedUnregisterErr?.uri)

        // send Subscribe message and receive Error for that Subscribe
        let subscribe = Subscribe(requestID: 7, topic: "topic")
        _ = try session.sendMessage(msg: subscribe)

        let subscribeErr = Error(messageType: Subscribe.id, requestID: subscribe.requestID,
                                 uri: errInvalidURI)
        let receivedSubscribeErr = try session.receive(
            data: serializer.serialize(message: subscribeErr)) as? Error
        XCTAssertEqual(subscribeErr.messageType, receivedSubscribeErr?.messageType)
        XCTAssertEqual(subscribeErr.requestID, receivedSubscribeErr?.requestID)
        XCTAssertEqual(subscribeErr.uri, receivedSubscribeErr?.uri)

        // send Unsubscribe message and receive Error for that Unsubscribe
        let unsubscribe = Unsubscribe(requestID: 8, subscriptionID: 8)
        _ = try session.sendMessage(msg: unsubscribe)

        let unsubscribeErr = Error(messageType: Unsubscribe.id, requestID: unsubscribe.requestID,
                                   uri: errInvalidURI)
        let receivedUnsubscribeErr = try session.receive(data: serializer.serialize(message: unsubscribeErr)) as? Error
        XCTAssertEqual(unsubscribeErr.messageType, receivedUnsubscribeErr?.messageType)
        XCTAssertEqual(unsubscribeErr.requestID, receivedUnsubscribeErr?.requestID)
        XCTAssertEqual(unsubscribeErr.uri, receivedUnsubscribeErr?.uri)

        // send Publish message and receive Error for that Publish
        let publish = Publish(requestID: 6, uri: "topic", options: ["acknowledge": true])
        _ = try session.sendMessage(msg: publish)

        let publishErr = Error(messageType: Publish.id, requestID: publish.requestID, uri: errInvalidURI)
        let receivedPublishErr = try session.receive(data: serializer.serialize(message: publishErr)) as? Error
        XCTAssertEqual(publishErr.messageType, receivedPublishErr?.messageType)
        XCTAssertEqual(publishErr.requestID, receivedPublishErr?.requestID)
        XCTAssertEqual(publishErr.uri, receivedPublishErr?.uri)
    }

    func testExceptions() throws {
        // send Yield for unknown invocation
        let invalidYield = Yield(requestID: 5)
        XCTAssertThrowsError(try session.sendMessage(msg: invalidYield))

        // send error for invalid message
        let invalidError = Error(messageType: Register.id, requestID: 10, uri: errProcedureAlreadyExists)
        XCTAssertThrowsError(try session.sendMessage(msg: invalidError))

        // send invalid message
        let invalidMessage = Registered(requestID: 11, registrationID: 12)
        XCTAssertThrowsError(try session.sendMessage(msg: invalidMessage))

        // receive invalid message
        XCTAssertThrowsError(try session.receive(data: serializer.serialize(
            message: Register(requestID: 100, uri: "io.xconn.test"))))

        // receive error for invalid message
        XCTAssertThrowsError(try session.receive(data: serializer.serialize(
            message: Error(messageType: Registered.id, requestID: 100, uri: errInvalidArgument))))

        // receive error invalid Call id
        XCTAssertThrowsError(try session.receive(data: serializer.serialize(
            message: Error(messageType: Call.id, requestID: 100, uri: errInvalidArgument))))

        // receive error Register id
        XCTAssertThrowsError(try session.receive(data: serializer.serialize(
            message: Error(messageType: Register.id, requestID: 100, uri: errInvalidArgument))))

        // receive error invalid Unregister id
        XCTAssertThrowsError(try session.receive(data: serializer.serialize(
            message: Error(messageType: Unregister.id, requestID: 100, uri: errInvalidArgument))))

        // receive error invalid Subscribe id
        XCTAssertThrowsError(try session.receive(data: serializer.serialize(
            message: Error(messageType: Subscribe.id, requestID: 100, uri: errInvalidArgument))))

        // receive error invalid Unsubscribe id
        XCTAssertThrowsError(try session.receive(data: serializer.serialize(
            message: Error(messageType: Unsubscribe.id, requestID: 100, uri: errInvalidArgument))))

        // receive error invalid Publish id
        XCTAssertThrowsError(try session.receive(data: serializer.serialize(
            message: Error(messageType: Publish.id, requestID: 100, uri: errInvalidArgument))))
    }
}
