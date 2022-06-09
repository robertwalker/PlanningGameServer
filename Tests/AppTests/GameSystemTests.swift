@testable import App
import XCTVapor
import PlanningGame

final class GameSystemTests: XCTestCase {
    let gameSystem = GameSystem()
    
    // MARK: - Game Events
    
    func testEncodingAConnectEvent() throws {
        // Given
        let eventName = OutboundEventName.connect
        let connect = WebSocketEvent(clientID: UUID(), eventName: eventName.rawValue)
        
        // When
        let json = try gameSystem.encodeToString(connect)
        
        // Then
        XCTAssertTrue(json.contains("clientID"))
        XCTAssertEqual(connect.eventName, eventName.rawValue)
    }
    
    func testDecodingAConnectEvent() throws {
        // Given
        let eventName = OutboundEventName.connect
        let json = loadFixture(.connectEvent)
        
        // When
        let message = try gameSystem.decodeFromString(WebSocketEvent.self, from: json)
        
        // Then
        XCTAssertEqual(message.clientID, UUID(uuidString: "1ACFD06E-594C-4C48-A912-640CAD34F24A"))
        XCTAssertEqual(message.eventName, eventName.rawValue)
    }
    
    func testEncodeGameStartedEvent() throws {
        // Given
        let eventName = OutboundEventName.gameStarted
        let gameMasterName = "Game Master"
        let gameStarted = GameStartedEvent(gameID: UUID(), gameToken: "1234", gameMasterName: gameMasterName)
        let payload = try gameSystem.encodeToString(gameStarted)
        let event = WebSocketEvent(clientID: UUID(), eventName: eventName.rawValue, event: payload)
        
        // When
        let json = try gameSystem.encodeToString(event)
        
        // Then
        XCTAssertTrue(json.contains("clientID"))
        XCTAssertTrue(json.contains("gameID"))
    }
    
    func testEncodeGameFoundEvent() throws {
        // Given
        let eventName = OutboundEventName.gameFound
        let gameFound = GameFoundEvent(
            gameID: UUID(),
            playerName: "Player Two",
            gameMasterName: "Game Master",
            playerNames: ["Player One"],
            lobbyPlayerNames: ["Player Three"],
            hand: ["one", "two", "three", "skip", "question"],
            playerCards: ["PlayerOne,one,false", "Player Two,two,true"]
        )
        let payload = try gameSystem.encodeToString(gameFound)
        let event = WebSocketEvent(clientID: UUID(), eventName: eventName.rawValue, event: payload)
        
        // When
        let json = try gameSystem.encodeToString(event)
        
        // Then
        XCTAssertTrue(json.contains("clientID"))
        XCTAssertTrue(json.contains("gameID"))
    }
    
    func testEncodePlayerJoinedEvent() throws {
        // Given
        let eventName = OutboundEventName.playerJoined
        let playerJoined = PlayerJoinedEvent(gameID: UUID(), playerName: "Player One", isInLobby: true)
        let payload = try gameSystem.encodeToString(playerJoined)
        let event = WebSocketEvent(clientID: UUID(), eventName: eventName.rawValue, event: payload)
        
        // When
        let json = try gameSystem.encodeToString(event)
        
        // Then
        XCTAssertTrue(json.contains("clientID"))
        XCTAssertTrue(json.contains("gameID"))
        XCTAssertTrue(json.contains("playerName"))
        XCTAssertTrue(json.contains("isInLobby"))
    }
    
    func testEncodePlayerQuitEvent() throws {
        // Given
        let eventName = OutboundEventName.playerQuit
        let playerQuit = PlayerQuitEvent(gameID: UUID(), playerName: "Player One")
        let payload = try gameSystem.encodeToString(playerQuit)
        let event = WebSocketEvent(clientID: UUID(), eventName: eventName.rawValue, event: payload)
        
        // When
        let json = try gameSystem.encodeToString(event)
        
        // Then
        XCTAssertTrue(json.contains("clientID"))
        XCTAssertTrue(json.contains("gameID"))
        XCTAssertTrue(json.contains("playerName"))
    }
    
