//
//  CrowdChatWebSocket.swift
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
import Combine
import UIKit
 
final class CrowdChatWebSocket {
    
    private var cancellables = Set<AnyCancellable>()
    private var pollingTimer: AnyCancellable?

    private var appEnteredBackground: Bool = false

    private let chatRoomTopicPrefix = "chat_room:"

    private var socket: WebSocket!
    
    /// CrowdChat Token
    ///
    /// This is a Token created by the Client App
    private let token: String
        
    private let subject: CrowdChatSubject
    
    private var onChannelJoined: OnChannelJoinedBlock?

    let socketName: String = "CrowdChat"

    typealias OnChannelJoinedBlock = ((_ info: CrowdChatRoomJoinResponse) -> Void)

    /// Socket Channel
    private(set) var channel: WebSocketsChannel?
    
    /// Socket Connection Status
    public var isConnected: Bool {
        self.socket != nil ? self.socket.isConnected : false
    }

    /// Round Trip Time to Chat Server
    ///
    /// This is the value of the most recent message
    public var messageRoundTripTime: AnyPublisher<Int, Never> {
        self.socket.$messageRoundTripTime.removeDuplicates().eraseToAnyPublisher()
    }

    init(server: URL?, token: String, subject: CrowdChatSubject) {
        self.token = token
        self.subject = subject
        
        setupSocket(server: server)
    }

}

// MARK: - Connection
extension CrowdChatWebSocket {
    
    /// Connects to the Socket
    /// - Parameter onChannelJoined: Closure with the Chat Room User that connected
    func connect(onChannelJoined: @escaping OnChannelJoinedBlock) {
        self.onChannelJoined = onChannelJoined
        
        if self.socket != nil {
            self.socket.connect()
            self.setupNotificationCenterObservers()
        }

    }
        
    /// Disconnect from socket
    func disconnect() {
        self.appEnteredBackground = true
        if self.socket != nil {
            self.socket.disconnect()
        }
        self.pollingTimer?.cancel()
        self.pollingTimer = nil
    }

    private func createChannel(subject: CrowdChatSubject) {
        let topic = chatRoomTopicPrefix + "\(subject.identifier)"

        self.channel = self.socket.channel(topic)
    }

}

// MARK: - Socket Setup
private extension CrowdChatWebSocket {
    
    func setupSocket(server: URL?) {
        guard let url = server, var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            CrowdLog.error("[\(self.socketName)] Sever URL Invalid", subsystem: .chat)
            return
        }

        let query = [
            URLQueryItem(name: "token", value: self.token)
        ]

        if components.queryItems == nil {
            components.queryItems = query
        } else {
            components.queryItems?.append(contentsOf: query)
        }
        
        guard let socketURL = components.url else {
            CrowdLog.error("[\(self.socketName)] Sever URL Invalid", subsystem: .chat)
            return
        }
        
        socket = WebSocket(url: socketURL)
        socket.heartbeatFailureTolerance = 2
        socket.socketName = self.socketName

        self.socket.onConnect = { [weak self] in
            guard let self else { return }
            CrowdLog.info("[\(self.socketName)] Socket Connected", subsystem: .chat)

            self.createChannel(subject: self.subject)

            self.appEnteredBackground = false
            
            if self.pollingTimer != nil {
                self.pollingTimer?.cancel()
                self.pollingTimer = nil
            }
            
            self.channel?.join(type: CrowdChatRoomJoinResponse.self, completion: { [weak self] result in
                guard let self else { return }

                switch result {
                case .success(let room):
                    self.onChannelJoined?(room)

                case .failure(let error):
                    CrowdLog.error(error.localizedDescription, subsystem: .chat)
                    self.socket.disconnect()
                }
            })
        }

        self.socket.onDisconnect = { [weak self] error in
            guard let self else { return }
            
            if !self.appEnteredBackground {
                self.setupReconnectionTimer()
            }

            self.channel?.leave()
            
            CrowdLog.error("[\(self.socketName)] Socket Disconnected: \(String(describing: error?.localizedDescription))", subsystem: .chat)
        }

    }
    
}

// MARK: - Helpers
private extension CrowdChatWebSocket {
    
    func pause(channel: WebSocketsChannel) {
        channel.leave()
    }
        
    func connectIfNot() {
        if !self.socket.isConnected && !self.socket.isConnecting {
            self.socket.connect()
        }
    }

}

// MARK: - Reconnect
private extension CrowdChatWebSocket {
    
    func setupReconnectionTimer() {
        self.pollingTimer = Timer.publish(every: 5.0, on: .main, in: .default).autoconnect().sink { [weak self] _ in
            guard let self else { return }
            self.connectIfNot()
        }
    }
}

// MARK: - Notification Center
private extension CrowdChatWebSocket {
        
    func setupNotificationCenterObservers() {
        
        NotificationCenter.default
            .publisher(for: UIApplication.didEnterBackgroundNotification)
            .onMain
            .sink { [weak self] notification in
                guard let self else { return }
                
                self.appEnteredBackground = true
                self.socket.disconnect()
                
            }
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)
            .onMain
            .sink { [weak self] notification in
                guard let self else { return }
                
                self.connectIfNot()
                
            }
            .store(in: &cancellables)
    }

}
