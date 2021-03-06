import XCTest

enum FakeTransportError: ErrorType {
    case NotConnected(localizedDescription: String)
}

@objc class FakeTransport: NSObject, RMQTransport {
    var connected = false
    var receivedData: NSData?
    var outboundData: NSData = NSData()

    func connect(onConnect: () -> Void) {
        connected = true
        onConnect()
    }
    func close(onClose: () -> Void) {
        connected = false
        onClose()
    }
    func write(data: NSData, onComplete complete: () -> Void) throws -> String {
        if (!connected) {
            throw FakeTransportError.NotConnected(localizedDescription: "foo")
        }
        outboundData = data;
        complete()
        return  ""
    }
    func isConnected() -> Bool {
        return connected
    }
    func readFrame(complete: (NSData) -> Void) {
        if (receivedData == nil) {
            XCTFail("You need to call receive() before readFrame() is called")
        } else{
            complete(receivedData!)
        }
    }
    func lastWrite() -> NSData {
        return outboundData
    }
    func receive(data: NSData) {
        receivedData = data
    }
}