    func testEncodeRoundStartedEvent() throws {
        // Given
        let eventName = OutboundEventName.roundStarted
        let hand = ["one", "two", "three", "question", "skip"]
        let roundStarted = RoundStartedEvent(
            gameID: UUID(),
            storyName: "Story One",
            playerNames: ["Player One", "Player Two"],
            lobbyPlayerNames: ["Player Three"],
            hand: hand
        )
        let payload = try gameSystem.encodeToString(roundStarted)
        let event = WebSocketEvent(clientID: UUID(), eventName: eventName.rawValue, event: payload)
        
        // When
        let json = try gameSystem.encodeToString(event)
        
        // Then
        XCTAssertTrue(json.contains("clientID"))
        XCTAssertTrue(json.contains("gameID"))
        XCTAssertTrue(json.contains("storyName"))
        XCTAssertTrue(json.contains("hand"))
    }
    
    func testEncodePlayerPlayedACardEvent() throws {
        // Given
        let eventName = OutboundEventName.playerPlayedACard
        let hand = ["one", "two", "three", "question", "skip"]
        let playerCards = ["PlayerOne,one,false", "Player Two,two,true"]
        let playerPlayedACard = PlayerPlayedACardEvent(
            gameID: UUID(), playerName: "Player One", hand: hand, playerCards: playerCards)
        let payload = try gameSystem.encodeToString(playerPlayedACard)
        let event = WebSocketEvent(clientID: UUID(), eventName: eventName.rawValue, event: payload)
        
        // When
        let json = try gameSystem.encodeToString(event)
        
        // Then
        XCTAssertTrue(json.contains("clientID"))
        XCTAssertTrue(json.contains("gameID"))
        XCTAssertTrue(json.contains("playerName"))
        XCTAssertTrue(json.contains("hand"))
        XCTAssertTrue(json.contains("playerCards"))
    }
    
    func testEncodeRoundScoredEvent() throws {
        // Given
        let eventName = OutboundEventName.roundScored
        let faceValue = FaceValue.one
        let roundScored = RoundScoredEvent(gameID: UUID(), faceValue: faceValue.rawValue)
        let payload = try gameSystem.encodeToString(roundScored)
        let event = WebSocketEvent(clientID: UUID(), eventName: eventName.rawValue, event: payload)
        
        // When
        let json = try gameSystem.encodeToString(event)
        
        // Then
        XCTAssertTrue(json.contains("clientID"))
        XCTAssertTrue(json.contains("gameID"))
        XCTAssertTrue(json.contains("faceValue"))
    }
    
    func testEncodeGameEndedEvent() throws {
        // Given
        let eventName = OutboundEventName.gameEnded
        let scoreboard = ["Story One,1", "Story Two,2"]
        let gameEnded = GameEndedEvent(gameID: UUID(), scoreboard: scoreboard)
        let payload = try gameSystem.encodeToString(gameEnded)
        let event = WebSocketEvent(clientID: UUID(), eventName: eventName.rawValue, event: payload)
        
        // When
        let json = try gameSystem.encodeToString(event)
        
        // Then
        XCTAssertTrue(json.contains("clientID"))
        XCTAssertTrue(json.contains("gameID"))
        XCTAssertTrue(json.contains("scoreboard"))
    }
    
    // MARK: - Error Events
    
    func testEncodingASocketErrorEvent() throws {
        // Given
        let eventName = OutboundEventName.socketError
        let failedEventName = InboundEventName.startGame
        let socketError = SocketErrorEvent(failedEventName: failedEventName.rawValue,errorMessage: "Test Error")
        let payload = try gameSystem.encodeToString(socketError)
        let event = WebSocketEvent(clientID: UUID(), eventName: eventName.rawValue, event: payload)
        
        // When
        let json = try gameSystem.encodeToString(event)
        
        // Then
        XCTAssertTrue(json.contains("clientID"))
        XCTAssertEqual(event.eventName, eventName.rawValue)
    }
    
