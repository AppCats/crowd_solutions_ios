//
//  CrowdChatResponseEvent.swift
//  CrowdSOLUTIONS
//
//  Created by Kevin Hoogheem on 4/8/22.
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

/// CrowdChat Socket Response Events
public enum CrowdChatResponseEvent {
    /// Chat Room Users On The Blocked List
    case blockedUsers
    /// Chat Room Joined
    ///
    /// - Parameter user: the `CrowdChatRoomUser` who joined
    case channelJoin(user: CrowdChatRoomUser)
    /// Chat Room Archived
    case chatRoomArchived
    /// Chat Room Unarchived
    case chatRoomUnarchived
    /// Chat Content Flagged
    case flaggedContent(type: CrowdChatFlaggedType)
    /// Chat Room Users On The Flagged List
    case flaggedUsers
    /// Chat Message Hidden
    case messageHidden
    /// Chat Message History
    ///
    /// - Parameter count: Number of messages returned when history is fetched
    case messageHistory(count: Int)
    /// Chat Message Removed/Deleted
    case messageRemoved
    /// New Chat Message Received
    case newMessage
    /// Chat Content Unflagged or Cleared
    case unflaggedContent(type: CrowdChatFlaggedType)
    /// Chat Room User Blocked
    case userBlocked
    /// Chat Room User Unblocked
    case userUnblocked

}
