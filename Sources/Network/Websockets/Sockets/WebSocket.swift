//
//  WebSocket.swift
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

/// Socket Health
public enum SocketHealth {
    /// Unknown
    case unknown
    /// Socket connected
    case connected
    /// Missed single heartbeat
    case caution
    /// Missed max heartbeat
    case warning
    /// Socket disconnected
    case disconnected
}

/// Web Socket
public final class WebSocket {
    struct Event {
        static let heartbeat    = "heartbeat"
        static let join         = "phx_join"
        static let leave        = "phx_leave"
        static let reply        = "phx_reply"
        static let error        = "phx_error"
        static let close        = "phx_close"
    }
    
    /// Default Socket Name
    static let socketDefaultName = "CrowdSOLUTIONS Socket"

    private static let HeartbeatInterval = DispatchTimeInterval.seconds(5)
    private static let HeartbeatPrefix = "hb-"
    private static let HeatbeatChannelTopic = "phoenix"

    private var heartbeatQueue: DispatchQueue = DispatchQueue(label: "co.appcats.websocket.hbqueue")
    private var awaitingResponses = [String: WebSocketsPush]()
    private var socketProvider: WebSocketProvider

    /// Payload data
    public typealias Payload = [String: Any]
    
    /// Channels for this socket
    private(set) public var channels: [String: WebSocketsChannel] = [:]
        
    /// Socket Name
    public var socketName = "CrowdSOLUTIONS Socket"
    
    /// Called when socket connected
    public var onConnect: (() -> Void)?
    /// Called each time a heartbeat message is sent
    public var onSendingHeartbeat: (() -> Void)?
    /// Called each time a heartbeat message is received
    public var onReceivedHeartbeat: (() -> Void)?
    /// Called when socket is disconnected
    public var onDisconnect: ((WebSocketProviderError?) -> Void)?
    
    /// Number of Heartbeats Pending
    public var numberOfHeartbeatsPending: Int {
        awaitingResponses.filter({ $0.key.hasPrefix(Self.HeartbeatPrefix) }).count
    }
    
    /// If Set this will reset the Socket after the number of Heartbeat Failures
    public var heartbeatFailureTolerance: Int?
    
    /// Socket is connected
    public var isConnected: Bool {
        socketProvider.isConnected
    }
    
    /// Socket is connecting
    private(set) public var isConnecting = false
    /// Round Trip Time for messages
    ///
    /// This is the value of the most recent message
    @Published
    private(set) public var messageRoundTripTime: Int = 0

    /// Create Socket
    /// - Parameter url: URL
    public init(url: URL) {
        var request = URLRequest(url: buildURL(url))
        request.timeoutInterval = 5.0
       
        socketProvider = AppleWebSocketProvider(request: request)

        socketProvider.delegate = self
    }

}

// MARK: - Connection
public extension WebSocket {
    
    /// Connect to socket
    func connect() {
        if self.isConnected {
            log("Socket connected -- not connecting")
            return
        }
        
        if isConnecting {
            log("Socket is connecting and you are calling connect... Checking again in 3 seconds")
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                if self.isConnecting {
                    self.log("Waited 3 seconds for socket to connect, closing connection and creating a new one")
                    self.forceDisconnect()
                    self.isConnecting = false
                    self.connect()
                }
            }
            return
        }
        
        log("Connecting to: \(socketProvider.currentURL)")
        isConnecting = true
        
        socketProvider.connect()
    }
    
    /// Disconnect from socket
    func disconnect() {
        if !self.isConnected {
            log("Socket not connected so no disconnect")
            return
        }
        
        socketProvider.disconnect()
    }
    
    /// Force Disconnect from socket
    func forceDisconnect() {
        socketProvider.disconnect()
    }

}

// MARK: - Channels
public extension WebSocket {
    
    /// Create socket channel
    /// - Parameters:
    ///   - topic: Topic for channel
    ///   - payload: payload data
    /// - Returns: Socket Channel
    func channel(_ topic: String, payload: Payload = [:]) -> WebSocketsChannel {
        let channel = WebSocketsChannel(socket: self, topic: topic, params: payload)
        channels[topic] = channel
        return channel
    }
    
    /// Remove and leave channel
    /// - Parameter channel: Channel to remove
    func remove(_ channel: WebSocketsChannel) {
        channel.leave()?.receive(.ok) { [weak self] response in
            self?.channels.removeValue(forKey: channel.topic)
        }
    }

}

