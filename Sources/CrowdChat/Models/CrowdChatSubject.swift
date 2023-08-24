//
//  CrowdChatSubject.swift
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

/// CrowdChat Subject Defines the Chat Room Subject Matter
public struct CrowdChatSubject: Codable {
    /// Subject Identifier
    ///
    /// This is an ID that matches the `CrowdChatSubjectType`
    /// for example a `broadcastEvent` should use the identifier is a Broadcast Event Identifier
    public let identifier: String
    /// Optional Subject Name
    public let name: String?
    /// Subject Type
    public let type: CrowdChatSubjectType

    public init(identifier: String, name: String?, type: CrowdChatSubjectType) {
        self.identifier = identifier
        self.name = name
        self.type = type

    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let identifier = try container.decode(String.self, forKey: .identifier)
        let name = try container.decodeIfPresent(String.self, forKey: .name)
        let type = try container.decode(CrowdChatSubjectType.self, forKey: .type)
        
        self.init(identifier: identifier, name: name, type: type)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(identifier, forKey: .identifier)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encode(type, forKey: .type)
    }

}

extension CrowdChatSubject: Equatable {}
extension CrowdChatSubject: Hashable {}

// MARK: - CodingKey
private extension CrowdChatSubject {
    
    enum CodingKeys: String, CodingKey {
        case identifier = "subject_id"
        case name       = "subject_name"
        case type       = "subject_type"
    }
    
}
