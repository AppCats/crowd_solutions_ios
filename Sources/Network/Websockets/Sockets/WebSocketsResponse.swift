//
//  WebSocketsResponse.swift
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

/// Response Data from Socket
public class WebSocketsResponse {
    /// Reference
    public let ref: String
    /// Topic
    public let topic: String
    /// Event
    public let event: String
    /// Payload data
    public let payload: WebSocket.Payload

    init?(data: Data) {
        
        do {
            guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? WebSocket.Payload else { return nil }
            
            ref = jsonObject["ref"] as? String ?? ""
            
            if let topic = jsonObject["topic"] as? String,
                let event = jsonObject["event"] as? String,
                let payload = jsonObject["payload"] as? WebSocket.Payload {
                self.topic = topic
                self.event = event
                self.payload = payload
            } else {
                return nil
            }
            
        } catch {
            return nil
        }
    }
}

// MARK: - Process Payload
public extension WebSocketsResponse {
    
    /// Processs the `Payload` for the `reason`
    ///
    /// This is used when you get a response of `error`
    /// - Parameter payload: The Dictionary of `Payload`
    /// - Returns: The Reason from Payload
    static func processPayloadReason(_ payload: WebSocket.Payload) -> String? {
        payload["reason"] as? String ?? (payload["response"] as? [String: Any])?["reason"] as? String
    }

}
