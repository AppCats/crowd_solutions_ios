//
//  KeyedDecodingContainer+Helpers.swift
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
#if canImport(UIKit)
import UIKit
#endif
#if canImport(Cocoa)
import Cocoa
#endif

extension KeyedDecodingContainer {
    
    /// Decodes a value of the given type for the given key, if present or default value.
    ///
    /// This method returns `defaultValue` if the container does not have a value
    /// associated with `key`, or if the value is null. The difference between
    /// these states can be distinguished with a `contains(_:)` call.
    ///
    /// - parameter type: The type of value to decode.
    /// - parameter key: The key that the decoded value is associated with.
    /// - parameter defaultValue: The default value to use if not present or decode fails.
    /// - returns: A decoded value of the requested type, or `defaultValue` if the
    ///   `Decoder` does not have an entry associated with the given key, or if
    ///   the value is a null value.
    func decodeFallbackDefaultValue<T: Decodable>(_ type: T.Type, forKey key: KeyedDecodingContainer<K>.Key, defaultValue: T) -> T {
        switch type {
        case is Bool.Type:
            return (decodeStringOrBoolAsBoolIfPresent(forKey: key) as? T) ?? defaultValue
            
        default:
            break
        }
        return (try? decodeIfPresent(T.self, forKey: key)) ?? defaultValue
    }
    
    /// Decodes a URL for the given key, if present or optional URL.
    ///
    /// This method returns `nil` if the container does not have a value
    /// associated with `key`, or if the value is null. The difference between
    /// these states can be distinguished with a `contains(_:)` call.
    ///
    /// - parameter type: The type of value to decode.
    /// - parameter key: The key that the decoded value is associated with.
    /// - returns: A decoded value of the requested type, or `nil` if the
    ///   `Decoder` does not have an entry associated with the given key, or if
    ///   the value is a null value.
    func decodeStringIntoUrl(forKey key: KeyedDecodingContainer<K>.Key) -> URL? {
        return try? decodeIfPresent(String.self, forKey: key).toURL()
    }
    
    /// Decodes a String into a Date for the given key, if present or optional Date.
    ///
    /// This method returns `nil` if the container does not have a value
    /// associated with `key`, or if the value is null. The difference between
    /// these states can be distinguished with a `contains(_:)` call.
    ///
    /// - parameter type: The type of value to decode.
    /// - parameter key: The key that the decoded value is associated with.
    /// - returns: A decoded value of the requested type, or `nil` if the
    ///   `Decoder` does not have an entry associated with the given key, or if
    ///   the value is a null value.
    func decodeStringIntoServerDate(forKey key: KeyedDecodingContainer<K>.Key) -> Date? {
        let dateString = (try? decodeIfPresent(String.self, forKey: key)) ?? ""
        return Date.convertDate(dateString)
    }
    
    /// Decodes a value of the given type for the given key, if present or empty string.
    ///
    /// This method returns `nil` if the container does not have a value
    /// associated with `key`, or if the value is null. The difference between
    /// these states can be distinguished with a `contains(_:)` call.
    ///
    /// - parameter type: The type of value to decode.
    /// - parameter key: The key that the decoded value is associated with.
    /// - returns: A decoded value of the requested type, or `nil` if the
    ///   `Decoder` does not have an entry associated with the given key, or if
    ///   the value is a null value.
    /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value
    ///   is not convertible to the requested type.
    func decodeIfPresentOrEmpty(_ type: String.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> String? {
        if let testString = try decodeIfPresent(String.self, forKey: key), testString.isEmpty == false {
            return testString
        }
        
        return nil
    }
    
    /// Decodes a value for the given key, if String or a Decimal Number.
    ///
    /// This method returns `nil` if the container does not have a value
    /// associated with `key`, or if the value is null. The difference between
    /// these states can be distinguished with a `contains(_:)` call.
    ///
    /// - parameter key: The key that the decoded value is associated with.
    /// - returns: A decoded value of the requested type, or `nil` if the
    ///   `Decoder` does not have an entry associated with the given key, or if
    ///   the value is a null value.
    /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value
    ///   is not convertible to the requested type.
    func decodeStringOrDecimalAsStringIfPresent(forKey key: KeyedDecodingContainer<K>.Key) throws -> String? {
        let stringValue = try? decodeIfPresent(String.self, forKey: key)
        
        if let stringValue = stringValue {
            return stringValue
        }
        
        if let testnumber = try decodeIfPresent(Decimal.self, forKey: key) ?? nil {
            return NSDecimalNumber(decimal: testnumber).stringValue
        }
        
        return nil
    }
    
    /// Decodes a value for the given key, if String or a Decimal and return as Int.
    ///
    /// This method returns `nil` if the container does not have a value
    /// associated with `key`, or if the value is null. The difference between
    /// these states can be distinguished with a `contains(_:)` call.
    ///
    /// - parameter key: The key that the decoded value is associated with.
    /// - returns: A decoded value of the requested type, or `nil` if the
    ///   `Decoder` does not have an entry associated with the given key, or if
    ///   the value is a null value.
    /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value
    ///   is not convertible to the requested type.
    func decodeStringOrDecimalAsIntIfPresent(forKey key: KeyedDecodingContainer<K>.Key) throws -> Int? {

        if let stringValue = try? decodeIfPresent(String.self, forKey: key) {
            guard !stringValue.isBlankString else { return nil }
            // don't let blank space otherwise you get 9 back
            return NSDecimalNumber(string: stringValue).intValue
        }
        
        if let decimalValue = try decodeIfPresent(Decimal.self, forKey: key) ?? nil {
            return NSDecimalNumber(decimal: decimalValue).intValue
        }
        
        return nil
    }
    
    /// Decodes a value for the given key, if String or a Bool and return as Bool.
    ///
    /// This method returns `nil` if the container does not have a value
    /// associated with `key`, or if the value is null. The difference between
    /// these states can be distinguished with a `contains(_:)` call.
    ///
    /// - parameter key: The key that the decoded value is associated with.
    /// - returns: A decoded value of the requested type, or `nil` if the
    ///   `Decoder` does not have an entry associated with the given key, or if
    ///   the value is a null value.
    /// - Throws: `DecodingError.typeMismatch` if the encountered encoded value
    ///   is not convertible to the requested type.
    func decodeStringOrBoolAsBoolIfPresent(forKey key: KeyedDecodingContainer<K>.Key) -> Bool? {
        
        let stringValue = try? decodeIfPresent(String.self, forKey: key)
        
        if let stringValue = stringValue, let bool = Bool(trueFalse: stringValue) {
            return bool
        }
        
        let boolValue = try? decodeIfPresent(Bool.self, forKey: key)
        
        if let boolValue = boolValue {
            return boolValue
        }
        
        return nil
    }
        
}
