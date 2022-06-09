@testable import App
import XCTVapor
import PlanningGame

final class GameStoreTests: XCTestCase {
    let validGameID = UUID(uuidString: "1EC4FE96-4B6B-4B2E-92C2-BBF7D27005B8")!
    let validClientID = UUID(uuidString: "8139068A-5AC9-4880-8AD7-029D0AB4E390")!
    let validGameMaster = Player(name: "Game Master")
    
    let gameStore = GameStore()
    
    // MARK: Tests
    
    func testShouldAppendGame() {
        // Given
        let clientID = UUID()
        let gameID = UUID()
        let gameToken = "ABC123"
        let game = makeValidGame()
        
        // When
        gameStore.append(clientID: clientID, gameID: gameID, gameToken: gameToken, game: game)
        
        // Then
        XCTAssertEqual(gameStore.count, 1)
        XCTAssertEqual(gameStore.activeTokens, [gameToken])
    }
    
    func testShouldRemoveGame() {
        // Setup
        appendTwoGames()
        
        // Given
        let gameID1 = validGameID
        let previousCount = gameStore.count
        let previousTokensCount = gameStore.activeTokens.count
        
        // When
        gameStore.remove(gameID: gameID1)
        
        // Then
        XCTAssertEqual(gameStore.count, previousCount - 1)
        XCTAssertEqual(gameStore.activeTokens.count, previousTokensCount - 1)
    }
    
    func testShouldFindGameByGameID() throws {
        // Setup
        try appendValidGame()
        
        // Given
        let gameID = validGameID
        
        // When
        let game = try gameStore.findByGameID(gameID: gameID)
        
        // Then
        XCTAssertEqual(game.gameMaster, validGameMaster)
    }
    
    func testShouldFindGameUsingGameToken() throws {
        // Setup
        try appendValidGame()
        
        // Given
        let gameToken = "ABC123"
        
        // When
        let (gameID, game) = try gameStore.findByGameToken(token: gameToken)
        
        // Then
        XCTAssertEqual(gameID, validGameID)
        XCTAssertEqual(game.gameMaster, validGameMaster)
    }
    
    func testShouldFindGameUsingClientID() throws {
        // Setup
        try appendValidGame()

        // Given
        let gameID = validGameID
        let clientID = validClientID
        let player = Player(name: "Player Three")
        try gameStore.appendGamePlayer(gameID: gameID, clientID: clientID, player: player)

        // When
        let (actualGameID, actualGame) = try gameStore.findByClientID(clientID: clientID)
        
        // Then
        let actualPlayer = try gameStore.findGamePlayer(gameID: actualGameID, clientID: clientID)
        XCTAssertEqual(actualGameID, validGameID)
        XCTAssertEqual(actualGame.gameMaster, validGameMaster)
        XCTAssertTrue(actualGame.players.contains(actualPlayer))
    }
    
    func testShouldAppendGamePlayer() throws {
        // Setup
        try appendValidGame()
        
        // Given
        let gameID = validGameID
        let clientID = validClientID
        let player = Player(name: "Player Three")
        
        // When
        try gameStore.appendGamePlayer(gameID: gameID, clientID: clientID, player: player)
        
        // Then
        let actualClientID = try gameStore.findPlayerClientID(gameID: gameID, player: player)
        XCTAssertEqual(clientID, actualClientID)
    }
    
    func testShouldFindGamePlayer() throws {
        // Setup
        let gameID = validGameID
        let clientID = validClientID
        let expectedPlayer = Player(name: "Player Three")
        try appendValidGame()
        try gameStore.appendGamePlayer(gameID: gameID, clientID: clientID, player: expectedPlayer)

        // Given
        let actualPlayer = try gameStore.findGamePlayer(gameID: gameID, clientID: clientID)
        
        // Then
        XCTAssertEqual(expectedPlayer.name, actualPlayer.name)
    }
    
    func testShouldFindAllPlayers() throws {
        // Setup
        try appendValidGame()
        
        // Given
        let clientID = validClientID
        let gameID = validGameID
        let player = Player(name: "Player Three")
        
        // When: Appending a current player and getting all players
        try gameStore.appendGamePlayer(gameID: gameID, clientID: clientID, player: player)
        let allPlayers = try gameStore.findAllPlayers(gameID: gameID)
        
        // Then: The player array should contain all players including the current player
        let filteredPlayers = allPlayers.filter { (actualClientID, _) in
            actualClientID == clientID
        }
        XCTAssertEqual(allPlayers.count, 4)
        XCTAssertEqual(filteredPlayers.count, 1)
    }
    
