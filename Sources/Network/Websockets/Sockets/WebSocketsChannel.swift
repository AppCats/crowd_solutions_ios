//
//  WebSocketsChannel.swift
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
import Combine

/// Websocket Channel
public class WebSocketsChannel {
    private var callbacks: [String: (WebSocketsResponse) -> Void] = [:]
    private var presenceStateCallback: ((WebSocketsPresence) -> Void)?
    private weak var socket: WebSocket?

    /// Channel Topic
    public let topic: String
    /// Channel Parameters
    public let params: WebSocket.Payload

    /// Channel State
    @Published
    private(set) public var state: WebSocketChannelState
    
    /// Presence Information
    private(set) public var presence: WebSocketsPresence

    /// Channel has reached the state of `joined`
    ///
    /// - note: On a `leave` this will be set back to `nil`
    public var onJoined: ((WebSocket.Payload) -> Void)?

    init(socket: WebSocket, topic: String, params: WebSocket.Payload = [:]) {
        self.socket = socket
        self.topic = topic
        self.params = params
        self.state = .closed
        self.presence = WebSocketsPresence()
        
        // Register presence handling.
        on(WebSocketsPresence.Events.state) { [weak self] response in
            self?.presence.sync(response)
            guard let presence = self?.presence else { return }
            self?.presenceStateCallback?(presence)
        }
        on(WebSocketsPresence.Events.diff) { [weak self] response in
            self?.presence.sync(response)
        }
    }

    // MARK: - Raw events

    func received(_ response: WebSocketsResponse) {
        if let callback = callbacks[response.event] {
            callback(response)
        }
    }
}

// MARK: - Callbacks
public extension WebSocketsChannel {
    
    /// Listen to Channel Event
    /// - Parameters:
    ///   - event: event to listen to
    ///   - callback: call back to perform on `event`
    /// - Returns: Channel
    @discardableResult
    func on(_ event: String, callback: @escaping (WebSocketsResponse) -> Void) -> Self {
        callbacks[event] = callback
        return self
    }
    
    /// Listen to Presence Updates
    /// - Parameter callback: call back to perform on Presence Updates
    /// - Returns: Channel
    @discardableResult
    func onPresenceUpdate(_ callback: @escaping (WebSocketsPresence) -> Void) -> Self {
        presenceStateCallback = callback
        return self
    }
    
}

// MARK: - Leave Channel
public extension WebSocketsChannel {
    
    /// Leaves Socket Channel
    /// - Returns: `WebSocketsPush`
    @discardableResult
    func leave() -> WebSocketsPush? {
        state = .leaving
        
        return send(WebSocket.Event.leave, payload: [:])?.receive(.ok, callback: { response in
            self.callbacks.removeAll()
            self.presence.onJoin = nil
            self.presence.onLeave = nil
            self.presence.onStateChange = nil
            self.onJoined = nil
            self.state = .closed
        })
    }
}

// MARK: - Join Channel
public extension WebSocketsChannel {
    
    /// Join Socket Channel
    /// - Returns: `WebSocketsPush`
    @discardableResult
    func join() -> WebSocketsPush? {
        state = .joining

        return send(WebSocket.Event.join, payload: params)?.receive(.ok, callback: { response in
            self.state = .joined
            self.onJoined?(response)
        })
    }

    /// Join Socket Channel and Decode the Direct Response
    ///
    /// *example:*
    /// ```
    ///  join(type: String.self) { result in
    ///    switch result {
    ///
    ///    case .success(_):
    ///        break
    ///    case .failure(_):
    ///        break
    ///    }
    ///  }
    ///  ```
    ///
    /// - Parameters:
    ///   - type: Type that is being decoded
    ///   - completion: Returns a success of `T` or `Error` as `String`
    func join<T: Decodable>(type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        self.join { item in
            completion(.success(item))
        } errorReason: { error in
            completion(.failure(error))
        }
    }