    func testEncodingAGameErrorEvent() throws {
        // Given
        let eventName = OutboundEventName.gameError
        let failedEventName = InboundEventName.startGame
        let gameError = GameErrorEvent(gameID: UUID(), failedEventName: failedEventName.rawValue,
                                       errorMessage: "Some game error")
        let payload = try gameSystem.encodeToString(gameError)
        let event = WebSocketEvent(clientID: UUID(), eventName: eventName.rawValue, event: payload)
        
        // When
        let json = try gameSystem.encodeToString(event)
        
        // Then
        XCTAssertTrue(json.contains("clientID"))
        XCTAssertTrue(json.contains("gameID"))
    }
    
    // MARK: - Query Events
    
    func testDecodeFindGameQuery() throws {
        // Given
        let eventName = InboundEventName.findGame
        let json = loadFixture(.findGameQuery)
        
        // When
        let message = try gameSystem.decodeFromString(WebSocketEvent.self, from: json)
        let query = try gameSystem.decodeFromString(FindGameQuery.self, from: message.event)
        
        // Then
        XCTAssertEqual(message.clientID, UUID(uuidString: "1ACFD06E-594C-4C48-A912-640CAD34F24A"))
        XCTAssertEqual(message.eventName, eventName.rawValue)
        XCTAssertEqual(query.playerName, "Player One")
        XCTAssertEqual(query.gameToken, "1ACFD06E")
    }
    
    // MARK: - Command Event
    
    func testDecodeStartGameCommand() throws {
        // Given
        let eventName = InboundEventName.startGame
        let pointScale = PointScale.linear
        let json = loadFixture(.startGameCommand)
        
        // When
        let message = try gameSystem.decodeFromString(WebSocketEvent.self, from: json)
        let command = try gameSystem.decodeFromString(StartGameCommand.self, from: message.event)
        
        // Then
        XCTAssertEqual(message.clientID, UUID(uuidString: "1ACFD06E-594C-4C48-A912-640CAD34F24A"))
        XCTAssertEqual(message.eventName, eventName.rawValue)
        XCTAssertEqual(command.gameMasterName, "Game Master")
        XCTAssertEqual(command.pointScale, pointScale.rawValue)
    }
    
    func testDecodeStartRoundCommand() throws {
        // Given
        let eventName = InboundEventName.startRound
        let json = loadFixture(.startRoundCommand)
        
        // When
        let message = try gameSystem.decodeFromString(WebSocketEvent.self, from: json)
        let command = try gameSystem.decodeFromString(StartRoundCommand.self, from: message.event)
        
        // Then
        XCTAssertEqual(message.clientID, UUID(uuidString: "1ACFD06E-594C-4C48-A912-640CAD34F24A"))
        XCTAssertEqual(message.eventName, eventName.rawValue)
        XCTAssertEqual(command.gameID, UUID(uuidString: "3F315C02-B6DD-4B81-8D32-46AF6BF61CDD"))
        XCTAssertEqual(command.storyName, "Test Story")
    }
    
    func testDecodePlayACardCommand() throws {
        // Given
        let eventName = InboundEventName.playACard
        let faceValue = FaceValue.one
        let json = loadFixture(.playACardCommand)
        
        // When
        let message = try gameSystem.decodeFromString(WebSocketEvent.self, from: json)
        let command = try gameSystem.decodeFromString(PlayACardCommand.self, from: message.event)
        
        // Then
        XCTAssertEqual(message.clientID, UUID(uuidString: "1ACFD06E-594C-4C48-A912-640CAD34F24A"))
        XCTAssertEqual(message.eventName, eventName.rawValue)
        XCTAssertEqual(command.gameID, UUID(uuidString: "3F315C02-B6DD-4B81-8D32-46AF6BF61CDD"))
        XCTAssertEqual(command.playerName, "Player One")
        XCTAssertEqual(command.faceValue, faceValue.rawValue)
    }
    