// MARK: - Sending data
extension WebSocket {
    
    /// Send Socket Message
    /// - Parameter message: `WebSocketsPush`
    /// - Returns: Discardable `WebSocketsPush`
    @discardableResult
    func send(_ message: WebSocketsPush) -> WebSocketsPush {
        if !self.isConnected {
            message.handleNotConnected()
            return message
        }
        
        do {
            let data = try message.toJson()
            if message.event == Event.heartbeat {
                logHeartbeat("S_Heartbeat: " + String((message.ref?.suffix(5))!))
                onSendingHeartbeat?()
                
                if let tolerance = heartbeatFailureTolerance {
                    if self.numberOfHeartbeatsPending > tolerance {
                        logHeartbeat("Socket heartbeat failed, force disconnect")
                        self.disconnect()
                    }
                }
                
            } else {
                log("Sending (\(message.topic):\(message.event)): \(message.payload)")
            }
            
            if let ref = message.ref {
                awaitingResponses[ref] = message
                heartbeatQueue.async {
                   self.socketProvider.write(data)
                }
            }
        } catch {
            log("Failed to send message (\(message.event)): \(error)")
            message.handleParseError()
        }
        
        return message
    }
}

// MARK: - WebSocketProviderDelegate
extension WebSocket: WebSocketProviderDelegate {
    
    func websocketDidConnect() {
        log("Connected to: \(self.socketProvider.currentURL)")
        isConnecting = false
        onConnect?()
        queueHeartbeat()
    }
    
    func websocketDidDisconnect(error: WebSocketProviderError?) {
        log("Disconnected from: \(self.socketProvider.currentURL)")
        onDisconnect?(error)

        // Reset state.
        awaitingResponses.removeAll()
        channels.removeAll()
        isConnecting = false
    }
    
    func websocketDidReceiveMessage(_ message: String) {
        
        if let data = message.data(using: String.Encoding.utf8),
            let response = WebSocketsResponse(data: data) {
            defer {
                awaitingResponses.removeValue(forKey: response.ref)
            }
            
            if response.topic == WebSocket.HeatbeatChannelTopic {
                if let sent = awaitingResponses[response.ref] {
                    logHeartbeat("R_Heartbeat [\(sent.millisecondsSinceCreated)ms]: " + response.ref.suffix(5))
                } else {
                    logHeartbeat("R_Heartbeat: " + response.ref.suffix(5))
                }

                onReceivedHeartbeat?()
            } else {
                if let sent = awaitingResponses[response.ref] {
                    log("Received event [\(sent.millisecondsSinceCreated)ms]: \(response.event) topic: \(response.topic) payload: \(response.payload)")
                } else {
                    log("Received event: \(response.event) topic: \(response.topic) payload: \(response.payload)")
                }
            }
            
            if let push = awaitingResponses[response.ref] {
                self.messageRoundTripTime = push.millisecondsSinceCreated
                push.handleResponse(response)
            }

            channels[response.topic]?.received(response)
        } else {
            fatalError("Couldn't parse response: \(message)")
        }
    }
    
}

// MARK: - Heartbeat
private extension WebSocket {
    
    func sendHeartbeat() {
        guard self.isConnected else { return }
                
        let ref = WebSocket.HeartbeatPrefix + UUID().uuidString
        let msg = WebSocketsPush(Event.heartbeat, topic: WebSocket.HeatbeatChannelTopic, payload: [:], ref: ref)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.send(msg)
        }
        queueHeartbeat()
    }
    
    func queueHeartbeat() {
        heartbeatQueue.asyncAfter(deadline: .now() + WebSocket.HeartbeatInterval) {
            self.sendHeartbeat()
        }
    }
    
}

// MARK: - Logging
private extension WebSocket {
    
    func log(_ message: String) {
        CrowdLog.info("[\(socketName)] \(message)", subsystem: .websocket)
    }
    
    func logHeartbeat(_ message: String) {
        CrowdLog.debug("[\(socketName)] \(message)", subsystem: .websocketHeartbeat)
    }

}

// MARK: - Private URL helpers
private func buildURL(_ url: URL) -> URL {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
        return url
    }
    
    guard let url = components.url else { fatalError("Problem with the URL") }
    
    return url
}
