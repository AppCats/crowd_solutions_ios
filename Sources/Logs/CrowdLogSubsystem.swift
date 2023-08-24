//
//  CrowdLogSubsystem.swift
//  CrowdSOLUTIONSTests
//
//  Created by Kevin Hoogheem on 8/17/23.
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
import OSLog

/// Logger Subsystem
public enum CrowdLogSubsystem {
    /// The unique identifier for our logger
    private static let subsystem: String = "com.appcats.crowdsolutions.logger"
    private static let chatLogger: Logger = Logger(subsystem: Self.subsystem, category: Self.chat.category)
    private static let networkLogger: Logger = Logger(subsystem: Self.subsystem, category: Self.network.category)
    private static let websocketLogger: Logger = Logger(subsystem: Self.subsystem, category: Self.websocket.category)
    private static let wsHeartbeatLogger: Logger = Logger(subsystem: Self.subsystem, category: Self.websocketHeartbeat.category)

    /// Chat Logs
    case chat
    /// Network
    case network
    /// WebSocket
    ///
    /// Send and Received Messages
    case websocket
    /// WebSocket Heartbeat messages
    case websocketHeartbeat

    /// All Subsystems
    static let all: [CrowdLogSubsystem] = [.chat, .network, .websocket, .websocketHeartbeat]

    /// Logger associated with subsystem
    var logger: Logger {
        switch self {
        case .chat:
            return Self.chatLogger
        case .network:
            return Self.networkLogger
        case .websocket:
            return Self.websocketLogger
        case .websocketHeartbeat:
            return Self.wsHeartbeatLogger
        }
    }
    
    /// Loggers category
    public var category: String {
        switch self {
        case .chat:
            return "chat"
        case .network:
            return "network"
        case .websocket:
            return "websocket"
        case .websocketHeartbeat:
            return "websocket-hb"
        }
    }
}
