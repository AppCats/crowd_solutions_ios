//
//  CrowdChatRoom.swift
//  CrowdSOLUTIONS
//
//  Created by Kevin Hoogheem on 7/25/22.
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

/// CrowdChat Room
public struct CrowdChatRoom: Decodable {
    /// Rooms Unique Identifier
    public let id: String
    /// Chat Room is Archived (read-only)
    public let archived: Bool
    /// Chat Room is Muted (closed)
    public let muted: Bool
    /// Room Subject
    public let subject: CrowdChatSubject

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        archived = container.decodeFallbackDefaultValue(Bool.self, forKey: .archived, defaultValue: false)
        muted = container.decodeFallbackDefaultValue(Bool.self, forKey: .muted, defaultValue: false)
        subject = try CrowdChatSubject(from: decoder)
    }

}

extension CrowdChatRoom: Equatable {}
extension CrowdChatRoom: Hashable {}

// MARK: - CodingKey
private extension CrowdChatRoom {
    
    enum CodingKeys: String, CodingKey {
        case id         = "id"
        case archived   = "archived"
        case muted      = "mute"
    }
    
}
