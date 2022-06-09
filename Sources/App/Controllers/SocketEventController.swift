//
//  SocketEventController.swift
//  
//
//  Created by Robert Walker on 3/25/21.
//

import Vapor
import PlanningGame

struct SocketEventController {
    let ws: WebSocket
    let socketStore: SocketStore
    let gameStore: GameStore
    let gameSystem: GameSystem
    let errorHandler: ClientErrorHandler
    let logger: Logger
    
    init(webSocket: WebSocket,
         socketStore: SocketStore,
         gameStore: GameStore,
         gameSystem: GameSystem,
         clientErrorHandler: ClientErrorHandler,
         logger: Logger)
    {
        self.ws = webSocket
        self.socketStore = socketStore
        self.gameStore = gameStore
        self.gameSystem = gameSystem
        self.errorHandler = clientErrorHandler
        self.logger = logger
    }
    
    mutating func handleEvent(socketEvent: WebSocketEvent) {
        guard let eventName = InboundEventName(rawValue: socketEvent.eventName) else {
            errorHandler.sendSocketErrorEvent(
                clientID: socketEvent.clientID, eventName: socketEvent.eventName, message: "Event has no route")
            return
        }
        
        switch eventName {
        case .startGame:
            startGame(socketEvent: socketEvent)
        case .findGame:
            findGame(socketEvent: socketEvent)
        case .startRound:
            startRound(socketEvent: socketEvent)
        case .playACard:
            playACard(socketEvent: socketEvent)
        case .replayRound:
            replayRound(socketEvent: socketEvent)
        case .scoreRound:
            scoreRound(socketEvent: socketEvent)
        case .endGame:
            endGame(socketEvent: socketEvent)
        }
    }
    
    func handlePlayerQuitEvent() {
        do {
            let clientID = try socketStore.findClientID(ws)
            let (gameID, game) = try gameStore.findByClientID(clientID: clientID)
            let player = try gameStore.findGamePlayer(gameID: gameID, clientID: clientID)
            guard player != game.gameMaster else {
                let scoreboard = game.rounds.map { "\($0.storyName),\($0.scoreCard.faceValue.pointValue)" }
                broadcastGameEndedEvents(clientID: clientID, gameID: gameID, scoreboard: scoreboard)
                gameStore.remove(gameID: gameID)
                logger.info("Game master quit the game before ending the game")
                return
            }
            broadcastPlayerQuitGameEvents(clientID: clientID, gameID: gameID, player: player)
        }
        catch {
            logger.error("An unexpected error occurred handling player quit event: \(error)")
        }
    }
    
    // MARK: - Handle Inbound Events
    
    private mutating func startGame(socketEvent: WebSocketEvent) {
        let maybeCommand = try? gameSystem.decodeFromString(StartGameCommand.self, from: socketEvent.event)
        let maybeGameToken = try? gameSystem.generateToken(activeTokens: gameStore.activeTokens)
        
        guard let command = maybeCommand, let gameToken = maybeGameToken else {
            errorHandler.sendSocketErrorEvent(
                clientID: socketEvent.clientID, eventName: socketEvent.eventName,
                message: "An unexpected error occurred attempting to start a new game")
            return
        }
        
        let gameMasterName = Validator.trimmedAndSanitized(command.gameMasterName)
        guard Validator.isNotBlank(gameMasterName) else {
            errorHandler.sendSocketErrorEvent(
                clientID: socketEvent.clientID, eventName: socketEvent.eventName,
                message: "Game master name is required")
            return
        }
        
        guard let pointScale = PointScale(rawValue: command.pointScale) else {
            errorHandler.sendSocketErrorEvent(
                clientID: socketEvent.clientID, eventName: socketEvent.eventName,
                message: "Point scale is required")
            return
        }
        
        let gameID = UUID()
        let gameMaster = Player(name: gameMasterName)
        let game = Game(gameMaster: gameMaster, pointScale: pointScale)
        gameStore.append(clientID: socketEvent.clientID, gameID: gameID, gameToken: gameToken, game: game)
        sendGameStartedEvent(
            clientID: socketEvent.clientID, gameID: gameID, gameToken: gameToken, gameMasterName: gameMasterName)
        logger.info("Starting game with ID: \(gameID)")
        logger.info("There are \(gameStore.count) active games")
    }
    
