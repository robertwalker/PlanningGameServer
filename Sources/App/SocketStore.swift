//
//  SocketStore.swift
//  
//
//  Created by Robert Walker on 1/24/21.
//

import Foundation
import Vapor

enum SocketStoreError: Error {
    case clientIDNotFound
    case clientNotFound
}

class SocketStore {
    let eventLoop: EventLoop
    var clients: Set<WebSocket> = []
    private var clientIDToSocket: [ClientUUID:WebSocket] = [:]
    private var socketToclientID: [WebSocket:ClientUUID] = [:]
    var active: Set<WebSocket> {
        clients.filter { !$0.isClosed }
    }
    
    init(eventLoop: EventLoop) {
        self.eventLoop = eventLoop
    }

    func addClient(_ client: WebSocket, clientID: ClientUUID) {
        clients.insert(client)
        clientIDToSocket[clientID] = client
        socketToclientID[client] = clientID
    }
    
    func removeClient(_ client: WebSocket) {
        guard let clientID = socketToclientID[client] else {
            return
        }
        socketToclientID[client] = nil
        clientIDToSocket[clientID] = nil
        clients.remove(client)
    }
    
    func findClientID(_ client: WebSocket) throws -> ClientUUID {
        guard let clientID = socketToclientID[client] else {
            throw SocketStoreError.clientIDNotFound
        }
        return clientID
    }
    
    func findClient(clientID: ClientUUID) throws -> WebSocket {
        guard let client = clientIDToSocket[clientID] else {
            throw SocketStoreError.clientNotFound
        }
        return client
    }

    deinit {
        let futures = clients.map { $0.close() }
        try! self.eventLoop.flatten(futures).wait()
    }
}

extension WebSocket: Equatable {
    public static func == (lhs: WebSocket, rhs: WebSocket) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

extension WebSocket: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
