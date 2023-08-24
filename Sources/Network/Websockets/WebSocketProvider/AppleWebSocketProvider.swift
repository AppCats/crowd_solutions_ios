//
//  AppleWebSocketProvider.swift
//  CrowdSOLUTIONS
//
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

/// Socket Provider based on Apple Websockets
final class AppleWebSocketProvider: NSObject, WebSocketProvider {
    private let callbackQueue: DispatchQueue = .main
    private let request: URLRequest
    private var task: URLSessionWebSocketTask?
    
    private(set) var currentURL: URL
    
    private(set) var isConnected = false
    
    weak var delegate: WebSocketProviderDelegate?
    
    init(request: URLRequest) {
        self.request = request
        self.currentURL = request.url!
        
        super.init()
        
        CrowdLog.info("[WebSockets] AppleWebSocketProvider setup", subsystem: .websocket)
    }
    
    func connect() {
        guard isConnected == false else { return }
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        task = session.webSocketTask(with: request)
        
        startReceiving()
        task?.resume()
    }
    
    func disconnect() {
        isConnected = false
        task?.cancel(with: .abnormalClosure, reason: nil)
    }
    
    func write(_ data: Data) {
        task?.send(.data(data), completionHandler: { error in
            // should we disco here or just eat it
        })
    }
    
}

private extension AppleWebSocketProvider {
    
    func startReceiving() {
        
        task?.receive { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let message):
                if case .string(let string) = message {
                    self.callBackDelegate { $0?.websocketDidReceiveMessage(string) }
                }
                self.startReceiving()
                
            case .failure(let error):
                self.performDisconnect(.receiveData(error.localizedDescription, code: (error as NSError).code))
            }
        }
        
    }
    
}

private extension AppleWebSocketProvider {
    
    func performDisconnect(_ error: WebSocketProviderError) {
        isConnected = false
        callBackDelegate { $0?.websocketDidDisconnect(error: error) }
    }
    
    func callBackDelegate(completion: @escaping (WebSocketProviderDelegate?) -> Void) {
        callbackQueue.async { [weak self] in
            guard let self else { return }
            
            completion(self.delegate)
        }
    }
    
}

// MARK: - URLSessionWebSocketDelegate
extension AppleWebSocketProvider: URLSessionWebSocketDelegate {
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        isConnected = true
        callBackDelegate { $0?.websocketDidConnect() }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        
        let error: WebSocketProviderError
        if let reasonData = reason, let reasonString = String(data: reasonData, encoding: .utf8) {
            error = .disconnection(reasonString, code: closeCode.rawValue)
        } else {
            error = .disconnection("Disconnected", code: closeCode.rawValue)
        }
        
        performDisconnect(error)
    }
    
}
