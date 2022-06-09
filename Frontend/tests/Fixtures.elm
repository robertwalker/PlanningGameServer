module Fixtures exposing (..)


validClientID : String
validClientID =
    "AFB3A9C0-094D-4F79-9B38-8376E9152242"


validGameID : String
validGameID =
    "0E58C8E4-5BC0-41C1-AFF2-E62BD0544DFD"


validGameToken : String
validGameToken =
    "ABCXYZ"


validConnectEventString : String
validConnectEventString =
    "{\"clientID\":\"" ++ validClientID ++ "\",\"eventName\":\"Connect\",\"event\":\"\"}"


validGameStartedEventString : String
validGameStartedEventString =
    "{\"gameID\":\""
        ++ validGameID
        ++ "\",\"gameToken\":\""
        ++ validGameToken
        ++ "\",\"gameMasterName\":\"Game Master\"}"


validGameFoundEventString : String
validGameFoundEventString =
    "{\"gameID\":\""
        ++ validGameID
        ++ "\",\"playerName\":\"Player One\","
        ++ "\"gameMasterName\":\"Game Master\","
        ++ "\"playerNames\":[\"Player One\",\"Player Two\"],"
        ++ "\"lobbyPlayerNames\":[\"Player Three\"],"
        ++ "\"hand\":[\"one\",\"two\"],"
        ++ "\"playerCards\":[\"Player One,one,true\",\"Player Two,three,true\"]}"


validPlayerJoinedEventString : String
validPlayerJoinedEventString =
    "{\"gameID\":\""
        ++ validGameID
        ++ "\",\"playerName\":\"Player One\","
        ++ "\"isInLobby\":true}"


validPlayerQuitEventString : String
validPlayerQuitEventString =
    "{\"gameID\":\""
        ++ validGameID
        ++ "\",\"playerName\":\"Player One\"}"


validRoundStartedEventString : String
validRoundStartedEventString =
    "{\"gameID\":\""
        ++ validGameID
        ++ "\",\"storyName\":\"Story One\","
        ++ "\"playerNames\":[\"Player One\",\"Player Two\"],"
        ++ "\"lobbyPlayerNames\":[\"Player Three\"],"
        ++ "\"hand\":[\"one\",\"two\",\"three\"]}"


validPlayerPlayedACardEventString : String
validPlayerPlayedACardEventString =
    "{\"gameID\":\""
        ++ validGameID
        ++ "\",\"playerName\":\"Player One\","
        ++ "\"hand\":[\"two\",\"four\",\"eight\",\"question\",\"skip\"],"
        ++ "\"playerCards\":[\"Player One,one,true\",\"Player Two,three,true\"]}"


validRoundScoredEventString : String
validRoundScoredEventString =
    "{\"gameID\":\""
        ++ validGameID
        ++ "\",\"faceValue\":\"one\"}"


validGameEndedEventString : String
validGameEndedEventString =
    "{\"gameID\":\""
        ++ validGameID
        ++ "\",\"scoreboard\":[\"First Story,1\",\"Second Story,2\"]}"


validSocketErrorEventString : String
validSocketErrorEventString =
    "{\"failedEventName\":\"Connect\",\"errorMessage\":\"User presentable error message\"}"


validGameErrorEventString : String
validGameErrorEventString =
    "{\"gameID\":\""
        ++ validGameID
        ++ "\",\"failedEventName\":\"StartGame\",\"errorMessage\":\"User presentable error message\"}"


validFindGameQueryString : String
validFindGameQueryString =
    "{\"clientID\":\""
        ++ validClientID
        ++ "\",\"eventName\":\"FindGame\","
        ++ "\"event\":\"{\\\"playerName\\\":\\\"Player One\\\",\\\"gameToken\\\":\\\"ABCDEF\\\"}\"}"


validStartGameComandString : String
validStartGameComandString =
    "{\"clientID\":\""
        ++ validClientID
        ++ "\",\"eventName\":\"StartGame\","
        ++ "\"event\":\"{\\\"gameMasterName\\\":\\\"Game Master\\\",\\\"pointScale\\\":\\\"linear\\\"}\"}"


valildStartRoundCommandString : String
valildStartRoundCommandString =
    "{\"clientID\":\""
        ++ validClientID
        ++ "\",\"eventName\":\"StartRound\",\"event\":\"{"
        ++ "\\\"gameID\\\":\\\""
        ++ validGameID
        ++ "\\\",\\\"storyName\\\":\\\"First Story\\\"}\"}"


validPlayACardCommandString : String
validPlayACardCommandString =
    "{\"clientID\":\""
        ++ validClientID
        ++ "\",\"eventName\":\"PlayACard\",\"event\":\""
        ++ "{\\\"gameID\\\":\\\""
        ++ validGameID
        ++ "\\\",\\\"playerName\\\":\\\"Player One\\\",\\\"faceValue\\\":\\\"one\\\"}\"}"


validReplayRoundCommandString : String
validReplayRoundCommandString =
    "{\"clientID\":\""
        ++ validClientID
        ++ "\",\"eventName\":\"ReplayRound\",\"event\":\""
        ++ "{\\\"gameID\\\":\\\""
        ++ validGameID
        ++ "\\\",\\\"storyName\\\":\\\"First Story\\\"}\"}"


validScoreRoundCommandString : String
validScoreRoundCommandString =
    "{\"clientID\":\""
        ++ validClientID
        ++ "\",\"eventName\":\"ScoreRound\",\"event\":\""
        ++ "{\\\"gameID\\\":\\\""
        ++ validGameID
        ++ "\\\",\\\"faceValue\\\":\\\"one\\\"}\"}"


validEndGameCommandString : String
validEndGameCommandString =
    "{\"clientID\":\""
        ++ validClientID
        ++ "\",\"eventName\":\"EndGame\",\"event\":\""
        ++ "{\\\"gameID\\\":\\\""
        ++ validGameID
        ++ "\\\"}\"}"
