//
//  Pagination.swift
//  CrowdSOLUTIONS
//
//  Created by Kevin Hoogheem on 8/16/23.
//  Copyright © 2023 AppCats LLC. All rights reserved.
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

/// Pagination Information
struct Pagination: Codable {
    /// Page Info
    var pageInfo: PaginationPageInfo
    /// Total Items
    let totalItems: Int
    /// Total Pages
    let totalPages: Int
    
    /// `true` if there are more pages available to fetch, otherwise `false` if all of the pages have already been fetched
    var canFetchNextPage: Bool {
        pageInfo.page + 1 <= totalPages
    }
    
    /// Creates Pagination Information
    ///
    /// - Parameters:
    ///   - pageInfo: Page Information
    ///   - totalItems: Total number of items
    ///   - totalPages: Total number of pages
    init(pageInfo: PaginationPageInfo, totalItems: Int, totalPages: Int) {
        self.pageInfo = pageInfo
        self.totalItems = totalItems
        self.totalPages = totalPages
    }
    
    /// Creates Pagination Information
    ///
    /// - Parameters:
    ///   - perPage: Items per page
    ///   - page: Page to get data from
    ///   - totalItems: Total number of items
    ///   - totalPages: Total number of pages
    init(perPage: Int, page: Int, totalItems: Int, totalPages: Int) {
        self.pageInfo = PaginationPageInfo(page: page, perPage: perPage)
        self.totalItems = totalItems
        self.totalPages = totalPages
    }
    
    /// Creates Pagination Information
    ///
    /// - Parameters:
    ///   - perPage: Items per page
    ///   - page: Page to get data from
    /// - Note: Defaults `totalItems`: 0 and `totalPages`: 10
    init(perPage: Int, page: Int) {
        self.pageInfo = PaginationPageInfo(page: page, perPage: perPage)
        self.totalItems = 0
        // The Total Pages is just set to something higher then 2 so we can Fetch at least
        // the first page then start getting Pagination Items from the Server
        // which will provide us with the real number of total Pages
        self.totalPages = 10
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let page = try container.decode(Int.self, forKey: .page)
        let perPage = try container.decode(Int.self, forKey: .perPage)
        self.pageInfo = PaginationPageInfo(page: page, perPage: perPage)
        totalItems = try container.decode(Int.self, forKey: .totalItems)
        totalPages = try container.decode(Int.self, forKey: .totalPages)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(pageInfo.page, forKey: .page)
        try container.encode(pageInfo.perPage, forKey: .perPage)
        try container.encode(totalPages, forKey: .totalPages)
        try container.encode(totalItems, forKey: .totalItems)
    }
    
    /// Increases the `PageInfo` page by 1 and returns the current page
    ///
    /// - note: If nextPage is greater than the total number of pages, the last page will be returned
    @discardableResult
    mutating func incrementPage() -> Int {
        guard self.canFetchNextPage else { return self.totalPages }
        
        self.pageInfo.page += 1
        return self.pageInfo.page
    }
}

// MARK: - CodingKeys
private extension Pagination {
    
    enum CodingKeys: String, CodingKey {
        case perPage    = "per_page"
        case page       = "page"
        case totalItems = "total"
        case totalPages = "total_pages"
    }
}
