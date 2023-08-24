//
//  CrowdLog.swift
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
import Combine

public class CrowdLog {

    /// Location for where logs present
    public enum Location {
        /// Console
        ///
        /// Printed directly to the console
        case console
        /// Publisher
        ///
        /// Clients can use the Publisher to inspect logs
        case publisher
    }
    
    private var _logReceived = PassthroughSubject<CrowdLogMessage, Never>()
    
    /// Shared Instance for Logger
    public static let shared: CrowdLog = CrowdLog()
    
    /// Location logs are sent
    public var logLocation: Location = .console
    
    /// Subsystems that get logged
    public var allowedSubsystems: [CrowdLogSubsystem] = CrowdLogSubsystem.all

    /// Log Publisher
    public lazy var logReceived: AnyPublisher<CrowdLogMessage, Never> = {
        self._logReceived.eraseToAnyPublisher()
    }()
    
    private init() { }
    
    /// Log a Debug message
    /// - Parameters:
    ///   - message: Message to log
    ///   - subsystem: Subsystem to log as
    ///   - function: Function where log was generated
    ///   - line: Line where log was generated
    class func debug(_ message: String, subsystem: CrowdLogSubsystem, _ function: String = #function, line: Int = #line) {
        guard shared.allowedSubsystems.contains(subsystem) else { return }
        
        let log = CrowdLogMessage(level: .debug,
                                  message: message,
                                  subsystem: subsystem,
                                  function: function,
                                  line: line)
        
        switch shared.logLocation {
        case .console:
            subsystem.logger.debug("\(log.consoleMessage)")
        case .publisher:
            shared._logReceived.send(log)
        }
    }
    
    /// Log an Info message
    /// - Parameters:
    ///   - message: Message to log
    ///   - subsystem: Subsystem to log as
    ///   - function: Function where log was generated
    ///   - line: Line where log was generated
    class func info(_ message: String, subsystem: CrowdLogSubsystem, _ function: String = #function, line: Int = #line) {
        guard shared.allowedSubsystems.contains(subsystem) else { return }

        let log = CrowdLogMessage(level: .info,
                                  message: message,
                                  subsystem: subsystem,
                                  function: function,
                                  line: line)
        
        switch shared.logLocation {
        case .console:
            subsystem.logger.debug("\(log.consoleMessage)")
        case .publisher:
            shared._logReceived.send(log)
        }
    }
    
    /// Log a Notice message
    /// - Parameters:
    ///   - message: Message to log
    ///   - subsystem: Subsystem to log as
    ///   - function: Function where log was generated
    ///   - line: Line where log was generated
    class func notice(_ message: String, subsystem: CrowdLogSubsystem, _ function: String = #function, line: Int = #line) {
        guard shared.allowedSubsystems.contains(subsystem) else { return }

        let log = CrowdLogMessage(level: .notice,
                                  message: message,
                                  subsystem: subsystem,
                                  function: function,
                                  line: line)
        
        switch shared.logLocation {
        case .console:
            subsystem.logger.debug("\(log.consoleMessage)")
        case .publisher:
            shared._logReceived.send(log)
        }
    }
    
    /// Log an Error message
    /// - Parameters:
    ///   - message: Message to log
    ///   - subsystem: Subsystem to log as
    ///   - function: Function where log was generated
    ///   - line: Line where log was generated
    class func error(_ message: String, subsystem: CrowdLogSubsystem, _ function: String = #function, line: Int = #line) {
        guard shared.allowedSubsystems.contains(subsystem) else { return }

        let log = CrowdLogMessage(level: .error,
                                  message: message,
                                  subsystem: subsystem,
                                  function: function,
                                  line: line)
        
        switch shared.logLocation {
        case .console:
            subsystem.logger.debug("\(log.consoleMessage)")
        case .publisher:
            shared._logReceived.send(log)
        }
    }
    
    /// Log a Fault message
    /// - Parameters:
    ///   - message: Message to log
    ///   - subsystem: Subsystem to log as
    ///   - function: Function where log was generated
    ///   - line: Line where log was generated
    class func fault(_ message: String, subsystem: CrowdLogSubsystem, _ function: String = #function, line: Int = #line) {
        guard shared.allowedSubsystems.contains(subsystem) else { return }

        let log = CrowdLogMessage(level: .fault,
                                  message: message,
                                  subsystem: subsystem,
                                  function: function,
                                  line: line)
        
        switch shared.logLocation {
        case .console:
            subsystem.logger.debug("\(log.consoleMessage)")
        case .publisher:
            shared._logReceived.send(log)
        }
    }
    
}
