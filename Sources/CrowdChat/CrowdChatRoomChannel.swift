//
//  CrowdChatRoomChannel.swift
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

/// CrowdChat Room Channel
public final class CrowdChatRoomChannel {
        
    private var cancellables = Set<AnyCancellable>()
    private var socket: CrowdChatWebSocket?

    private var socketName: String {
        socket?.socketName ?? "CrowdChat"
    }
    
    /// Pagination Information
    private var pagination: Pagination = Pagination(perPage: 30, page: 1, totalItems: 0, totalPages: 10)
    
    private var isLoadingHistory = false

    /// The number of users in channel
    @Published
    private(set) public var channelUserCount: Int = 0
    
    /// Chat Messages
    @Published
    private(set) public var messages: [CrowdChatMessage] = []
    
    /// List of Chat Messages that are flagged
    private(set) public var flaggedMessages: Set<CrowdChatMessage> = []

    /// List of Chat Room Users that are blocked
    private(set) public var blockedUsers: Set<CrowdChatRoomUser> = []
    
    /// List of Chat Room Users that are flagged
    private(set) public var flaggedUsers: Set<CrowdChatRoomUser> = []

    /// The Chat Room
    private(set) public var chatRoom: CrowdChatRoom?
    
    /// Your Chat Room User
    private(set) public var user: CrowdChatRoomUser?
    
    /// New Server Event Received
    private(set) public var newEventReceived = PassthroughSubject<CrowdChatResponseEvent, Never>()
    
    /// Round Trip Time to Chat Server
    ///
    /// This is the value of the most recent message
    @Published
    private(set) public var messageRoundTripTime: Int = 0

    public init?(server: URL?, token: String, subject: CrowdChatSubject) {
        guard let url = server else { return nil }
        
        self.socket = CrowdChatWebSocket(server: url, token: token, subject: subject)
        
        self.listenForMessageRTTUpdates()
    }
    
}

// MARK: - Connect
public extension CrowdChatRoomChannel {
    
    /// Connects to the CrowdChat Room
    /// - Parameter onConnected: Closure when the connection is completed
    func connect(onConnected: (() -> Void)?) {
        self.socket?.connect { [weak self] roomInfo in
            guard let self else { return }
            
            self.isLoadingHistory = false
            
            self.chatRoom = roomInfo.room
            self.user = roomInfo.user
            self.setupChannelEventListeners()
            
            // on Connect we always get page 1 as messages could have been added
            // this insures that we always have one page worth of New messages
            self.sendMessageHistory(pageInfo: self.pagination.pageInfo) { [weak self] paginatedHistory in
                guard let self else { return }
                
                if let history = try? paginatedHistory.get() {
                    self.updateChatMessages(messages: history.messages)
                    self.updateFlaggedMessages(messages: history.messages)
                }

                CrowdLog.debug("[\(self.socketName)] Channel is Joined", subsystem: .chat)

                onConnected?()

                self.newEventReceived.send(.channelJoin(user: roomInfo.user))
            }
            
            // seed the list of Blocked Users
            if roomInfo.user.roomRole.isModerator {
                self.getBlockedUsers()
            }
            
            // seed the list of Flagged Users
            self.getFlaggedUsers()
        }
    }
    
    /// Leave the Chat Room
    func leave() {
        self.socket?.disconnect()
        self.socket = nil
        
        CrowdLog.debug("[\(self.socketName)] Channel is Disconnected", subsystem: .chat)
    }

}

// MARK: - Message Commands
public extension CrowdChatRoomChannel {
    
    /// Sends a Text based Chat Message
    /// - Parameters:
    ///   - body: Body of Message
    ///   - completion: Sent Success Status
    func sendTextMessage(body: String, completion: ((Bool) -> Void)? = nil) {
        self.sendSocketMessage(CrowdChatCommandTextMessageSend(body: body), completion: completion)
    }
    
    /// Remove Chat Message
    /// - Parameters:
    ///   - id: Identifier of the Message
    ///   - completion: Sent Success Status
    func removeMessage(id: String, completion: ((Bool) -> Void)? = nil) {
        self.sendSocketMessage(CrowdChatCommandRemoveMessage(id: id), completion: completion)
    }
    
