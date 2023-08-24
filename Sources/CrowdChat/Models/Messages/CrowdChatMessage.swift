//
//  CrowdChatMessage.swift
//  CrowdSOLUTIONS
//
//  Created by Kevin Hoogheem on 3/25/22.
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

/// Base Class for Chat Messages
public class CrowdChatMessage: CrowdChatFlaggableContent, Decodable {
    /// Deleted At Date
    let deletedAt: Date?

    /// Message Identifier
    public let id: String
    /// Room Identifier
    public let roomIdentifier: String
    /// Chat User
    public let user: CrowdChatRoomUser
    /// Message Type
    public let type: CrowdChatMessageType
    /// Message Type Data
    public let typeData: CrowdChatMessageTypeData?
    /// Optional Body Text
    public let body: String?
    /// Message Hidden
    public let hidden: Bool
    /// Created At Date
    public let createdAt: Date
    /// List of Users that Flagged Message
    public let flaggedBy: [CrowdChatRoomUser]
    
    /// If the message is deleted
    public var isDeleted: Bool {
        deletedAt != nil
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        roomIdentifier = try container.decode(String.self, forKey: .roomIdentifier)
        user = try container.decode(CrowdChatRoomUser.self, forKey: .user)
        type = try container.decode(CrowdChatMessageType.self, forKey: .type)
        typeData = try type.decodeTypeDataIfPresent(from: decoder)
        body = try container.decodeIfPresent(String.self, forKey: .body)
        hidden = container.decodeFallbackDefaultValue(Bool.self, forKey: .hidden, defaultValue: false)
        createdAt = container.decodeStringIntoServerDate(forKey: .createdAt) ?? .distantPast
        deletedAt = container.decodeStringIntoServerDate(forKey: .deletedAt)
        flaggedBy = (try? container.decodeIfPresent([CrowdChatRoomUser].self, forKey: .flaggedBy)) ?? []
    }

}

extension CrowdChatMessage: Comparable {
    public static func < (lhs: CrowdChatMessage, rhs: CrowdChatMessage) -> Bool {
        return lhs.createdAt < rhs.createdAt
    }
    
}

extension CrowdChatMessage: Equatable {
    public static func == (lhs: CrowdChatMessage, rhs: CrowdChatMessage) -> Bool {
        lhs.id == rhs.id
        && lhs.roomIdentifier == rhs.roomIdentifier
        && lhs.user == rhs.user
        && lhs.type == rhs.type
        && lhs.body == rhs.body
        && lhs.hidden == rhs.hidden
        && lhs.createdAt == rhs.createdAt
        && lhs.deletedAt == rhs.deletedAt
        && lhs.flaggedBy == rhs.flaggedBy
    }
}

extension CrowdChatMessage: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
        hasher.combine(self.roomIdentifier)
        hasher.combine(self.user)
        hasher.combine(self.type)
        hasher.combine(self.body)
        hasher.combine(self.hidden)
        hasher.combine(self.createdAt)
        hasher.combine(self.deletedAt)
        hasher.combine(self.flaggedBy)
    }

}

// MARK: - CodingKey
private extension CrowdChatMessage {
    
    enum CodingKeys: String, CodingKey {
        case id             = "id"
        case roomIdentifier = "chat_room_id"
        case user           = "chat_room_user"
        case type           = "type"
        case typeData       = "type_data"
        case body           = "body"
        case hidden         = "hidden"
        case createdAt      = "created_at"
        case deletedAt      = "deleted_at"
        case flaggedBy      = "flagged_by"
    }
    
}