    func testShouldFindOtherPlayers() throws {
        // Setup
        try appendValidGame()
        
        // Given
        let clientID = validClientID
        let gameID = validGameID
        let player = Player(name: "Player Three")
        
        // When
        try gameStore.appendGamePlayer(gameID: gameID, clientID: clientID, player: player)
        let otherPlayers = try gameStore.findOtherPlayers(gameID: gameID, player: player)
        
        // Then
        XCTAssertEqual(otherPlayers.count, 3)
    }
    
    func testShouldRemoveGamePlayer() throws {
        // Setup
        let gameID = validGameID
        let clientID = validClientID
        let player = Player(name: "Player Three")
        try appendValidGame()
        
        // Given: A player has joined a game in progress
        try gameStore.appendGamePlayer(gameID: gameID, clientID: clientID, player: player)
        
        // When
        try gameStore.removeGamePlayer(gameID: gameID, clientID: clientID)
        
        // Then
        let game = try gameStore.findByGameID(gameID: gameID)
        let playerClientID = try? gameStore.findPlayerClientID(gameID: gameID, player: player)
        XCTAssertFalse(game.players.contains(player))
        XCTAssertEqual(playerClientID, nil)
    }
    
    func testShouldUpdateGameWhenStartingAGameRound() throws {
        // Setup
        try appendValidGame()
        
        // Given
        let gameID = validGameID
        var game = try gameStore.findByGameID(gameID: gameID)
        let round = Round(storyName: "Story One")
        
        // When
        try game.startRound(round: round)
        try gameStore.updateGame(gameID: gameID, game: game)
        
        // Then
        let updatedGame = try gameStore.findByGameID(gameID: gameID)
        let gameMasterClientID = try gameStore.findPlayerClientID(gameID: validGameID, player: updatedGame.gameMaster)
        let gameMaster = try gameStore.findGamePlayer(gameID: validGameID, clientID: gameMasterClientID)
        XCTAssertEqual(updatedGame.lastRound?.storyName, round.storyName)
        XCTAssertEqual(updatedGame.gameMaster.hand, gameMaster.hand)
    }
    
    // MARK: Private Helper Methods
    
    private func makeValidGame() -> Game {
        return Game(gameMaster: validGameMaster, pointScale: .linear)
    }
    
    private func makeTwoValidGameTokens() -> [String] {
        return ["ABC123", "XYZ789"]
    }
    
    private func makeTwoValidGameMasters() -> [Player] {
        return [
            Player(name: "Game Master One"),
            Player(name: "Game Master Two")
        ]
    }
    
    private func makeTwoValidPlayers() -> [Player] {
        return [
            Player(name: "Player One"),
            Player(name: "Player Two")
        ]
    }
    
    private func appendGame(clientID: UUID, gameID: UUID, gameToken: String, game: Game) {
        gameStore.append(clientID: clientID, gameID: gameID, gameToken: gameToken, game: game)
    }
    
    private func appendGamePlayers(gameID: UUID, gameMaster: Player) throws {
        for player in makeTwoValidPlayers() {
            try gameStore.appendGamePlayer(gameID: gameID, clientID: UUID(), player: player)
        }
    }
    
    private func appendValidGame() throws {
        let clientID = UUID()
        let gameID = validGameID
        let gameToken = "ABC123"
        let game = makeValidGame()
        appendGame(clientID: clientID, gameID: gameID, gameToken: gameToken, game: game)
        try appendGamePlayers(gameID: gameID, gameMaster: game.gameMaster)
    }
    
    private func appendTwoGames() {
        let clientID1 = validClientID
        let clientID2 = UUID(uuidString: "3F3EBE50-A22B-40EE-9259-5D55167BF655")!
        let gameID1 = validGameID
        let gameID2 = UUID(uuidString: "7FF39DF4-41E3-4669-9DEC-18C5731FD9F6")!
        let gameTokens = makeTwoValidGameTokens()
        let gameMasters = makeTwoValidGameMasters()
        let game1 = Game(gameMaster: gameMasters[0], pointScale: .linear)
        let game2 = Game(gameMaster: gameMasters[1], pointScale: .powersOfTwo)
        appendGame(clientID: clientID1, gameID: gameID1, gameToken: gameTokens[0], game: game1)
        appendGame(clientID: clientID2, gameID: gameID2, gameToken: gameTokens[1], game: game2)
    }
}
