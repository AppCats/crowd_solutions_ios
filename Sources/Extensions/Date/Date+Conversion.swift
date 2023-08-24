//
//  Date+Conversion.swift
//  CrowdSOLUTIONS
//
//  Created by Kevin Hoogheem on 8/17/23.
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

extension Date {
    
    /// Converts a Date using Date Formatters
    /// - Parameter string: Date string
    /// - Returns: Date
    static func convertDate(_ string: String) -> Date? {
        guard string.isBlankString == false else { return nil }
        
        if let date = Date.mapperDateFormatter.date(from: string) {
            return date
        }
        
        if let backupDate = Date.UTCTimestampFormatter.date(from: string) {
            return backupDate
        }
        
        if let iso8601 = Date.iso8601UTCFormatter.date(from: string) {
            return iso8601
        }
        
        if let iso8601NoSeconds = Date.iso8601FormatterUTCNoFractionalSeconds.date(from: string) {
            return iso8601NoSeconds
        }

        if let amz = Date.amzFormatter.date(from: string) {
            return amz
        }

        if let pmz = Date.pmzFormatter.date(from: string) {
            return pmz
        }

        return nil
    }
}
