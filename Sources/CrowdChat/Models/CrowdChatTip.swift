//
//  CrowdChatTip.swift
//  CrowdSOLUTIONS
//
//  Created by Kevin Hoogheem on 8/4/22.
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

/// CrowdChat Coin Tip
public struct CrowdChatTip: Codable, CrowdChatMessageTypeData {
    /// Amount of the Tip Given
    public let amount: String
    /// Any Notes added to the Tip
    public let notes: String?

    public init(amount: String, notes: String?) {
        self.amount = amount
        self.notes = notes
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let amount = try container.decode(String.self, forKey: .amount)
        let notes = try container.decodeIfPresent(String.self, forKey: .notes)
        
        self.init(amount: amount, notes: notes)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(amount, forKey: .amount)
        try container.encodeIfPresent(notes, forKey: .notes)
    }

}

extension CrowdChatTip: Equatable {}
extension CrowdChatTip: Hashable {}

// MARK: - CodingKey
private extension CrowdChatTip {
    
    enum CodingKeys: String, CodingKey {
        case amount = "amount"
        case notes  = "notes"
    }
    
}
