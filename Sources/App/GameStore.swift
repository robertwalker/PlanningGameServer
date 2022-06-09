//
//  GameStore.swift
//  
//
//  Created by Robert Walker on 5/12/22.
//

import Foundation
import PlanningGame

enum GameStoreError: Error {
    case gameNotFound
    case playerNotFound
    case playerClientIDNotFound
    case playerInfoNotFound
}

struct PlayerInfo {
    let clientID: ClientUUID
    let player: Player
}

class GameStore {
    private var games: [GameUUID:Game] = [:]
    private var gameTokens: [String:GameUUID] = [:]
    private var gamePlayerInfo: [GameUUID:[PlayerInfo]] = [:]
    private var clientIDToGame: [ClientUUID:GameUUID] = [:]
    var count: Int {
        return games.count
    }
    var activeTokens: [String] {
        [String](gameTokens.keys)
    }
    
    func append(clientID: ClientUUID, gameID: GameUUID, gameToken: String, game: Game) {
        games[gameID] = game
        gameTokens[gameToken] = gameID
        gamePlayerInfo[gameID] = [PlayerInfo(clientID: clientID, player: game.gameMaster)]
        clientIDToGame[clientID] = gameID
    }
    
    func remove(gameID: GameUUID) {
        games[gameID] = nil
        removeToken(gameID: gameID)
        gamePlayerInfo[gameID] = nil
        removeClientIDMapping(gameID: gameID)
    }
    
    func findByGameID(gameID: GameUUID) throws -> Game {
        guard let game = games[gameID] else {
            throw GameStoreError.gameNotFound
        }
        return game
    }
    
    func findByGameToken(token: String) throws -> (GameUUID, Game) {
        guard let gameID = gameTokens[token] else {
            throw GameStoreError.gameNotFound
        }
        guard let game = games[gameID] else {
            throw GameStoreError.gameNotFound
        }
        return (gameID, game)
    }
    
    func findByClientID(clientID: ClientUUID) throws -> (GameUUID, Game) {
        guard let gameID = clientIDToGame[clientID] else {
            throw GameStoreError.gameNotFound
        }
        let game = try findByGameID(gameID: gameID)
        return (gameID, game)
    }
    
    func appendGamePlayer(gameID: GameUUID, clientID: ClientUUID, player: Player) throws {
        guard var game = games[gameID] else {
            throw GameStoreError.gameNotFound
        }
        
        try game.addPlayer(player)
        games[gameID] = game
        
        clientIDToGame[clientID] = gameID

        let playerInfo = PlayerInfo(clientID: clientID, player: player)
        
        if var playerInfoArray = gamePlayerInfo[gameID] {
            playerInfoArray.append(playerInfo)
            gamePlayerInfo[gameID] = playerInfoArray
        }
        else {
            gamePlayerInfo[gameID] = [playerInfo]
        }
    }
    
    func findGamePlayer(gameID: GameUUID, clientID: ClientUUID) throws -> Player {
        guard let playerInfoArray = gamePlayerInfo[gameID] else {
            throw GameStoreError.gameNotFound
        }
        let filtered = playerInfoArray.filter { $0.clientID == clientID }
        guard let playerInfo = filtered.first else {
            throw GameStoreError.playerNotFound
        }
        return playerInfo.player
    }
    
    func findPlayerClientID(gameID: GameUUID, player: Player) throws -> ClientUUID {
        guard let playerInfoArray = gamePlayerInfo[gameID] else {
            throw GameStoreError.gameNotFound
        }
        let filteredPlayerInfo = playerInfoArray.filter { $0.player.name == player.name }
        guard let playerInfo = filteredPlayerInfo.first else {
            throw GameStoreError.playerClientIDNotFound
        }
        return playerInfo.clientID
    }
    
    func findAllPlayers(gameID: GameUUID) throws -> [(ClientUUID, Player)] {
        guard let playerInfoArray = gamePlayerInfo[gameID] else {
            throw GameStoreError.gameNotFound
        }
        return playerInfoArray.map { ($0.clientID, $0.player) }
    }
    
    func findOtherPlayers(gameID: GameUUID, player: Player) throws -> [(ClientUUID, Player)] {
        guard let playerInfoArray = gamePlayerInfo[gameID] else {
            throw GameStoreError.gameNotFound
        }
        let otherPlayerInfo = playerInfoArray.filter { $0.player.name != player.name }
        return otherPlayerInfo.map { ($0.clientID, $0.player) }
    }
    
    func removeGamePlayer(gameID: GameUUID, clientID: ClientUUID) throws {
        guard var game = games[gameID] else {
            throw GameStoreError.gameNotFound
        }
        guard let playerInfoArray = gamePlayerInfo[gameID] else {
            throw GameStoreError.playerClientIDNotFound
        }
        let maybePlayer = try? findGamePlayer(gameID: gameID, clientID: clientID)
        guard let player = maybePlayer else {
            throw GameStoreError.playerNotFound
        }
        
        game.removePlayer(player)
        games[gameID] = game
        
        gamePlayerInfo[gameID] = playerInfoArray.filter { $0.clientID != clientID }
    }
    
    func updateGame(gameID: GameUUID, game: Game) throws {
        try updateGamePlayerInfo(gameID: gameID, game: game)
        games[gameID] = game
    }
    
    // MARK: Private Methods
    
    private func updateGamePlayerInfo(gameID: GameUUID, game: Game) throws {
        guard let playerInfoArray = gamePlayerInfo[gameID] else {
            throw GameStoreError.playerInfoNotFound
        }
        
        gamePlayerInfo[gameID] = try playerInfoArray.map({ info in
            if info.player == game.gameMaster {
                return PlayerInfo(clientID: info.clientID, player: game.gameMaster)
            }
            
            let allPlayers = game.players + game.lobby
            guard let player = allPlayers.first(where: { $0 == info.player }) else {
                throw GameStoreError.playerNotFound
            }
            return PlayerInfo(clientID: info.clientID, player: player)
        })
    }

    private func removeToken(gameID: GameUUID) {
        gameTokens = gameTokens.filter({ (_, value) in
            value != gameID
        })
    }
    
    private func removeClientIDMapping(gameID: GameUUID) {
        clientIDToGame = clientIDToGame.filter({ (_, value) in
            value != gameID
        })
    }
}
