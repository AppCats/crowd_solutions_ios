//
//  CrowdChatMessageType.swift
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

/// Type of Chat Message
public enum CrowdChatMessageType: String, Codable {
    /// Tennis Update
    case tennisUpdate   = "tennis_update"
    /// Text Based Message
    case text           = "message"
    /// Welcome To Chat Message
    case welcome        = "welcome_message"
    /// Coin Tip Received
    case tipReceived    = "tip_received"

    /// Decodes a `CrowdChatMessageTypeData`, if present.
    ///
    /// This throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    func decodeTypeDataIfPresent(from decoder: Decoder) throws -> CrowdChatMessageTypeData? {
        enum CodingKeys: String, CodingKey {
            case type
            case typeData = "type_data"
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(CrowdChatMessageType.self, forKey: .type)

        switch type {
        case .tennisUpdate, .text:
            return nil
        case .welcome:
            let element = try container.decodeIfPresent(SafeDecodableElement<CrowdChatMessageTypeDataWelcome>.self, forKey: .typeData)
            return element?.decodedElement
        case .tipReceived:
            let element = try container.decodeIfPresent(SafeDecodableElement<CrowdChatTip>.self, forKey: .typeData)
            return element?.decodedElement
        }
    }
}

extension CrowdChatMessageType: Equatable {}
extension CrowdChatMessageType: Hashable {}