    /// Updates the Messages with one page worth of `CrowdChatMessage`
    func getNextMessageHistory() {
        guard self.isLoadingHistory == false else { return }
        guard self.pagination.canFetchNextPage else { return }
        
        self.pagination.incrementPage()
        
        self.isLoadingHistory = true
        
        self.sendMessageHistory(pageInfo: self.pagination.pageInfo) { [weak self] paginatedHistory in
            guard let self else { return }
            self.isLoadingHistory = false
            
            guard let history = try? paginatedHistory.get() else { return }
            
            self.updateChatMessages(messages: history.messages)
            self.updateFlaggedMessages(messages: history.messages)
            self.newEventReceived.send(.messageHistory(count: history.messages.count))
        }
    }

}

// MARK: - Tips
public extension CrowdChatRoomChannel {
    
    /// Sends a Tip to the Chat Server
    /// - Parameters:
    ///   - tip: The `CrowdChatTip`
    ///   - completion: Sent Success Status
    func sendTip(_ tip: CrowdChatTip, completion: ((Bool) -> Void)? = nil) {
        self.sendSocketMessage(CrowdChatCommandTipSend(tip: tip), completion: completion)
    }

}

// MARK: - Flag Commands
public extension CrowdChatRoomChannel {

    /// Flags Chat Message
    /// - Parameters:
    ///   - message: A `CrowdChatMessage` to flag
    ///   - completion: Sent Success Status
    func flagMessage(_ message: CrowdChatMessage, completion: ((Bool) -> Void)? = nil) {
        self.sendSocketMessage(CrowdChatCommandFlagContent(type: .message, contentId: message.id), completion: completion)
    }

    /// Remove Flag from Chat Message
    /// - Parameters:
    ///   - message: A `CrowdChatMessage` to remove flag
    ///   - completion: Sent Success Status
    func unflagMessage(_ message: CrowdChatMessage, completion: ((Bool) -> Void)? = nil) {
        self.sendSocketMessage(CrowdChatCommandUnflagContent(type: .message, contentId: message.id), completion: completion)
    }
    
    /// Flag a User
    /// - Parameters:
    ///   - user: The `CrowdChatRoomUser` to flag
    ///   - completion: Sent Success Status
    func flagUser(_ user: CrowdChatRoomUser, completion: ((Bool) -> Void)? = nil) {
        self.sendSocketMessage(CrowdChatCommandFlagContent(type: .user, contentId: user.id), completion: completion)
    }

    /// Unflag a User
    /// - Parameters:
    ///   - user: The `CrowdChatRoomUser` to unflag
    ///   - completion: Sent Success Status
    func unflagUser(_ user: CrowdChatRoomUser, completion: ((Bool) -> Void)? = nil) {
        self.sendSocketMessage(CrowdChatCommandUnflagContent(type: .user, contentId: user.id), completion: completion)
    }

}

// MARK: - Moderator Only Commands
public extension CrowdChatRoomChannel {
    
    /// Hide Chat Message
    ///
    /// Message will be hidden from all users but the sender.
    /// - Parameters:
    ///   - message: A `CrowdChatMessage` to hide
    ///   - completion: Sent Success Status
    func hideMessage(message: CrowdChatMessage, completion: ((Bool) -> Void)? = nil) {
        self.sendSocketMessage(CrowdChatCommandHideMessage(id: message.id), completion: completion)
    }
    
    /// Block a User from Chat
    /// - Parameters:
    ///   - user: The `CrowdChatRoomUser` to block
    ///   - completion: Sent Success Status
    /// - note: Can only be called by `CrowdChatRoomRole` of `mod`
    func blockUser(_ user: CrowdChatRoomUser, completion: ((Bool) -> Void)? = nil) {
        self.sendSocketMessage(CrowdChatCommandBlockUser(userId: user.id), completion: completion)
    }

    /// Unblock a User from Chat
    /// - Parameters:
    ///   - user: The `CrowdChatRoomUser` to unblock
    ///   - completion: Sent Success Status
    /// - note: Can only be called by `CrowdChatRoomRole` of `mod`
    func unblockUser(_ user: CrowdChatRoomUser, completion: ((Bool) -> Void)? = nil) {
        self.sendSocketMessage(CrowdChatCommandUserUnblock(userId: user.id), completion: completion)
    }

