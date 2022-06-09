//
//  GameSystem.swift
//  
//
//  Created by Robert Walker on 1/23/21.
//

import Foundation
import PlanningGame

// MARK: - Type Aliases

typealias GameUUID = UUID
typealias ClientUUID = UUID

typealias WebSocketMessage = WebSocketIdentifiable & Codable
typealias WebSocketGameEvent = GameIdentifiable & Codable
typealias WebSocketErrorEvent = Codable

// MARK: - Protocols

protocol WebSocketIdentifiable {
    var clientID: UUID { get set }
    var eventName: String { get set }
}

protocol GameIdentifiable {
    var gameID: UUID { get set }
}

protocol GameTokenSearchable {
    var gameToken: String { get set }
}

// MARK: - Enumerations

enum InboundEventName: String {
    case findGame = "FindGame"
    case startGame = "StartGame"
    case startRound = "StartRound"
    case playACard = "PlayACard"
    case replayRound = "ReplayRound"
    case scoreRound = "ScoreRound"
    case endGame = "EndGame"
}

enum OutboundEventName: String {
    case connect = "Connect"
    case gameStarted = "GameStarted"
    case gameFound = "GameFound"
    case playerJoined = "PlayerJoined"
    case playerQuit = "PlayerQuit"
    case roundStarted = "RoundStarted"
    case playerPlayedACard = "PlayerPlayedACard"
    case roundScored = "RoundScored"
    case gameEnded = "GameEnded"
    case socketError = "SocketError"
    case gameError = "GameError"
}

// MARK: - Game Events

struct WebSocketEvent: WebSocketMessage {
    var clientID: UUID
    var eventName: String
    var event: String = ""
}

struct GameStartedEvent: WebSocketGameEvent {
    var gameID: UUID
    var gameToken: String
    var gameMasterName: String
}

struct GameFoundEvent: WebSocketGameEvent {
    var gameID: UUID
    var playerName: String
    var gameMasterName: String
    var playerNames: [String]
    var lobbyPlayerNames: [String]
    var hand: [String]
    var playerCards: [String]
}

struct PlayerJoinedEvent: WebSocketGameEvent {
    var gameID: UUID
    var playerName: String
    var isInLobby: Bool = false
}

struct PlayerQuitEvent: WebSocketGameEvent {
    var gameID: UUID
    var playerName: String
}

struct RoundStartedEvent: WebSocketGameEvent {
    var gameID: UUID
    var storyName: String
    var playerNames: [String]
    var lobbyPlayerNames: [String]
    var hand: [String]
}

struct PlayerPlayedACardEvent: WebSocketGameEvent {
    var gameID: UUID
    var playerName: String
    var hand: [String]
    var playerCards: [String]
}

struct RoundScoredEvent: WebSocketGameEvent {
    var gameID: UUID
    var faceValue: String
}

struct GameEndedEvent: WebSocketGameEvent {
    var gameID: UUID
    var scoreboard: [String]
}

// MARK: - Error Events

struct SocketErrorEvent: WebSocketErrorEvent {
    var failedEventName: String
    var errorMessage: String
}

struct GameErrorEvent: WebSocketGameEvent {
    var gameID: UUID
    var failedEventName: String
    var errorMessage: String
}

// MARK: - Game Queries

struct FindGameQuery: GameTokenSearchable, Codable {
    var playerName: String
    var gameToken: String
}

// MARK: - Game Commands

struct StartGameCommand: Codable {
    var gameMasterName: String
    var pointScale: String
}

struct StartRoundCommand: WebSocketGameEvent {
    var gameID: UUID
    var storyName: String
}

struct PlayACardCommand: WebSocketGameEvent {
    var gameID: UUID
    var playerName: String
    var faceValue: String
}

struct ReplayRoundCommand: WebSocketGameEvent {
    var gameID: UUID
    var storyName: String
}

struct ScoreRoundCommand: WebSocketGameEvent {
    var gameID: UUID
    var faceValue: String
}

struct EndGameCommand: WebSocketGameEvent {
    var gameID: UUID
}

// MARK: - Game System

struct GameSystem {
    let encoder = JSONEncoder()
    let decoder =  JSONDecoder()
    
    enum MessageError: Error {
        case encodingFailed
        case invalidJSONString
        case tokenGenerationFailed
    }
    
    func encodeToString<T>(_ value: T) throws -> String where T: Encodable {
        guard let data = try? encoder.encode(value) else {
            throw MessageError.encodingFailed
        }
        guard let json = String(data: data, encoding: .utf8) else {
            throw MessageError.encodingFailed
        }
        return json
    }
    
    func decodeFromString<T>(_ type: T.Type, from: String) throws -> T where T: Decodable {
        do {
            let data = Data(from.utf8)
            return try decoder.decode(type, from: data)
        } catch {
            throw MessageError.invalidJSONString
        }
    }
    
    func generateToken(activeTokens: [String]) throws -> String {
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var gameToken = ""
        var retries = 10
        
        repeat {
            var token = ""
            for _ in 0..<6 {
                token += String(alphabet.randomElement()!)
            }
            gameToken = token
            retries -= 1
            print("Game Token: \(gameToken)")
        } while (activeTokens.contains(gameToken) && retries > 0)
        
        guard retries > 0 else {
            throw MessageError.tokenGenerationFailed
        }
        
        return gameToken
    }
    
    func playingCardFlippedFaceDown(_ card: PlayingCard) -> PlayingCard {
        var cardCopy = card
        cardCopy.isFaceDown = true
        return cardCopy
    }
    
    func playingCardFlippedFaceUp(_ card: PlayingCard) -> PlayingCard {
        var cardCopy = card
        cardCopy.isFaceDown = false
        return cardCopy
    }
    
    func playerCardFlippedFaceUp(_ card: PlayerCard) -> PlayerCard {
        let playingCard = playingCardFlippedFaceUp(card.playingCard)
        return PlayerCard(player: card.player, playingCard: playingCard)
    }
}