    func testDecodeReplayRoundCommand() throws {
        // Given
        let eventName = InboundEventName.replayRound
        let json = loadFixture(.replayRoundCommand)
        
        // When
        let message = try gameSystem.decodeFromString(WebSocketEvent.self, from: json)
        let command = try gameSystem.decodeFromString(ReplayRoundCommand.self, from: message.event)
        
        // Then
        XCTAssertEqual(message.clientID, UUID(uuidString: "1ACFD06E-594C-4C48-A912-640CAD34F24A"))
        XCTAssertEqual(message.eventName, eventName.rawValue)
        XCTAssertEqual(command.gameID, UUID(uuidString: "3F315C02-B6DD-4B81-8D32-46AF6BF61CDD"))
        XCTAssertEqual(command.storyName, "Test Story")
    }
    
    func testDecodeScoreRoundCommand() throws {
        // Given
        let eventName = InboundEventName.scoreRound
        let faceValue = FaceValue.one
        let json = loadFixture(.scoreRoundCommand)
        
        // When
        let message = try gameSystem.decodeFromString(WebSocketEvent.self, from: json)
        let command = try gameSystem.decodeFromString(ScoreRoundCommand.self, from: message.event)
        
        // Then
        XCTAssertEqual(message.clientID, UUID(uuidString: "1ACFD06E-594C-4C48-A912-640CAD34F24A"))
        XCTAssertEqual(message.eventName, eventName.rawValue)
        XCTAssertEqual(command.gameID, UUID(uuidString: "3F315C02-B6DD-4B81-8D32-46AF6BF61CDD"))
        XCTAssertEqual(command.faceValue, faceValue.rawValue)
    }
    
    func testDecodeEndGameCommand() throws {
        // Given
        let eventName = InboundEventName.endGame
        let json = loadFixture(.endGameCommand)
        
        // When
        let message = try gameSystem.decodeFromString(WebSocketEvent.self, from: json)
        let command = try gameSystem.decodeFromString(EndGameCommand.self, from: message.event)
        
        // Then
        XCTAssertEqual(message.clientID, UUID(uuidString: "1ACFD06E-594C-4C48-A912-640CAD34F24A"))
        XCTAssertEqual(message.eventName, eventName.rawValue)
        XCTAssertEqual(command.gameID, UUID(uuidString: "3F315C02-B6DD-4B81-8D32-46AF6BF61CDD"))
    }
    
    // MARK: - Game System Tests
    
    func testGenerateGameToken() throws {
        // Given
        let activeTokens: [String] = []
        let expectedTokenLength = 6
        
        // When
        let gameToken = try gameSystem.generateToken(activeTokens: activeTokens)
        
        // Then
        XCTAssertEqual(gameToken.count, expectedTokenLength)
    }
    
    func testPlayingCardFlippedFaceDown() {
        // Given: A face up card
        let card = PlayingCard(faceValue: .one)
        
        // When: I flip the card
        let flippedCard = gameSystem.playingCardFlippedFaceDown(card)
        
        // Then: The card should be face down
        XCTAssertTrue(flippedCard.isFaceDown)
    }
    
    func testPlayingCardFlippedFaceUp() {
        // Given: A face down card
        let card = PlayingCard(faceValue: .one, isFaceDown: true)
        
        // When: I flip the card
        let flippedCard = gameSystem.playingCardFlippedFaceUp(card)
        
        // Then: The card should be face up
        XCTAssertFalse(flippedCard.isFaceDown)
    }
    
    func testFlippedPlayerCard() {
        // Given: A face down player card
        let player = Player(name: "Player One")
        let playingCard = PlayingCard(faceValue: .one, isFaceDown: true)
        let card = PlayerCard(player: player, playingCard: playingCard)
        
        // When: I flip the
        let flippedCard = gameSystem.playerCardFlippedFaceUp(card)
        
        // Then: The card should be face up
        XCTAssertFalse(flippedCard.playingCard.isFaceDown)
    }
}