    /// Clears Flag from Chat Message
    /// - Parameters:
    ///   - message: A `CrowdChatMessage` to clear flags
    ///   - completion: Sent Success Status
    /// - note: Can only be called by `CrowdChatRoomRole` of `mod`
    func clearFlaggedMessage(message: CrowdChatMessage, completion: ((Bool) -> Void)? = nil) {
        self.sendSocketMessage(CrowdChatCommandClearFlags(type: .message, contentId: message.id), completion: completion)
    }

    /// Clears flags on a User
    /// - Parameters:
    ///   - user: The `CrowdChatRoomUser` to clear flags
    ///   - completion: Sent Success Status
    /// - note: Can only be called by `CrowdChatRoomRole` of `mod`
    func clearFlaggedUser(_ user: CrowdChatRoomUser, completion: ((Bool) -> Void)? = nil) {
        self.sendSocketMessage(CrowdChatCommandClearFlags(type: .user, contentId: user.id), completion: completion)
    }

}

// MARK: - Flagged Users
private extension CrowdChatRoomChannel {
    
    /// Gets a List of users that are currently Flagged
    func getFlaggedUsers() {
        let command = CrowdChatCommandFlaggedList(type: .user)
        
        CrowdLog.info("[\(self.socketName)] Sending Command for Event: \(command.event)", subsystem: .chat)

        self.socket?.channel?.send(command.event, payload: command.payload, type: [CrowdChatRoomUser].self) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let flagged):
                flagged.forEach {
                    self.flaggedUsers.update(with: $0)
                }
                
                self.newEventReceived.send(.flaggedUsers)

            case .failure(let error):
                CrowdLog.error(error.localizedDescription, subsystem: .chat)
            }
        }
    }

}

// MARK: - Blocked Users
private extension CrowdChatRoomChannel {
    
    /// Gets a List of users that are currently Blocked
    func getBlockedUsers() {
        let command = CrowdChatCommandUsersBlocked()
        
        CrowdLog.info("[\(self.socketName)] Sending Command for Event: \(command.event)", subsystem: .chat)

        self.socket?.channel?.send(command.event, payload: command.payload, type: CrowdChatCommandUsersBlocked.Response.self) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let blocked):
                blocked.users.forEach {
                    self.blockedUsers.update(with: $0)
                }
                
                self.newEventReceived.send(.blockedUsers)

            case .failure(let error):
                CrowdLog.error(error.localizedDescription, subsystem: .chat)
            }
        }
    }

}

// MARK: - Socket Message
private extension CrowdChatRoomChannel {
    
    /// Sends Socket Message
    /// - Parameters:
    ///   - command: the `CrowdChatEventSocketCommand` to send
    ///   - completion: indication of success for failure
    func sendSocketMessage(_ command: CrowdChatEventSocketCommand, completion: ((Bool) -> Void)?) {
        guard let user = self.user else { return }
        
        if command is CrowdChatEventSocketCommandModSendable && !user.roomRole.isModerator {
            CrowdLog.info("[\(self.socketName)] Non Moderator Tried Sending Command for Event: \(command.event)", subsystem: .chat)
            return
        }

        CrowdLog.info("[\(self.socketName)] Sending Command for Event: \(command.event)", subsystem: .chat)

        self.socket?.channel?.send(command.event, payload: command.payload)?
            .receive(.ok, callback: { [weak self] response in
                guard let _ = self else { return }
                completion?(true)
            })
            .receive(.error, callback: { [weak self] response in
                guard let self else { return }

                if let message = WebSocketsResponse.processPayloadReason(response) {
                    let msg = "[\(self.socketName)] Send (\(command.event)) Error: " + message
                    CrowdLog.error(msg, subsystem: .chat)
                }
                
                completion?(false)
            })
    }
    
    /// Request the list of Message History
    ///
    /// - Parameter completion: `CrowdChatPaginatedChatMessages`
    func sendMessageHistory(pageInfo: PaginationPageInfo, completion: @escaping (Result<CrowdChatPaginatedChatMessages, Error>) -> Void) {
        let command = CrowdChatCommandMessageHistory(pageInfo: pageInfo)

        CrowdLog.info("[\(self.socketName)] Sending Command for Event: \(command.event)", subsystem: .chat)

        self.socket?.channel?.send(command.event, payload: command.payload, type: CrowdChatPaginatedChatMessages.self) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let messages):
                self.pagination = messages.pagination
                completion(.success(messages))

