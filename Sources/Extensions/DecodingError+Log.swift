//
//  DecodingError+Log.swift
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

extension DecodingError {
    
    /// String value for a `DecodingError`
    /// - Parameter type: Type of what was being decoded
    /// - Returns: `DecodingError` error information
    func createDecodingLogString(type: String) -> String {
        var errorMessage = "Error Decoding \(type): "
        switch self {
        case DecodingError.dataCorrupted(let context):
            errorMessage += "DataCorrupted, "
            errorMessage += "Description: \(context.debugDescription), "
            errorMessage += "UnderlyingError: \(context.underlyingError?.localizedDescription ?? "N/A"), "
            errorMessage += "CodingPath: \(context.codingPath)"
            
        case DecodingError.keyNotFound(let key, let context):
            errorMessage += "Key Not Found, "
            errorMessage += "\(key.stringValue) was not found, "
            errorMessage += "Description: \(context.debugDescription), "
            errorMessage += "UnderlyingError: \(context.underlyingError?.localizedDescription ?? "N/A"), "
            errorMessage += "CodingPath: \(context.codingPath)"
            
        case DecodingError.typeMismatch(let type, let context):
            errorMessage += "TypeMismatch, "
            errorMessage += "\(type) was expected, "
            errorMessage += "Description: \(context.debugDescription), "
            errorMessage += "UnderlyingError: \(context.underlyingError?.localizedDescription ?? "N/A"), "
            errorMessage += "CodingPath: \(context.codingPath)"
            
        case DecodingError.valueNotFound(let type, let context):
            errorMessage += "Value Not Found, "
            errorMessage += "no value was found for \(type), "
            errorMessage += "Description: \(context.debugDescription), "
            errorMessage += "UnderlyingError: \(context.underlyingError?.localizedDescription ?? "N/A"), "
            errorMessage += "CodingPath: \(context.codingPath)"
            
        default:
            errorMessage += self.localizedDescription
        }
        
        return errorMessage
    }
    
}
