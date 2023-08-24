//
//  CrowdChatSubjectType.swift
//  CrowdSOLUTIONS
//
//  Created by Kevin Hoogheem on 3/22/22.
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

/// CrowdChat Subject Types
public enum CrowdChatSubjectType: String, Codable {
    /// Broadcast Event
    case broadcastEvent = "broadcast_event"
    /// Tennis Match
    case tennisMatch    = "tennis_match"
    /// Tennis Schedule Entry
    case tennisSchedule = "tennis_schedule"
    /// Live Stream
    case livestream     = "livestream"
    /// If the Subject allows Anonymous Users
    ///
    /// If the subject does not allow anonymous access the user must be authorized to join the chat room
    public var allowsAnonymous: Bool {
        switch self {
        case .broadcastEvent:
            return false
        case .tennisMatch, .tennisSchedule, .livestream:
            return true
        }
    }
}

extension CrowdChatSubjectType: Equatable {}
extension CrowdChatSubjectType: Hashable {}