            case .failure(let error):
                CrowdLog.error(error.localizedDescription, subsystem: .chat)

                completion(.failure(error))
            }
        }

    }
    
    /// Updates Flagged Message Set
    /// - Parameter messages: Messages to check flagged status
    func updateFlaggedMessages(messages: [CrowdChatMessage]) {
        guard !messages.isEmpty else { return }
        
        var copyOfFlaggedMessages = self.flaggedMessages
        
        for message in messages {
            
            if message.flaggedBy.isEmpty {
                // If there is no Flagged by we can just discard it from our
                // list of flagged messages

                if let index = copyOfFlaggedMessages.firstIndex(where: { $0.id == message.id }) {
                    copyOfFlaggedMessages.remove(at: index)
                }
                
            } else {
                
                if !copyOfFlaggedMessages.contains(where: { $0.id == message.id }) {
                    copyOfFlaggedMessages.update(with: message)
                } else {
                    
                    if let index = copyOfFlaggedMessages.firstIndex(where: { $0.id == message.id }) {
                        copyOfFlaggedMessages.remove(at: index)
                    }
                    copyOfFlaggedMessages.update(with: message)
                }
            }
        }
        
        self.flaggedMessages = copyOfFlaggedMessages
    }
    
    /// Updates Flagged Users Set
    /// - Parameter users: Users to check flagged status
    func updateFlaggedUsers(users: [CrowdChatRoomUser]) {
        guard !users.isEmpty else { return }

        var copyOfFlaggedUsers = self.flaggedUsers

        for user in users {
            
            if user.flaggedBy.isEmpty {
                // If there is no Flagged by we can just discard it from our
                // list of flagged messages

                if let index = copyOfFlaggedUsers.firstIndex(where: { $0.id == user.id }) {
                    copyOfFlaggedUsers.remove(at: index)
                }
                
            } else {
                
                if let index = copyOfFlaggedUsers.firstIndex(where: { $0.id == user.id }) {
                    copyOfFlaggedUsers.remove(at: index)
                }
                copyOfFlaggedUsers.update(with: user)

            }
        }
        
        self.flaggedUsers = copyOfFlaggedUsers
    }
    
    /// Updates the list of Chat Messages
    /// - Parameter messages: Messages to add, remove or update
    func updateChatMessages(messages: [CrowdChatMessage]) {
        guard !messages.isEmpty else { return }
                
        var newMessages = self.messages
        for message in messages {
            
            if !newMessages.contains(where: { $0.id == message.id }) {
                newMessages.append(message)
            } else {
                
                if let containedMsg = newMessages.first(where: { $0.id == message.id }) {
                    if containedMsg != message {
                        if let index = newMessages.firstIndex(where: { $0.id == message.id }) {
                            newMessages.remove(at: index)
                        }
                        newMessages.append(message)
                    }
                }

            }
        }
        
        self.messages = newMessages.sorted(by: <)
    }
}

// MARK: - Channel Events
private extension CrowdChatRoomChannel {
    
    func setupChannelEventListeners() {
        self.listenForPresenceUpdates()
        self.setupChannelEventMessages()
        self.setupChannelFlaggableEventMessages()
    }
    
    func listenForPresenceUpdates() {
        self.socket?.channel?.presence.$keys.onMain.weakAssign(to: \.channelUserCount, on: self).store(in: &cancellables)
    }
    
    func listenForMessageRTTUpdates() {        
        self.socket?.messageRoundTripTime.onMain.weakAssign(to: \.messageRoundTripTime, on: self).store(in: &cancellables)
    }