    private func findGame(socketEvent: WebSocketEvent) {
        let maybeQuery = try? gameSystem.decodeFromString(FindGameQuery.self, from: socketEvent.event)
        guard let query = maybeQuery else {
            errorHandler.sendSocketErrorEvent(
                clientID: socketEvent.clientID, eventName: socketEvent.eventName,
                message: "An unexpected error occurred while finding the game")
            return
        }
        
        let playerName = Validator.trimmedAndSanitized(query.playerName)
        let gameToken = Validator.trimmedAndSanitized(query.gameToken)
        guard Validator.isNotBlank(playerName) else {
            errorHandler.sendSocketErrorEvent(
                clientID: socketEvent.clientID, eventName: socketEvent.eventName,
                message: "Player name is required")
            return
        }
        
        do {
            let (gameID, _) = try gameStore.findByGameToken(token: gameToken)
            let player = Player(name: playerName)
            try gameStore.appendGamePlayer(gameID: gameID, clientID: socketEvent.clientID, player: player)
            sendGameFoundEvent(clientID: socketEvent.clientID, gameID: gameID, player: player)
            broadcastPlayerJoinedEvents(clientID: socketEvent.clientID, gameID: gameID)
        }
        catch GameStoreError.gameNotFound {
            errorHandler.sendSocketErrorEvent(
                clientID: socketEvent.clientID, eventName: socketEvent.eventName,
                message: "No game found for game token: \(gameToken)")
        }
        catch {
            errorHandler.sendSocketErrorEvent(
                clientID: socketEvent.clientID, eventName: socketEvent.eventName,
                message: "An unexpected error occurred while joining a game with the game token: \(gameToken)")
            logger.error("\(error)")
        }
    }
    
    private func startRound(socketEvent: WebSocketEvent) {
        let maybeCommand = try? gameSystem.decodeFromString(StartRoundCommand.self, from: socketEvent.event)
        guard let command = maybeCommand else {
            errorHandler.sendSocketErrorEvent(
                clientID: socketEvent.clientID, eventName: socketEvent.eventName,
                message: "An unexpected error ocurred while starting a round")
            return
        }
        
        let gameID = command.gameID
        
        let storyName = Validator.trimmedAndSanitized(command.storyName)
        guard Validator.isNotBlank(storyName) else {
            errorHandler.sendGameErrorEvent(
                clientID: socketEvent.clientID, gameID: gameID, eventName: socketEvent.eventName,
                message: "Story name is required")
            return
        }
        
        do {
            var game = try gameStore.findByGameID(gameID: gameID)
            let round = Round(storyName: storyName)
            try game.startRound(round: round)
            try gameStore.updateGame(gameID: gameID, game: game)
            broadcastRoundStartedEvents(
                clientID: socketEvent.clientID, gameID: gameID, storyName: storyName)
        }
        catch GameStoreError.gameNotFound {
            errorHandler.sendGameErrorEvent(
                clientID: socketEvent.clientID, gameID: gameID, eventName: socketEvent.eventName,
                message: "An unexpected error occurred while finding the game")
        }
        catch GameError.roundMustHaveUniqueStoryName {
            errorHandler.sendGameErrorEvent(
                clientID: socketEvent.clientID, gameID: gameID, eventName: socketEvent.eventName,
                message: "Game round names must be unique")
        }
        catch GameError.roundCannotBeStartedWithZeroPlayers {
            errorHandler.sendGameErrorEvent(
                clientID: socketEvent.clientID, gameID: gameID, eventName: socketEvent.eventName,
                message: "Cannot start a round until at least one player joins the game")
        }
        catch GameError.roundMustBeScoredBeforeStartingNextRound {
            errorHandler.sendSocketErrorEvent(
                clientID: socketEvent.clientID, eventName: socketEvent.eventName,
                message: "Current round must be scored before starting a new round")
        }
        catch {
            errorHandler.sendGameErrorEvent(
                clientID: socketEvent.clientID, gameID: gameID, eventName: socketEvent.eventName,
                message: "An unexpected error occurred while starting a round")
            logger.error("An unexpected error occurred: \(error)")
        }
    }
    
