//
//  CrowdChatEventSocketCommand.swift
//  CrowdSOLUTIONS
//
//  Created by Kevin Hoogheem on 3/24/22.
//  Copyright © 2022 AppCats LLC. All rights reserved.
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

/// Protocol for Events that can be sent to the Chat Server
protocol CrowdChatEventSocketCommand {
    /// Event String Value
    var event: String { get }
    
    /// Payload
    var payload: WebSocket.Payload { get }
}

/// Protocol for Events that are Responses from the Chat Server
protocol CrowdChatEventSocketCommandResponse {
    /// Event String Value
    var event: String { get }

    init?(event: String, payload: WebSocket.Payload)
}

/// Empty Protocol to denote Commands that Only a Mod can send
protocol CrowdChatEventSocketCommandModSendable {}

/// Commands that are Sendable by Moderator Only
typealias CrowdChatEventSocketCommandModerator = CrowdChatEventSocketCommand & CrowdChatEventSocketCommandModSendable
