//
//  TestSupport.swift
//  
//
//  Created by Robert Walker on 5/12/22.
//

import Foundation

// MARK: - Event JSON Fixtures

fileprivate let connectEvent = #"""
    {
    "clientID": "1ACFD06E-594C-4C48-A912-640CAD34F24A",
    "eventName": "Connect",
    "event": ""
    }
    """#
fileprivate let findGameQuery = #"""
    {
        "clientID": "1ACFD06E-594C-4C48-A912-640CAD34F24A",
        "eventName": "FindGame",
        "event": "{\"playerName\": \"Player One\",\"gameToken\": \"1ACFD06E\"}"
    }
    """#
fileprivate let playACardCommand = #"""
    {
      "clientID": "1ACFD06E-594C-4C48-A912-640CAD34F24A",
      "eventName": "PlayACard",
      "event": "{\"gameID\": \"3F315C02-B6DD-4B81-8D32-46AF6BF61CDD\",\"playerName\": \"Player One\",\"faceValue\": \"one\"}"
    }
    """#
fileprivate let startGameCommand = #"""
    {
      "clientID": "1ACFD06E-594C-4C48-A912-640CAD34F24A",
      "eventName": "StartGame",
      "event": "{\"gameMasterName\": \"Game Master\",\"pointScale\": \"linear\"}"
    }
    """#
fileprivate let startRoundCommand = #"""
    {
      "clientID": "1ACFD06E-594C-4C48-A912-640CAD34F24A",
      "eventName": "StartRound",
      "event": "{\"gameID\": \"3F315C02-B6DD-4B81-8D32-46AF6BF61CDD\",\"storyName\": \"Test Story\"}"
    }
    """#
fileprivate let replayRoundCommand = #"""
    {
      "clientID": "1ACFD06E-594C-4C48-A912-640CAD34F24A",
      "eventName": "ReplayRound",
      "event": "{\"gameID\": \"3F315C02-B6DD-4B81-8D32-46AF6BF61CDD\",\"storyName\":\"Test Story\"}"
    }
    """#
fileprivate let scoreRoundCommand = #"""
    {
      "clientID": "1ACFD06E-594C-4C48-A912-640CAD34F24A",
      "eventName": "ScoreRound",
      "event": "{\"gameID\": \"3F315C02-B6DD-4B81-8D32-46AF6BF61CDD\",\"faceValue\": \"one\"}"
    }
    """#
fileprivate let endGameCommand = #"""
    {
      "clientID": "1ACFD06E-594C-4C48-A912-640CAD34F24A",
      "eventName": "EndGame",
      "event": "{\"gameID\": \"3F315C02-B6DD-4B81-8D32-46AF6BF61CDD\"}"
    }
    """#

// MARK: - Public API

enum JSONFixture {
    case connectEvent
    case findGameQuery
    case playACardCommand
    case startGameCommand
    case startRoundCommand
    case replayRoundCommand
    case scoreRoundCommand
    case endGameCommand
}

func loadFixture(_ fixture: JSONFixture) -> String {
    switch fixture {
    case .connectEvent:
        return connectEvent
    case .findGameQuery:
        return findGameQuery
    case .playACardCommand:
        return playACardCommand
    case .startGameCommand:
        return startGameCommand
    case .startRoundCommand:
        return startRoundCommand
    case .replayRoundCommand:
        return replayRoundCommand
    case .scoreRoundCommand:
        return scoreRoundCommand
    case .endGameCommand:
        return endGameCommand
    }
}