    private func playACard(socketEvent: WebSocketEvent) {
        let maybeCommand = try? gameSystem.decodeFromString(PlayACardCommand.self, from: socketEvent.event)
        guard let command = maybeCommand else {
            errorHandler.sendSocketErrorEvent(
                clientID: socketEvent.clientID, eventName: socketEvent.eventName,
                message: "An unexpected error ocurred while playing a card")
            return
        }
        guard let faceValue = FaceValue(rawValue: command.faceValue) else {
            errorHandler.sendGameErrorEvent(
                clientID: socketEvent.clientID, gameID: command.gameID,
                eventName: socketEvent.eventName,
                message: "An unexpected playing card was received: \(command.faceValue)")
            return
        }
        
        let gameID = command.gameID
        do {
            var game = try gameStore.findByGameID(gameID: gameID)
            guard let round = game.lastRound else {
                errorHandler.sendGameErrorEvent(
                    clientID: socketEvent.clientID, gameID: gameID, eventName: socketEvent.eventName,
                    message: "There is no active game round")
                return
            }
            guard !round.hasEnded else {
                errorHandler.sendGameErrorEvent(
                    clientID: socketEvent.clientID, gameID: gameID, eventName: socketEvent.eventName,
                    message: "Cannot play cards after game round has ended")
                return
            }
            let player = try gameStore.findGamePlayer(gameID: gameID, clientID: socketEvent.clientID)
            let playingCard = PlayingCard(faceValue: faceValue)
            try game.playACard(player: player, card: playingCard)
            try gameStore.updateGame(gameID: gameID, game: game)
            broadcastPlayerPlayedACardEvents(
                clientID: socketEvent.clientID, gameID: gameID, game: game, player: player)
        }
        catch {
            errorHandler.sendGameErrorEvent(
                clientID: socketEvent.clientID, gameID: gameID, eventName: socketEvent.eventName,
                message: "An unexpected error occurred while playing a card")
            logger.error("An unexpected error occurred: \(error)")
        }
    }
    
    func replayRound(socketEvent: WebSocketEvent) {
        let maybeCommand = try? gameSystem.decodeFromString(ReplayRoundCommand.self, from: socketEvent.event)
        guard let command = maybeCommand else {
            errorHandler.sendSocketErrorEvent(
                clientID: socketEvent.clientID, eventName: socketEvent.eventName,
                message: "An unexpected error ocurred while replaying a round")
            return
        }
        
        let gameID = command.gameID
        let storyName = Validator.trimmedAndSanitized(command.storyName)
        do {
            var game = try gameStore.findByGameID(gameID: gameID)
            try game.replayRound()
            try gameStore.updateGame(gameID: gameID, game: game)
            broadcastRoundStartedEvents(
                clientID: socketEvent.clientID, gameID: gameID, storyName: storyName)
        }
        catch GameError.scoredRoundsCannotBeReplayed {
            errorHandler.sendGameErrorEvent(
                clientID: socketEvent.clientID, gameID: gameID, eventName: socketEvent.eventName,
                message: "Cannot replay rounds that have been scored")
        }
        catch {
            errorHandler.sendGameErrorEvent(
                clientID: socketEvent.clientID, gameID: gameID, eventName: socketEvent.eventName,
                message: "An unexpected error occurred while scoring a round")
            logger.error("An unexpected error occurred: \(error)")
        }
    }
    
