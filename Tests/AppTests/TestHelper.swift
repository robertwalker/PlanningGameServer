//
//  TestSupport.swift
//  
//
//  Created by Robert Walker on 5/12/22.
//

import Foundation

enum FixtureName: String {
    case connectEvent = "ConnectEvent"
    case findGameQuery = "FindGameQuery"
    case playACardCommand = "PlayACardCommand"
    case startGameCommand = "StartGameCommand"
    case startRoundCommand = "StartRoundCommand"
    case replayRoundCommand = "ReplayRoundCommand"
    case scoreRoundCommand = "ScoreRoundCommand"
    case endGameCommand = "EndGameCommand"
}

func loadFixture(_ name: FixtureName) -> String {
    let path = fixturesPath(fixtureName: name)
    if let data = FileManager.default.contents(atPath: path) {
        return String(decoding: data, as: UTF8.self)
    }
    else {
        return ""
    }
}

fileprivate func fixturesPath(fixtureName: FixtureName) -> String {
    let developerDirectoryURL =
        try! FileManager.default.url(for: .developerDirectory,
                                     in: .userDomainMask,
                                     appropriateFor: nil,
                                     create: false)
    let fixturesDirectory = developerDirectoryURL
        .appendingPathComponent("Projects")
        .appendingPathComponent("PlanningGame")
        .appendingPathComponent("PlanningGameServer")
        .appendingPathComponent("Tests")
        .appendingPathComponent("AppTests")
        .appendingPathComponent("Fixtures")
    return fixturesDirectory
        .appendingPathComponent(fixtureName.rawValue)
        .appendingPathExtension("json").path
}
