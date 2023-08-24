//
//  Combine+WeakAssign.swift
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
import Combine

extension Publisher where Failure == Never {
    
    /// Weakly Assigns each element from a publisher to a property on an object
    /// - Parameters:
    ///   - keyPath: A key path that indicates the property to assign. See [Key-Path Expression]
    ///   - object: The object that contains the property. The subscriber assigns the object’s property every time it receives a new value
    /// - Returns: An `AnyCancellable` instance. Call `Cancellable/cancel()` on this instance when you no longer want the publisher to automatically assign the property. Deinitializing this instance will also cancel automatic assignment
    func weakAssign<T: AnyObject>(to keyPath: ReferenceWritableKeyPath<T, Output>, on object: T) -> AnyCancellable {
        sink { [weak object] value in
            guard let object else { return }
            
            object[keyPath: keyPath] = value
        }
    }
}
