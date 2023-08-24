//
//  CrowdChatCommandRemoveMessageResponse.swift
//  CrowdSOLUTIONS
//
//  Created by Kevin Hoogheem on 3/26/22.
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

/// The Response to the Remove Message Command
struct CrowdChatCommandRemoveMessageResponse: CrowdChatEventSocketCommandResponse {
    static let event: String = "removed_message"

    var event: String = Self.event

    /// Message To Remove
    let message: CrowdChatMessage
            
    init?(event: String, payload: WebSocket.Payload) {
        guard event.lowercased() == Self.event,
              let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []),
              let message = try? JSONDecoder().decode(CrowdChatMessage.self, from: jsonData) else {
                  return nil
              }
        
        self.message = message
    }
    
}