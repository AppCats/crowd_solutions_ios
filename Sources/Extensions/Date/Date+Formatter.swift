//
//  Date+Formatter.swift
//  CrowdSOLUTIONS
//
//  Created by Kevin Hoogheem on 8/17/23.
//  Copyright © 2023 AppCats LLC. All rights reserved.
//

import Foundation

extension Date {
    
    /// ISO-8601 Formatter with Fractional Seconds
    /// - note: Timezone of GMT
    static var iso8601UTCFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    /// ISO-8601 Formatter without Fractional Seconds
    /// - note: Timezone of GMT
    static var iso8601FormatterUTCNoFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    /// UTC Timestamp Formatter
    /// - note: Timezone of GMT
    static var UTCTimestampFormatter: DateFormatter = {
        let fileTimeStampFormatter = DateFormatter()
        fileTimeStampFormatter.timeZone = TimeZone(identifier: "GMT")
        fileTimeStampFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return fileTimeStampFormatter
    }()

}

// MARK: - Other Formatters
extension Date {
    
    /// Standard Server Date Format
    /// - note: Timezone of GMT
    static let mapperDateFormatter: DateFormatter = {
        let serverFormatter = DateFormatter()
        serverFormatter.timeZone = TimeZone(identifier: "GMT")
        // server date format = "2016-03-04T15:31:00Z"
        serverFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        return serverFormatter
    }()
    
    /// GMT Format with a `AMZ` timezone indicator
    /// - note: Timezone of GMT
    static let amzFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS' AMZ'"
        return formatter
    }()

    /// GMT Format with a `PMZ` timezone indicator
    /// - note: Timezone of GMT
    static let pmzFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS' PMZ'"
        return formatter
    }()
}
