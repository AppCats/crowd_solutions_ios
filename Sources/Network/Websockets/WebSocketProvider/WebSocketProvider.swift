//
//  WebSocketProvider.swift
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

/// Defines a Websocket Provider
protocol WebSocketProvider {
    
    /// Current URL Socket is Connected to
    var currentURL: URL { get }
    /// If the Socket is Connected
    var isConnected: Bool { get }
    /// Socket Provider Delegate
    var delegate: WebSocketProviderDelegate? { get set }
    
    init(request: URLRequest)
    
    /// Connect to the WebSocket
    func connect()
    
    /// Disconnect from the Websocket
    func disconnect()
    
    /// Writes Data to the Socket
    func write(_ data: Data)
}

public enum WebSocketProviderError: Error, LocalizedError {
    /// Disconnect Received
    case disconnection(String, code: Int)
    /// Data Receive Error
    case receiveData(String, code: Int)
    
    struct Code {
        static let disconnection: Int = 0
    }
    
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch self {
        case .disconnection(let msg, code: let code):
            return "[WebSocket] Error: \(msg) Code: \(code)"
        case .receiveData(let msg, code: let code):
            return "[WebSocket] Error: \(msg) Code: \(code)"
        }
    }
}

/// Websocket Provider Delegates
protocol WebSocketProviderDelegate: AnyObject {
    
    /// Websocket did Connect
    func websocketDidConnect()
    
    /// Websocket disconnected with error
    func websocketDidDisconnect(error: WebSocketProviderError?)
    
    /// Websocket Received Messages
    func websocketDidReceiveMessage(_ message: String)
}
