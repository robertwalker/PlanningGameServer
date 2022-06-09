//
//  ChannelController.swift
//  
//
//  Created by Robert Walker on 1/24/21.
//

import Vapor

struct ChannelController {
    let socketStore: SocketStore
    let gameStore: GameStore
    let gameSystem = GameSystem()
    
    func channel(req: Request, ws: WebSocket) {
        let errorHandler = ClientErrorHandler(ws: ws, gameSystem: gameSystem, logger: req.logger)
        req.logger.info("WebSocket connected")
        handleConnection(ws, logger: req.logger)
        req.logger.info("Clients connected: \(socketStore.clients.count)")
        
        ws.onText { (ws, message) in
            req.logger.info("Message received: \(message)");
            do {
                let socketEvent = try gameSystem.decodeFromString(WebSocketEvent.self, from: message)
                var controller = SocketEventController(
                    webSocket: ws,
                    socketStore: socketStore,
                    gameStore: gameStore,
                    gameSystem: gameSystem,
                    clientErrorHandler: errorHandler,
                    logger: req.logger
                )
                controller.handleEvent(socketEvent: socketEvent)
            }
            catch {
                req.logger.error("Failed to decode message: \(message)")
                // TODO: Send error event to client
            }
        }
        
        ws.onClose.whenComplete { result in
            switch result {
            case .success:
                let controller = SocketEventController(
                    webSocket: ws,
                    socketStore: socketStore,
                    gameStore: gameStore,
                    gameSystem: gameSystem,
                    clientErrorHandler: errorHandler,
                    logger: req.logger
                )
                controller.handlePlayerQuitEvent()
                socketStore.removeClient(ws)
            case .failure(let error):
                req.logger.error("Failed to close socket: \(error.localizedDescription)")
            }
            req.logger.info("Client closed socket \(ws)")
        }
    }
    
    private func handleConnection(_ ws: WebSocket, logger: Logger) {
        if !socketStore.clients.contains(ws) {
            let clientID = UUID()
            socketStore.addClient(ws, clientID: clientID)
            let eventName = OutboundEventName.connect
            let connect = WebSocketEvent(clientID: clientID, eventName: eventName.rawValue)
            do {
                let message = try gameSystem.encodeToString(connect)
                ws.send(message)
                logger.info("Message sent: \(message)")
            }
            catch {
                logger.error("Failed to encode \(eventName.rawValue) event message")
            }
        }
    }
}
