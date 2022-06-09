//
//  ClientErrorHandler.swift
//  
//
//  Created by Robert Walker on 5/19/22.
//

import Vapor

struct ClientErrorHandler {
    let ws: WebSocket
    let gameSystem: GameSystem
    let logger: Logger

    init(ws: WebSocket, gameSystem: GameSystem, logger: Logger) {
        self.ws = ws
        self.gameSystem = gameSystem
        self.logger = logger
    }
    
    func sendSocketErrorEvent(clientID: ClientUUID, eventName: String, message: String) {
        let socketError = SocketErrorEvent(failedEventName: eventName, errorMessage: message)
        do {
            let errorEventName = OutboundEventName.socketError
            let event = try gameSystem.encodeToString(socketError)
            let socketEvent = WebSocketEvent(clientID: clientID, eventName: errorEventName.rawValue, event: event)
            let message = try gameSystem.encodeToString(socketEvent)
            ws.send(message)
            
            logWithContext(clientID: clientID, eventName: socketError.failedEventName, message: socketError.errorMessage)
        }
        catch {
            logger.error("Failed to encode SocketErrorEvent")
        }
    }
    
    func sendGameErrorEvent(clientID: ClientUUID, gameID: GameUUID, eventName: String, message: String) {
        let gameError = GameErrorEvent(gameID: gameID, failedEventName: eventName, errorMessage: message)
        do {
            let errorEventName = OutboundEventName.gameError
            let event = try gameSystem.encodeToString(gameError)
            let socketEvent = WebSocketEvent(clientID: clientID, eventName: errorEventName.rawValue, event: event)
            let message = try gameSystem.encodeToString(socketEvent)
            ws.send(message)
            
            logWithContext(clientID: clientID, eventName: gameError.failedEventName, message: gameError.errorMessage)
        }
        catch {
            logger.error("Failed to encode GameErrorEvent")
        }
    }
    
    func logWithContext(clientID: UUID, eventName: String, message: String, gameID: String = "") {
        let context = "[clientID: \(clientID), eventName: \(eventName), gameID: \(gameID)]"
        logger.error("\(context) \(message)")
    }
}
