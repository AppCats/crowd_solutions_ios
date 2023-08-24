//
//  WebSocketsPresence.swift
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

/// Socket Presence Information
public final class WebSocketsPresence {

    enum Events {
        static let diff   = "presence_diff"
        static let state  = "presence_state"
    }

    /// Presence State
    public typealias WebSocketsPresencePresenceState = [String: [SocketsMeta]]
    /// Presence Diff data
    public typealias SocketsDiff = [String: [String: Any]]
    /// Presence Meta data
    public typealias SocketsMeta = [String: Any]
    
    /// State of Presence
    private(set) public var state: WebSocketsPresencePresenceState
    
    /// Called when someone Joins
    public var onJoin: ((_ id: String, _ meta: SocketsMeta) -> Void)?
    
    /// Called when someone Leaves
    public var onLeave: ((_ id: String, _ meta: SocketsMeta) -> Void)?

    /// Called when someone Joins
    public var onStateChange: ((_ state: WebSocketsPresencePresenceState) -> Void)?

    /// The number of Keys (users)
    @Published
    private(set) public var keys: Int = 0

    init(state: WebSocketsPresencePresenceState = WebSocketsPresence.WebSocketsPresencePresenceState()) {
        self.state = state
    }

}

// MARK: - Presence access convenience
public extension WebSocketsPresence {
    
    /// Meta for Identifier
    /// - Parameter id: Identifier
    /// - Returns: List of `SocketsMeta`
    func metas(id: String) -> [SocketsMeta]? {
        return state[id]
    }

    /// First Meta for Identifier
    /// - Parameter id: Identifier
    /// - Returns: the first `SocketsMeta`
    func firstMeta(id: String) -> SocketsMeta? {
        return state[id]?.first
    }

    /// Meta for Identifier
    /// - Returns: Dictionary of meta information
    func firstMetas() -> [String: SocketsMeta] {
        var result = [String: SocketsMeta]()
        state.forEach { id, metas in
            result[id] = metas.first
        }

        return result
    }
    
    /// First Meta Value
    /// - Parameters:
    ///   - id: identifier
    ///   - key: key
    /// - Returns: the value for the meta
    func firstMetaValue<T>(id: String, key: String) -> T? {
        guard let meta = state[id]?.first, let value = meta[key] as? T else { return nil }

        return value
    }
    
    /// FIrst Meta Vallues
    /// - Parameter key: key
    /// - Returns: List of meta values for key
    func firstMetaValues<T>(key: String) -> [T] {
        var result = [T]()
        state.forEach { id, metas in
            if let meta = metas.first, let value = meta[key] as? T {
                result.append(value)
            }
        }

        return result
    }

}

// MARK: - Syncing
internal extension WebSocketsPresence {
    
    func sync(_ diff: WebSocketsResponse) {
        // Initial state event
        if diff.event == WebSocketsPresence.Events.state {
            diff.payload.forEach { id, entry in
                if let entry = entry as? [String: Any] {
                    if let metas = entry["metas"] as? [SocketsMeta] {
                        state[id] = metas
                    }
                }
            }
            onStateChange?(state)
            self.keys = state.keys.count

        } else if diff.event == WebSocketsPresence.Events.diff {
            let count = state.keys.count

            if let leaves = diff.payload["leaves"] as? SocketsDiff, !leaves.isEmpty {
                syncLeaves(leaves)
            }
            if let joins = diff.payload["joins"] as? SocketsDiff, !joins.isEmpty {
                syncJoins(joins)
            }

            if state.keys.count != count {
                onStateChange?(state)
                self.keys = state.keys.count
            }
        }

    }

    private func syncLeaves(_ diff: SocketsDiff) {
        defer {
            diff.forEach { id, entry in
                if let metas = entry["metas"] as? [SocketsMeta] {
                    metas.forEach { onLeave?(id, $0) }
                }
            }
        }

        for (id, entry) in diff where state[id] != nil {
            guard var existing = state[id] else { continue }

            // If there's only one entry for the id, just remove it.
            if existing.count == 1 {
                state.removeValue(forKey: id)
                continue
            }

            // Otherwise, we need to find the phx_ref keys to delete.
            let metas = entry["metas"] as? [SocketsMeta]
            if let refsToDelete = metas?.compactMap({ $0["phx_ref"] as? String }) {
                existing = existing.filter {
                    if let phxRef = $0["phx_ref"] as? String {
                        return !refsToDelete.contains(phxRef)
                    }
                    
                    return true
                }
                
                // if what is now existing is 0 we should just remove the key
                if existing.isEmpty {
                    state.removeValue(forKey: id)
                    return
                }
                
                // update the key to the remaining metas
                state[id] = existing
            }
        }
    }

    private func syncJoins(_ diff: SocketsDiff) {
        diff.forEach { id, entry in
            if let metas = entry["metas"] as? [SocketsMeta] {
                if var existing = state[id] {
                    existing += metas
                    state[id] = existing
                } else {
                    state[id] = metas
                }
                
                metas.forEach { onJoin?(id, $0) }
            }
        }
    }

}
