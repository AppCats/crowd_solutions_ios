//
//  CrowdChatCommandMessageHistory.swift
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

/// Command that sends the History command
///
/// This will resspond back with a paginated list of chat messages
struct CrowdChatCommandMessageHistory: CrowdChatEventSocketCommand {
    var event: String = "history"
    
    /// Pagination Page
    let pageInfo: PaginationPageInfo

    var payload: WebSocket.Payload {        
        [
            "pagination": [
                "page": self.pageInfo.page,
                "per_page": self.pageInfo.perPage
            ]
        ]
    }

    init(pageInfo: PaginationPageInfo) {
        self.pageInfo = pageInfo
    }
        
}