    func scoreRound(socketEvent: WebSocketEvent) {
        let maybeCommand = try? gameSystem.decodeFromString(ScoreRoundCommand.self, from: socketEvent.event)
        guard let command = maybeCommand else {
            errorHandler.sendSocketErrorEvent(
                clientID: socketEvent.clientID, eventName: socketEvent.eventName,
                message: "An unexpected error ocurred while scoring a round")
            return
        }
        guard let faceValue = FaceValue(rawValue: command.faceValue) else {
            errorHandler.sendGameErrorEvent(
                clientID: socketEvent.clientID, gameID: command.gameID, eventName: socketEvent.eventName,
                message: "An unexpected playing card was received: \(command.faceValue)")
            return
        }
        
        let gameID = command.gameID
        do {
            var game = try gameStore.findByGameID(gameID: gameID)
            let card = PlayingCard(faceValue: faceValue)
            try game.scoreRound(card: card)
            try gameStore.updateGame(gameID: gameID, game: game)
            broadcastRoundScoredEvents(clientID: socketEvent.clientID, gameID: gameID, card: card)
        }
        catch GameError.lastRoundHasNotEnded {
            errorHandler.sendGameErrorEvent(
                clientID: socketEvent.clientID, gameID: gameID, eventName: socketEvent.eventName,
                message: "Cannot score the round until all players have played a card")
        }
        catch {
            errorHandler.sendGameErrorEvent(
                clientID: socketEvent.clientID, gameID: gameID, eventName: socketEvent.eventName,
                message: "An unexpected error occurred while scoring a round")
            logger.error("An unexpected error occurred: \(error)")
        }
    }
    
    func endGame(socketEvent: WebSocketEvent) {
        let maybeCommand = try? gameSystem.decodeFromString(EndGameCommand.self, from: socketEvent.event)
        guard let command = maybeCommand else {
            errorHandler.sendSocketErrorEvent(
                clientID: socketEvent.clientID, eventName: socketEvent.eventName,
                message: "An unexpected error ocurred while ending the game")
            return
        }
        
        let gameID = command.gameID
        do {
            let game = try gameStore.findByGameID(gameID: gameID)
            let scoreboard = game.rounds.map { "\($0.storyName),\($0.scoreCard.faceValue.pointValue)" }
            broadcastGameEndedEvents(clientID: socketEvent.clientID, gameID: gameID, scoreboard: scoreboard)
            gameStore.remove(gameID: gameID)
        }
        catch {
            errorHandler.sendGameErrorEvent(
                clientID: socketEvent.clientID, gameID: gameID, eventName: socketEvent.eventName,
                message: "An unexpected error occurred while ending the game")
            logger.error("An unexpected error occurred: \(error)")
        }
    }
    
    // MARK: - Send Outbound Events
    
    private func sendSocketEvent(
        client: WebSocket,
        clientID: ClientUUID,
        eventName: OutboundEventName,
        event: String
    ) throws {
        let socketEvent = WebSocketEvent(clientID: clientID, eventName: eventName.rawValue, event: event)
        let message = try gameSystem.encodeToString(socketEvent)
        client.send(message)
        logger.info("Message sent: \(message)")
    }
    
    private func sendGameStartedEvent(
        clientID: ClientUUID, gameID: GameUUID, gameToken: String, gameMasterName: String
    ) {
        let eventName = OutboundEventName.gameStarted
        let gameStarted = GameStartedEvent(gameID: gameID, gameToken: gameToken, gameMasterName: gameMasterName)
        
        do {
            let event = try gameSystem.encodeToString(gameStarted)
            try sendSocketEvent(client: ws, clientID: clientID, eventName: eventName, event: event)
        }
        catch {
            errorHandler.sendGameErrorEvent(
                clientID: clientID, gameID: gameID, eventName: eventName.rawValue,
                message: "Failed to encode event")
            logger.error("\(error)")
        }
    }
    
    private func sendGameFoundEvent(clientID: ClientUUID, gameID: GameUUID, player: Player) {
        let eventName = OutboundEventName.gameFound
        
        do {
            let game = try gameStore.findByGameID(gameID: gameID)
            let playerNames = game.players.map { $0.name }
            let lobbyPlayerNames = game.lobby.map { $0.name }
            let hand = handFaceValues(hand: player.hand)
            let playedCards = playedCardsFlipped(game: game, player: player)
            let gameFound = GameFoundEvent(
                gameID: gameID,
                playerName: player.name,
                gameMasterName: game.gameMaster.name,
                playerNames: playerNames,
                lobbyPlayerNames: lobbyPlayerNames,
                hand: hand,
                playerCards: playedCards
            )
            let event = try gameSystem.encodeToString(gameFound)
            try sendSocketEvent(client: ws, clientID: clientID, eventName: eventName, event: event)
        }
        catch {
            errorHandler.sendGameErrorEvent(
                clientID: clientID, gameID: gameID, eventName: eventName.rawValue,
                message: "Failed to encode event")
            logger.error("\(error)")
        }
    }
    
