module Model.JsonCoders exposing
    ( decodeConnectEvent
    , decodeGameEndedEvent
    , decodeGameErrorEvent
    , decodeGameFoundEvent
    , decodeGameStartedEvent
    , decodePlayerJoinedEvent
    , decodePlayerPlayedACardEvent
    , decodePlayerQuitEvent
    , decodeRoundScoredEvent
    , decodeRoundStartedEvent
    , decodeSocketErrorEvent
    , encodeEndGameCommand
    , encodeFindGameQuery
    , encodePlayACardCommand
    , encodeReplayRoundCommand
    , encodeScoreRoundCommand
    , encodeStartGameCommand
    , encodeStartRoundCommand
    )

import Json.Decode as Decode exposing (Decoder, Error, bool, decodeString, list, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import Model.Game exposing (..)



-- DECODE FUNCTIONS


decodeConnectEvent : String -> Result Error ConnectEvent
decodeConnectEvent msg =
    decodeString connectEventDecoder msg


decodeGameStartedEvent : String -> Result Error GameStartedEvent
decodeGameStartedEvent msg =
    decodeString gameStartedEventDecoder msg


decodeGameFoundEvent : String -> Result Error GameFoundEvent
decodeGameFoundEvent msg =
    decodeString gameFoundEventDecoder msg


decodePlayerJoinedEvent : String -> Result Error PlayerJoinedEvent
decodePlayerJoinedEvent msg =
    decodeString playerJoinedEventDecoder msg


decodePlayerQuitEvent : String -> Result Error PlayerQuitEvent
decodePlayerQuitEvent msg =
    decodeString playerQuitEventDecoder msg


decodeRoundStartedEvent : String -> Result Error RoundStartedEvent
decodeRoundStartedEvent msg =
    decodeString roundStartedEventDecoder msg


decodePlayerPlayedACardEvent : String -> Result Error PlayerPlayedACardEvent
decodePlayerPlayedACardEvent msg =
    decodeString playerPlayedACardEventDecoder msg


decodeRoundScoredEvent : String -> Result Error RoundScoredEvent
decodeRoundScoredEvent msg =
    decodeString roundScoredEventDecoder msg


decodeGameEndedEvent : String -> Result Error GameEndedEvent
decodeGameEndedEvent msg =
    decodeString gameEndedEventDecoder msg


decodeSocketErrorEvent : String -> Result Error SocketErrorEvent
decodeSocketErrorEvent msg =
    decodeString socketErrorEventDecoder msg


decodeGameErrorEvent : String -> Result Error GameErrorEvent
decodeGameErrorEvent msg =
    decodeString gameErrorEventDecoder msg



-- ENCODE FUNCTIONS


encodeValueToString : Encode.Value -> String
encodeValueToString value =
    Encode.encode 0 value


encodeSocketMessage : String -> EventName -> String -> Encode.Value
encodeSocketMessage clientID eventName event =
    Encode.object
        [ ( "clientID", Encode.string clientID )
        , ( "eventName", Encode.string <| getEventName eventName )
        , ( "event", Encode.string event )
        ]


encodeFindGameQuery : String -> FindGameQuery -> String
encodeFindGameQuery eventID query =
    findGameQueryEncoder query
        |> encodeValueToString
        |> encodeSocketMessage eventID findGameQuery
        |> encodeValueToString


encodeStartGameCommand : String -> StartGameCommand -> String
encodeStartGameCommand eventID command =
    startGameCommandEncoder command
        |> encodeValueToString
        |> encodeSocketMessage eventID startGameCommand
        |> encodeValueToString


encodeStartRoundCommand : String -> StartRoundCommand -> String
encodeStartRoundCommand eventID command =
    startRoundCommandEncoder command
        |> encodeValueToString
        |> encodeSocketMessage eventID startRoundCommand
        |> encodeValueToString


encodePlayACardCommand : String -> PlayACardCommand -> String
encodePlayACardCommand eventID command =
    playACardCommandEncoder command
        |> encodeValueToString
        |> encodeSocketMessage eventID playACardCommand
        |> encodeValueToString


encodeReplayRoundCommand : String -> ReplayRoundCommand -> String
encodeReplayRoundCommand eventID command =
    replayRoundCommandEncoder command
        |> encodeValueToString
        |> encodeSocketMessage eventID replayRoundCommand
        |> encodeValueToString


encodeScoreRoundCommand : String -> ScoreRoundCommand -> String
encodeScoreRoundCommand eventID command =
    scoreRoundCommandEncoder command
        |> encodeValueToString
        |> encodeSocketMessage eventID scoreRoundCommand
        |> encodeValueToString


encodeEndGameCommand : String -> EndGameCommand -> String
encodeEndGameCommand eventID command =
    endGameCommandEncoder command
        |> encodeValueToString
        |> encodeSocketMessage eventID endGameCommand
        |> encodeValueToString



-- GAME EVENT DECODERS


connectEventDecoder : Decoder ConnectEvent
connectEventDecoder =
    Decode.succeed ConnectEvent
        |> required "clientID" string
        |> required "eventName" string
        |> required "event" string


gameStartedEventDecoder : Decoder GameStartedEvent
gameStartedEventDecoder =
    Decode.succeed GameStartedEvent
        |> required "gameID" string
        |> required "gameToken" string
        |> required "gameMasterName" string


gameFoundEventDecoder : Decoder GameFoundEvent
gameFoundEventDecoder =
    Decode.succeed GameFoundEvent
        |> required "gameID" string
        |> required "playerName" string
        |> required "gameMasterName" string
        |> required "playerNames" (list string)
        |> required "lobbyPlayerNames" (list string)
        |> required "hand" (list string)
        |> required "playerCards" (list string)


playerJoinedEventDecoder : Decoder PlayerJoinedEvent
playerJoinedEventDecoder =
    Decode.succeed PlayerJoinedEvent
        |> required "gameID" string
        |> required "playerName" string
        |> required "isInLobby" bool


playerQuitEventDecoder : Decoder PlayerQuitEvent
playerQuitEventDecoder =
    Decode.succeed PlayerQuitEvent
        |> required "gameID" string
        |> required "playerName" string


roundStartedEventDecoder : Decoder RoundStartedEvent
roundStartedEventDecoder =
    Decode.succeed RoundStartedEvent
        |> required "gameID" string
        |> required "storyName" string
        |> required "playerNames" (list string)
        |> required "lobbyPlayerNames" (list string)
        |> required "hand" (list string)


playerPlayedACardEventDecoder : Decoder PlayerPlayedACardEvent
playerPlayedACardEventDecoder =
    Decode.succeed PlayerPlayedACardEvent
        |> required "gameID" string
        |> required "playerName" string
        |> required "hand" (list string)
        |> required "playerCards" (list string)


roundScoredEventDecoder : Decoder RoundScoredEvent
roundScoredEventDecoder =
    Decode.succeed RoundScoredEvent
        |> required "gameID" string
        |> required "faceValue" string


gameEndedEventDecoder : Decoder GameEndedEvent
gameEndedEventDecoder =
    Decode.succeed GameEndedEvent
        |> required "gameID" string
        |> required "scoreboard" (list string)


socketErrorEventDecoder : Decoder SocketErrorEvent
socketErrorEventDecoder =
    Decode.succeed SocketErrorEvent
        |> required "failedEventName" string
        |> required "errorMessage" string


gameErrorEventDecoder : Decoder GameErrorEvent
gameErrorEventDecoder =
    Decode.succeed GameErrorEvent
        |> required "gameID" string
        |> required "failedEventName" string
        |> required "errorMessage" string



-- QUERY ENCODERS


findGameQueryEncoder : FindGameQuery -> Encode.Value
findGameQueryEncoder query =
    Encode.object
        [ ( "playerName", Encode.string query.playerName )
        , ( "gameToken", Encode.string query.gameToken )
        ]



-- COMMAND ENCODERS


startGameCommandEncoder : StartGameCommand -> Encode.Value
startGameCommandEncoder command =
    Encode.object
        [ ( "gameMasterName", Encode.string command.gameMasterName )
        , ( "pointScale", Encode.string <| getPointScaleName command.pointScale )
        ]


startRoundCommandEncoder : StartRoundCommand -> Encode.Value
startRoundCommandEncoder command =
    Encode.object
        [ ( "gameID", Encode.string command.gameID )
        , ( "storyName", Encode.string command.storyName )
        ]


playACardCommandEncoder : PlayACardCommand -> Encode.Value
playACardCommandEncoder command =
    Encode.object
        [ ( "gameID", Encode.string command.gameID )
        , ( "playerName", Encode.string command.playerName )
        , ( "faceValue", Encode.string <| getFaceValueName command.faceValue )
        ]


replayRoundCommandEncoder : ReplayRoundCommand -> Encode.Value
replayRoundCommandEncoder command =
    Encode.object
        [ ( "gameID", Encode.string <| command.gameID )
        , ( "storyName", Encode.string <| command.storyName )
        ]


scoreRoundCommandEncoder : ScoreRoundCommand -> Encode.Value
scoreRoundCommandEncoder command =
    Encode.object
        [ ( "gameID", Encode.string command.gameID )
        , ( "faceValue", Encode.string <| getFaceValueName command.faceValue )
        ]


endGameCommandEncoder : EndGameCommand -> Encode.Value
endGameCommandEncoder command =
    Encode.object
        [ ( "gameID", Encode.string command.gameID ) ]
