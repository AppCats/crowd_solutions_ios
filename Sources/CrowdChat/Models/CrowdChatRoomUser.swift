//
//  CrowdChatRoomUser.swift
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

/// CrowdChat Room User
public struct CrowdChatRoomUser: CrowdChatFlaggableContent, Decodable {
    /// Deleted At Date
    let deletedAt: Date?

    /// The Users Id
    public let id: String
    /// User is Blocked
    public let blocked: Bool
    /// Room Role
    public let roomRole: CrowdChatRoomRole
    /// User Name
    public let userName: String
    /// User Photo
    public let userPhoto: URL?
    /// List of Users that Flagged Message
    public let flaggedBy: [CrowdChatRoomUser]

    /// If the user is deleted from Chat server
    public var isDeleted: Bool {
        deletedAt != nil
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        blocked = container.decodeFallbackDefaultValue(Bool.self, forKey: .blocked, defaultValue: false)
        roomRole = try container.decode(CrowdChatRoomRole.self, forKey: .roomRole)

        userName = try container.decode(String.self, forKey: .userName)
        userPhoto = container.decodeStringIntoUrl(forKey: .userPhoto)
        deletedAt = container.decodeStringIntoServerDate(forKey: .deletedAt)
        flaggedBy = (try? container.decodeIfPresent([CrowdChatRoomUser].self, forKey: .flaggedBy)) ?? []
    }

}

extension CrowdChatRoomUser: Equatable {}
extension CrowdChatRoomUser: Hashable {}

// MARK: - CodingKey
private extension CrowdChatRoomUser {
    
    enum CodingKeys: String, CodingKey {
        case id             = "id"
        case blocked        = "blocked"
        case roomRole       = "room_role"
        case userName       = "name"
        case userPhoto      = "profile_photo"
        case deletedAt      = "deleted_at"
        case flaggedBy      = "flagged_by"
    }
    
}