    func setupChannelEventMessages() {
        self.socket?.channel?.on(CrowdChatCommandNewMessageResponse.event, callback: { [weak self] response in
            guard let self else { return }

            if let action = CrowdChatCommandNewMessageResponse(event: response.event, payload: response.payload) {
                self.updateChatMessages(messages: [action.message])
                self.newEventReceived.send(.newMessage)
            }
        })

        self.socket?.channel?.on(CrowdChatCommandRemoveMessageResponse.event, callback: { [weak self] response in
            guard let self else { return }

            if let action = CrowdChatCommandRemoveMessageResponse(event: response.event, payload: response.payload) {
                guard let index = self.messages.firstIndex(where: { $0.id == action.message.id }) else { return }
                self.messages.remove(at: index)
                // Add it back as it says "Message Removed"
                self.updateChatMessages(messages: [action.message])
                self.newEventReceived.send(.messageRemoved)
            }
        })
        
        self.socket?.channel?.on(CrowdChatCommandHideMessageResponse.event, callback: { [weak self] response in
            guard let self else { return }

            if let action = CrowdChatCommandHideMessageResponse(event: response.event, payload: response.payload) {
                guard let index = self.messages.firstIndex(where: { $0.id == action.message.id }) else { return }
                self.messages.remove(at: index)
                // Add it back as it has changed the hidden
                self.updateChatMessages(messages: [action.message])
                self.newEventReceived.send(.messageHidden)
            }
        })

        self.socket?.channel?.on(CrowdChatCommandUserBlockedResponse.event, callback: { [weak self] response in
            guard let self else { return }

            if let action = CrowdChatCommandUserBlockedResponse(event: response.event, payload: response.payload) {
                if action.user.id == self.user?.id {
                    self.user = action.user
                } else {
                    if !self.blockedUsers.contains(where: { $0.id == action.user.id }) {
                        self.blockedUsers.insert(action.user)
                    }
                }

                self.newEventReceived.send(.userBlocked)
            }
        })

        self.socket?.channel?.on(CrowdChatCommandUserUnblockedResponse.event, callback: { [weak self] response in
            guard let self else { return }

            if let action = CrowdChatCommandUserUnblockedResponse(event: response.event, payload: response.payload) {
                if action.user.id == self.user?.id {
                    self.user = action.user
                } else {
                    if let user = self.blockedUsers.first(where: { $0.id == action.user.id }) {
                        self.blockedUsers.remove(user)
                    }
                }

                self.newEventReceived.send(.userUnblocked)
            }
        })
        
        self.socket?.channel?.on(CrowdChatCommandArchiveResponse.event, callback: { [weak self] _ in
            guard let self else { return }
            
            // No need to decode payload as we only care about the event
            self.newEventReceived.send(.chatRoomArchived)
        })
        
        self.socket?.channel?.on(CrowdChatCommandUnarchiveResponse.event, callback: { [weak self] _ in
            guard let self else { return }
            
            // No need to decode payload as we only care about the event
            self.newEventReceived.send(.chatRoomUnarchived)
        })
    }
    
}

// MARK: - Channel Events: Flags
private extension CrowdChatRoomChannel {
    
    /// Process the Unflag / clear flags response
    /// - Parameter response: The `WebSocketsResponse`
    func processUnflagging(response: WebSocketsResponse) {
        if let action = CrowdChatCommandFlaggableContentResponse(event: response.event, payload: response.payload) {
            switch action.type {
            case .message:
                guard let message = action.content as? CrowdChatMessage else { return }

                self.updateFlaggedMessages(messages: [message])
                self.newEventReceived.send(.unflaggedContent(type: .message))

            case .user:
                guard let user = action.content as? CrowdChatRoomUser else { return }

                self.updateFlaggedUsers(users: [user])
                self.newEventReceived.send(.unflaggedContent(type: .user))
            }
        }
    }

    func setupChannelFlaggableEventMessages() {
        
        self.socket?.channel?.on(CrowdChatCommandFlaggableContentResponse.flaggedEvent, callback: { [weak self] response in
            guard let self else { return }

            if let action = CrowdChatCommandFlaggableContentResponse(event: response.event, payload: response.payload) {
                switch action.type {
                case .message:
                    guard let message = action.content as? CrowdChatMessage else { return }

                    self.updateFlaggedMessages(messages: [message])
                    self.newEventReceived.send(.flaggedContent(type: .message))
                    
                case .user:
                    guard let user = action.content as? CrowdChatRoomUser else { return }

                    self.updateFlaggedUsers(users: [user])
                    self.newEventReceived.send(.flaggedContent(type: .user))
                }
            }
        })
                
        self.socket?.channel?.on(CrowdChatCommandFlaggableContentResponse.unflaggedEvent, callback: { [weak self] response in
            guard let self else { return }
            self.processUnflagging(response: response)
        })

        self.socket?.channel?.on(CrowdChatCommandFlaggableContentResponse.clearedFlagsEvent, callback: { [weak self] response in
            guard let self else { return }
            self.processUnflagging(response: response)
        })

    }

}
