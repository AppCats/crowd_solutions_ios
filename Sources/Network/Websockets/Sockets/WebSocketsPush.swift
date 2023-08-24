//
//  WebSocketsPush.swift
//  CrowdSOLUTIONS
//
//  Copyright © 2023 AppCats LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

/// Socket Push
public class WebSocketsPush {
    
    /// Receive Status
    public enum ReceiveStatus {
        /// Error
        case error
        /// OK
        case ok
        /// Custom
        case custom(status: String)
        
        var rawValue: String {
            switch self {
            case .error:
                return "error"
            case .ok:
                return "ok"
            case .custom(status: let status):
                return status
            }
        }
    }
    
    private var callbacks: [String: [(WebSocket.Payload) -> Void]] = [:]
    private var alwaysCallbacks: [() -> Void] = []

    /// Time message was created since 1970
    private let createdTime: TimeInterval

    let ref: String?

    private(set) var receivedStatus: String?
   
    private(set) var receivedResponse: WebSocket.Payload?

    /// Topic
    public let topic: String

    /// Time in milliseconds since message was created
    var millisecondsSinceCreated: Int {
        Int(Double(Date().timeIntervalSince1970 - createdTime) * 1000)
    }
    /// Event
    public let event: String
    /// Socket Payload
    public let payload: WebSocket.Payload

    init(_ event: String, topic: String, payload: WebSocket.Payload, ref: String = UUID().uuidString) {
        self.createdTime = Date().timeIntervalSince1970
        self.topic = topic
        self.event = event
        self.payload = payload
        self.ref = ref
    }

}

// MARK: - Callback registration
public extension WebSocketsPush {
    
    /// Register a `ReceiveStatus` callback
    /// - Parameters:
    ///   - status: The `ReceiveStatus` to register
    ///   - callback: `WebSocket.Payload` for status
    /// - Returns: A `WebSocketsPush`
    @discardableResult
    func receive(_ status: ReceiveStatus, callback: @escaping (WebSocket.Payload) -> Void) -> Self {
        if receivedStatus == status.rawValue,
            let receivedResponse = receivedResponse {
            callback(receivedResponse)
        } else {
            if callbacks[status.rawValue] == nil {
                callbacks[status.rawValue] = [callback]
            } else {
                callbacks[status.rawValue]?.append(callback)
            }
        }

        return self
    }

    /// Callback for any push coming in
    /// - Parameter callback: call back to perform
    /// - Returns: A `WebSocketsPush`
    @discardableResult
    func always(_ callback: @escaping () -> Void) -> Self {
        alwaysCallbacks.append(callback)
        return self
    }
}

// MARK: - JSON parsing
extension WebSocketsPush {

    func toJson() throws -> Data {
        let dict = [
            "topic": topic,
            "event": event,
            "payload": payload,
            "ref": ref ?? ""
        ] as [String: Any]

        return try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions())
    }
}

// MARK: - Response handling
extension WebSocketsPush {

    func handleResponse(_ response: WebSocketsResponse) {
        receivedStatus = response.payload["status"] as? String
        receivedResponse = response.payload

        fireCallbacksAndCleanup()
    }

    func handleParseError() {
        receivedStatus = "error"
        receivedResponse = ["reason": "Invalid payload request." as AnyObject]

        fireCallbacksAndCleanup()
    }

    func handleNotConnected() {
        receivedStatus = "error"
        receivedResponse = ["reason": "Not connected to socket." as AnyObject]

        fireCallbacksAndCleanup()
    }

    func fireCallbacksAndCleanup() {
        defer {
            callbacks.removeAll()
            alwaysCallbacks.removeAll()
        }

        guard let status = receivedStatus else { return }

        alwaysCallbacks.forEach({ $0() })

        if let matchingCallbacks = callbacks[status],
            let receivedResponse = receivedResponse {
            matchingCallbacks.forEach({ $0(receivedResponse) })
        }
    }
}