    /// Join Socket Channel and Decode the Direct Response
    ///
    /// - Parameters:
    ///   - responseObject: The Decodable Object returned from the join response
    ///   - errorReason: String value of Error
    private func join<T: Decodable>(responseObject: @escaping (T) -> Void, errorReason: @escaping (String) -> Void) {
        let socketname = self.socket?.socketName ?? WebSocket.socketDefaultName
        let errorBase = "[\(socketname)] Join Error: "

        guard socket != nil else {
            errorReason(errorBase + "Not connected to socket")
            return
        }
                
        join()?.receive(.ok, callback: { response in
            guard let jsonData = try? JSONSerialization.data(withJSONObject: response["response"] as Any, options: []) else {
                let message = errorBase + "Invalid response payload"
                errorReason(message)
                return
            }

            self.decodeJsonData(jsonData) { item in
                responseObject(item)
            } errorReason: { error in
                let message = "[\(socketname)] Decode Errorr: \(error)"
                errorReason(message)
            }

        }).receive(.error, callback: { [weak self] response in
            guard self != nil else { return }

            if let message = WebSocketsResponse.processPayloadReason(response) {
                let errorMsg = errorBase + message
                errorReason(errorMsg)
            } else {
                errorReason(errorBase + "Join not acccepted")
            }
        })
    }

}

// MARK: - Send Message
public extension WebSocketsChannel {
    
    /// Sends Socket Event
    /// - Parameters:
    ///   - event: The Socket Event
    ///   - payload: Payload for event
    /// - Returns: An Optional `WebSocketsPush`
    @discardableResult
    func send(_ event: String, payload: WebSocket.Payload) -> WebSocketsPush? {
        let message = WebSocketsPush(event, topic: topic, payload: payload)
        return socket?.send(message)
    }
    
    /// Sends Socket Event and Decode the Direct Response
    ///
    /// *example:*
    /// ```
    ///  self.send("blah", payload: [:], type: String.self) { result in
    ///    switch result {
    ///
    ///    case .success(_):
    ///        break
    ///    case .failure(_):
    ///        break
    ///    }
    ///  }
    ///  ```
    ///
    /// - Parameters:
    ///   - event: The Socket Event
    ///   - payload: Payload for event
    ///   - type: Type that is being decoded
    ///   - completion: Returns a success of `T` or `Error` as `String`
    func send<T: Decodable>(_ event: String, payload: WebSocket.Payload, type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        self.send(event, payload: payload) { item in
            completion(.success(item))
        } errorReason: { error in
            completion(.failure(error))
        }
    }
    
    /// Sends Socket Event and Decode the Direct Response
    ///
    /// - Parameters:
    ///   - event: The Socket Event
    ///   - payload: Payload for event
    ///   - responseObject: The Decodable Object returned from the socket response
    ///   - errorReason: String value of Error
    private func send<T: Decodable>(_ event: String, payload: WebSocket.Payload, responseObject: @escaping (T) -> Void, errorReason: @escaping (String) -> Void) {
        let socketname = self.socket?.socketName ?? WebSocket.socketDefaultName
        let errorBase = "[\(socketname)] Send - \(event) Error: "

        guard let socket else {
            errorReason(errorBase + "Not connected to socket")
            return
        }
        let message = WebSocketsPush(event, topic: topic, payload: payload)
        
        socket.send(message).receive(.ok, callback: { response in
            guard let jsonData = try? JSONSerialization.data(withJSONObject: response["response"] as Any, options: []) else {
                let message = errorBase + "Invalid response payload"
                errorReason(message)
                return
            }

            self.decodeJsonData(jsonData) { item in
                responseObject(item)
            } errorReason: { error in
                let message = "[\(socketname)] Decode Error of \(event): \(error)"
                errorReason(message)
            }
            
        }).receive(.error, callback: { [weak self] response in
            guard self != nil else { return }
            
            if let message = WebSocketsResponse.processPayloadReason(response) {
                let errorMsg = errorBase + message
                errorReason(errorMsg)
            } else {
                errorReason(errorBase + "Command not acccepted")
            }
        })
    }

}

// MARK: - Process Payload
private extension WebSocketsChannel {
    
    func decodeJsonData<T: Decodable>(_ jsonData: Data, responseObject: @escaping (T) -> Void, errorReason: @escaping (String) -> Void) {
        do {
            let object = try JSONDecoder().decode(T.self, from: jsonData)
            responseObject(object)
        } catch {
            let message = error.decodingErrorString(type: T.self)
            errorReason(message)
            return
        }
    }

}