    private func sendRoundStartedEventToGameMaster(
        clientID: ClientUUID, gameID: GameUUID, gameMaster: Player, storyName: String
    ) {
        let eventName = OutboundEventName.roundStarted
        
        do {
            let game = try gameStore.findByGameID(gameID: gameID)
            let playerNames = game.players.map { $0.name }
            let lobbyPlayerNames = game.lobby.map { $0.name }
            let hand = handFaceValues(hand: gameMaster.hand)
            let roundStarted = RoundStartedEvent(
                gameID: gameID,
                storyName: storyName,
                playerNames: playerNames,
                lobbyPlayerNames: lobbyPlayerNames,
                hand: hand
            )
            let event = try gameSystem.encodeToString(roundStarted)
            try sendSocketEvent(client: ws, clientID: clientID, eventName: eventName, event: event)
        }
        catch {
            errorHandler.sendGameErrorEvent(
                clientID: clientID, gameID: gameID, eventName: eventName.rawValue,
                message: "Failed to broadcast round started event to game master")
            logger.error("\(error)")
        }
    }
    
    private func broadcastPlayerJoinedEvents(clientID: ClientUUID, gameID: GameUUID) {
        let eventName = OutboundEventName.playerJoined
        
        do {
            let player = try gameStore.findGamePlayer(gameID: gameID, clientID: clientID)
            let game = try gameStore.findByGameID(gameID: gameID)
            let isInLobby = game.lobby.contains(player)
            let playerJoined = PlayerJoinedEvent(gameID: gameID, playerName: player.name, isInLobby: isInLobby)
            let event = try gameSystem.encodeToString(playerJoined)
            let otherPlayers = try gameStore.findOtherPlayers(gameID: gameID, player: player)
            for (otherClientID, _) in otherPlayers {
                let client = try socketStore.findClient(clientID: otherClientID)
                try sendSocketEvent(client: client, clientID: clientID, eventName: eventName, event: event)
            }
        }
        catch {
            errorHandler.sendGameErrorEvent(
                clientID: clientID, gameID: gameID, eventName: eventName.rawValue,
                message: "Failed to broadcast player joined events")
            logger.error("\(error)")
        }
    }
    
    private func broadcastRoundStartedEvents(clientID: ClientUUID, gameID: GameUUID, storyName: String) {
        let eventName = OutboundEventName.roundStarted
        
        
        do {
            let game = try gameStore.findByGameID(gameID: gameID)
            let gameMaster = try gameStore.findGamePlayer(gameID: gameID, clientID: clientID)
            sendRoundStartedEventToGameMaster(
                clientID: clientID, gameID: gameID, gameMaster: gameMaster, storyName: storyName)
            
            let otherPlayers = try gameStore.findOtherPlayers(gameID: gameID, player: gameMaster)
            for (otherClientID, player) in otherPlayers {
                let playerNames = game.players.map { $0.name }
                let lobbyPlayerNames = game.lobby.map { $0.name }
                let hand = handFaceValues(hand: player.hand)
                let roundStarted = RoundStartedEvent(
                    gameID: gameID,
                    storyName: storyName,
                    playerNames: playerNames,
                    lobbyPlayerNames: lobbyPlayerNames,
                    hand: hand
                )
                let event = try gameSystem.encodeToString(roundStarted)
                let client = try socketStore.findClient(clientID: otherClientID)
                try sendSocketEvent(client: client, clientID: clientID, eventName: eventName, event: event)
            }
        }
        catch {
            errorHandler.sendGameErrorEvent(
                clientID: clientID, gameID: gameID, eventName: eventName.rawValue,
                message: "Failed to broadcast round started events")
            logger.error("\(error)")
        }
    }
    
