module JsonCodersTests exposing (..)

import Expect
import Fixtures exposing (..)
import Model.Game exposing (..)
import Model.JsonCoders exposing (..)
import Test exposing (..)



-- GAME EVENT TESTS


connectEvent : Test
connectEvent =
    describe "Decoding a Connect event"
        [ test "should decode a valid JSON string" <|
            \_ ->
                let
                    result =
                        decodeConnectEvent validConnectEventString
                in
                result |> Expect.ok
        , test "should fail to decode invalid JSON string" <|
            \_ ->
                let
                    result =
                        decodeConnectEvent "Foo"
                in
                result |> Expect.err
        ]


gameStartedEvent : Test
gameStartedEvent =
    describe "Decoding a GameStarted event"
        [ test "should decode a valid JSON string" <|
            \_ ->
                let
                    result =
                        decodeGameStartedEvent validGameStartedEventString
                in
                result |> Expect.ok
        ]


gameFoundEvent : Test
gameFoundEvent =
    describe "Decoding a GameFound event"
        [ test "should decode a valid JSON string" <|
            \_ ->
                let
                    result =
                        decodeGameFoundEvent validGameFoundEventString
                in
                result |> Expect.ok
        ]


playerJoinedEvent : Test
playerJoinedEvent =
    describe "Decoding a PlayerJoined event"
        [ test "should decode a valid JSON string" <|
            \_ ->
                let
                    result =
                        decodePlayerJoinedEvent validPlayerJoinedEventString
                in
                result |> Expect.ok
        ]


playerQuitEvent : Test
playerQuitEvent =
    describe "Decoding a PlayerQuit event"
        [ test "should decode a valid JSON string" <|
            \_ ->
                let
                    result =
                        decodePlayerQuitEvent validPlayerQuitEventString
                in
                result |> Expect.ok
        ]


roundStartedEvent : Test
roundStartedEvent =
    describe "Decoding a RoundStarted event"
        [ test "should decode a valid JSON string" <|
            \_ ->
                let
                    result =
                        decodeRoundStartedEvent validRoundStartedEventString
                in
                result |> Expect.ok
        ]


playerPlayedACardEvent : Test
playerPlayedACardEvent =
    describe "Decoding a PlayerPlayedACard event"
        [ test "should decode a valid JSON string" <|
            \_ ->
                let
                    result =
                        decodePlayerPlayedACardEvent validPlayerPlayedACardEventString
                in
                result |> Expect.ok
        ]


roundScoredEvent : Test
roundScoredEvent =
    describe "Decoding a RoundScored event"
        [ test "should decode a valid JSON string" <|
            \_ ->
                let
                    result =
                        decodeRoundScoredEvent validRoundScoredEventString
                in
                result |> Expect.ok
        ]


gameEndedEvent : Test
gameEndedEvent =
    describe "Decoding a GameEnded event"
        [ test "should decode a valid JSON string" <|
            \_ ->
                let
                    result =
                        decodeGameEndedEvent validGameEndedEventString
                in
                result |> Expect.ok
        ]



-- ERROR EVENT TESTS


socketErrorEvent : Test
socketErrorEvent =
    describe "Decoding a SocketError event"
        [ test "should decode a valid JSON string" <|
            \_ ->
                let
                    result =
                        decodeSocketErrorEvent validSocketErrorEventString
                in
                result |> Expect.ok
        ]


gameErrorEvent : Test
gameErrorEvent =
    describe "Decoding a GameError event"
        [ test "should decode a valid JSON string" <|
            \_ ->
                let
                    result =
                        decodeGameErrorEvent validGameErrorEventString
                in
                result |> Expect.ok
        ]



-- GAME QUERY EVENT TESTS


findGameQuery : Test
findGameQuery =
    describe "Encoding a FileGame query"
        [ test "should encode a find game query message" <|
            \_ ->
                let
                    message =
                        encodeFindGameQuery validClientID <| FindGameQuery "Player One" "ABCDEF"
                in
                message |> Expect.equal validFindGameQueryString
        ]



-- GAME COMMAND EVENT TESTS


startGameCommand : Test
startGameCommand =
    describe "Encodeing a StartGame command"
        [ test "should encode a start game command message" <|
            \_ ->
                let
                    message =
                        encodeStartGameCommand validClientID <| StartGameCommand "Game Master" linear
                in
                message |> Expect.equal validStartGameComandString
        ]


startRoundCommand : Test
startRoundCommand =
    describe "Encodeing a StartRound command"
        [ test "should encode a start round command message" <|
            \_ ->
                let
                    message =
                        encodeStartRoundCommand validClientID <| StartRoundCommand validGameID "First Story"
                in
                message |> Expect.equal valildStartRoundCommandString
        ]


playACardCommand : Test
playACardCommand =
    describe "Encoding a PlayingACard command"
        [ test "should encode a play a card command message" <|
            \_ ->
                let
                    message =
                        encodePlayACardCommand validClientID <| PlayACardCommand validGameID "Player One" oneCard
                in
                message |> Expect.equal validPlayACardCommandString
        ]


replayRoundCommand : Test
replayRoundCommand =
    describe "Encoding a ReplayRound command"
        [ test "should encode a replay round command message" <|
            \_ ->
                let
                    message =
                        encodeReplayRoundCommand validClientID <| ReplayRoundCommand validGameID "First Story"
                in
                message |> Expect.equal validReplayRoundCommandString
        ]


scoreRoundCommand : Test
scoreRoundCommand =
    describe "Encoding a ScoreRound command"
        [ test "should encode a score round command message" <|
            \_ ->
                let
                    message =
                        encodeScoreRoundCommand validClientID <| ScoreRoundCommand validGameID oneCard
                in
                message |> Expect.equal validScoreRoundCommandString
        ]


endGameCommand : Test
endGameCommand =
    describe "Encodeing an EndGame command"
        [ test "should encode an end game command message" <|
            \_ ->
                let
                    message =
                        encodeEndGameCommand validClientID <| EndGameCommand validGameID
                in
                message |> Expect.equal validEndGameCommandString
        ]