    private func broadcastPlayerPlayedACardEvents(clientID: ClientUUID, gameID: GameUUID, game: Game, player: Player) {
        let eventName = OutboundEventName.playerPlayedACard
        
        do {
            let allPlayers = try gameStore.findAllPlayers(gameID: gameID)
            for (otherClientID, otherPlayer) in allPlayers {
                let hand = handFaceValues(hand: otherPlayer.hand)
                let playedCards = playedCardsFlipped(game: game, player: otherPlayer)
                let playerPlayedACard = PlayerPlayedACardEvent(
                    gameID: gameID, playerName: player.name, hand: hand, playerCards: playedCards)
                let event = try gameSystem.encodeToString(playerPlayedACard)
                let client = try socketStore.findClient(clientID: otherClientID)
                try sendSocketEvent(client: client, clientID: clientID, eventName: eventName, event: event)
            }
        }
        catch {
            errorHandler.sendGameErrorEvent(
                clientID: clientID, gameID: gameID, eventName: eventName.rawValue,
                message: "Failed to broadcast player played a card events")
            logger.error("\(error)")
        }
    }
    
    private func broadcastRoundScoredEvents(clientID: ClientUUID, gameID: GameUUID, card: PlayingCard) {
        let eventName = OutboundEventName.roundScored
        
        do {
            let roundScored = RoundScoredEvent(gameID: gameID, faceValue: card.faceValue.rawValue)
            let event = try gameSystem.encodeToString(roundScored)
            let allPlayers = try gameStore.findAllPlayers(gameID: gameID)
            for (playerClientID, _) in allPlayers {
                let client = try socketStore.findClient(clientID: playerClientID)
                try sendSocketEvent(client: client, clientID: clientID, eventName: eventName, event: event)
            }
        }
        catch {
            errorHandler.sendGameErrorEvent(
                clientID: clientID, gameID: gameID, eventName: eventName.rawValue,
                message: "Failed to broadcast round scored events")
            logger.error("\(error)")
        }
    }
    
    private func broadcastPlayerQuitGameEvents(clientID: ClientUUID, gameID: GameUUID, player: Player) {
        let eventName = OutboundEventName.playerQuit
        
        do {
            let playerQuit = PlayerQuitEvent(gameID: gameID, playerName: player.name)
            let event = try gameSystem.encodeToString(playerQuit)
            
            try gameStore.removeGamePlayer(gameID: gameID, clientID: clientID)
            
            let otherPlayers = try gameStore.findOtherPlayers(gameID: gameID, player: player)
            for (otherClientID, _) in otherPlayers {
                let client = try socketStore.findClient(clientID: otherClientID)
                try sendSocketEvent(client: client, clientID: clientID, eventName: eventName, event: event)
            }
        } catch {
            logger.error("An unexpected error occurred while broadcasting player quit event: \(error)")
        }
    }
    
    private func broadcastGameEndedEvents(clientID: ClientUUID, gameID: GameUUID, scoreboard: [String]) {
        let eventName = OutboundEventName.gameEnded
        
        do {
            let gameEnded = GameEndedEvent(gameID: gameID, scoreboard: scoreboard)
            let event = try gameSystem.encodeToString(gameEnded)
            let allPlayers = try gameStore.findAllPlayers(gameID: gameID)
            for (playerClientID, _) in allPlayers {
                let client = try socketStore.findClient(clientID: playerClientID)
                try sendSocketEvent(client: client, clientID: clientID, eventName: eventName, event: event)
            }
        }
        catch {
            errorHandler.sendGameErrorEvent(
                clientID: clientID, gameID: gameID, eventName: eventName.rawValue,
                message: "Failed to broadcast game ended events")
            logger.error("\(error)")
        }
    }
    
    // MARK: - Private Utility Methods
    
    private func handFaceValues(hand: [PlayingCard]) -> [String] {
        return hand.map { $0.faceValue.rawValue }
    }
    
    private func playedCardsFlipped(game: Game, player: Player) -> [String] {
        guard let round = game.lastRound else {
            return game.playerCards.map { pc -> String in
                let pcf = (pc.player == player) ? gameSystem.playerCardFlippedFaceUp(pc) : pc
                return "\(pcf.player.name),\(pcf.playingCard.faceValue.rawValue),\(pcf.playingCard.isFaceDown)"
            }
        }
        return game.playerCards.map { pc -> String in
            let pcf = (pc.player == player || round.hasEnded) ? gameSystem.playerCardFlippedFaceUp(pc) : pc
            return "\(pcf.player.name),\(pcf.playingCard.faceValue.rawValue),\(pcf.playingCard.isFaceDown)"
        }
    }
}
