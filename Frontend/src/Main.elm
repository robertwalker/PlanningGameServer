port module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input exposing (Label, OptionState)
import Html exposing (Html)
import Json.Decode exposing (errorToString)
import Model.Game exposing (..)
import Model.JsonCoders exposing (..)
import Model.Theme exposing (..)
import Url



-- MAIN


main : Program Bool Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }



-- PORTS


port sendMessage : String -> Cmd msg


port messageReceiver : (String -> msg) -> Sub msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    messageReceiver Recv



-- MODEL


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , clientID : String
    , gameID : String
    , gameTokenInput : String
    , gameToken : String
    , isGameMaster : Bool
    , gameMasterName : String
    , pointScale : PointScale
    , playerName : String
    , hand : List PlayingCard
    , players : List String
    , lobbyPlayers : List String
    , playerCards : List PlayerCard
    , storyName : String
    , storyNameInput : String
    , scoreboard : List Round
    , alertMessage : String
    , footerMessage : String
    , messages : List String
    , showConsole : Bool
    }


init : Bool -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init showConsole url key =
    ( { key = key
      , url = url
      , clientID = ""
      , gameID = ""
      , gameTokenInput = ""
      , gameToken = ""
      , isGameMaster = False
      , gameMasterName = ""
      , pointScale = linear
      , playerName = ""
      , hand = []
      , players = []
      , lobbyPlayers = []
      , playerCards = []
      , storyName = ""
      , storyNameInput = ""
      , scoreboard = []
      , alertMessage = ""
      , footerMessage = "Welcome to the Planning Game!"
      , messages = []
      , showConsole = showConsole
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = NoOp
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | Recv String
    | UserTypedGameMasterName String
    | UserTypedPlayerName String
    | UserChosePointScale PointScale
    | UserTypedGameToken String
    | UserTypedStoryName String
    | UserClickedAlertCloseButton
    | StartNewGame
    | FindExistingGame
    | StartNewRound String
    | UserPlayedACard PlayerCard
    | ReplayRound
    | ScoreLastRound FaceValue
    | EndGame
    | HideScoreboard


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url }
            , Cmd.none
            )

        Recv message ->
            handleInboundMessage model message

        UserTypedGameMasterName gameMasterName ->
            ( { model | gameMasterName = gameMasterName }
            , Cmd.none
            )

        UserTypedPlayerName playerName ->
            ( { model | playerName = playerName }
            , Cmd.none
            )

        UserChosePointScale pointScale ->
            ( { model | pointScale = pointScale }
            , Cmd.none
            )

        UserTypedGameToken token ->
            ( { model | gameTokenInput = token }
            , Cmd.none
            )

        UserTypedStoryName storyName ->
            ( { model | storyNameInput = storyName }
            , Cmd.none
            )

        UserClickedAlertCloseButton ->
            ( { model | alertMessage = "" }, Cmd.none )

        StartNewGame ->
            ( { model | alertMessage = "" }, sendStartGameCommand model )

        FindExistingGame ->
            ( { model | alertMessage = "" }, sendFindGameQuery model )

        StartNewRound storyName ->
            ( { model | alertMessage = "" }, sendStartRoundCommand model storyName )

        UserPlayedACard card ->
            ( { model | alertMessage = "" }, sendPlayACardCommand model card )

        ReplayRound ->
            ( { model | alertMessage = "" }, sendReplayRoundCommand model )

        ScoreLastRound faceValue ->
            ( { model | alertMessage = "" }, sendScoreRoundCommand model faceValue )

        EndGame ->
            ( { model | alertMessage = "" }, sendEndGameCommand model )

        HideScoreboard ->
            ( { model | scoreboard = [], alertMessage = "", messages = [] }, Cmd.none )



-- INBOUND GAME EVENTS


storeClientID : Model -> String -> String -> Model
storeClientID model clientID message =
    if String.isEmpty model.clientID then
        { model | clientID = clientID, messages = model.messages ++ [ message ] }

    else
        { model | messages = model.messages ++ [ message ] }


handleInboundMessage : Model -> String -> ( Model, Cmd Msg )
handleInboundMessage model message =
    let
        result =
            decodeConnectEvent message
    in
    case result of
        Err _ ->
            ( model, Cmd.none )

        Ok event ->
            storeClientID model event.clientID message
                |> handleGameEvent (eventNameFromString event.eventName) event.event


handleGameEvent : Maybe EventName -> String -> Model -> ( Model, Cmd Msg )
handleGameEvent maybeEventName message model =
    case maybeEventName of
        Nothing ->
            ( { model | messages = model.messages ++ [ "ERROR: Inbound event name missing or not recognized" ] }
            , Cmd.none
            )

        Just eventName ->
            case eventName of
                Connect _ ->
                    ( model, Cmd.none )

                GameStarted _ ->
                    ( handleGameStartedEvent message model, Cmd.none )

                GameFound _ ->
                    ( handleGameFoundEvent message model, Cmd.none )

                PlayerJoined _ ->
                    ( handlePlayerJoinedEvent message model, Cmd.none )

                PlayerQuit _ ->
                    ( handlePlayerQuitEvent message model, Cmd.none )

                RoundStarted _ ->
                    ( handleRoundStartedEvent message model, Cmd.none )

                PlayerPlayedACard _ ->
                    ( handlePlayerPlayedACardEvent message model, Cmd.none )

                RoundScored _ ->
                    ( handleRoundScoredEvent message model, Cmd.none )

                GameEnded _ ->
                    ( handleGameEndedEvent message model, Cmd.none )

                SocketError _ ->
                    ( handleSocketErrorEvent message model, Cmd.none )

                GameError _ ->
                    ( handleGameErrorEvent message model, Cmd.none )

                _ ->
                    ( { model | messages = model.messages ++ [ "ERROR: Unknown inbound event" ] }, Cmd.none )


handleGameStartedEvent : String -> Model -> Model
handleGameStartedEvent message model =
    let
        result =
            decodeGameStartedEvent message
    in
    case result of
        Err error ->
            { model | messages = model.messages ++ [ errorToString error ] }

        Ok event ->
            { model
                | gameID = event.gameID
                , gameToken = event.gameToken
                , gameTokenInput = ""
                , gameMasterName = event.gameMasterName
                , isGameMaster = True
                , scoreboard = []
                , footerMessage =
                    "Welcome to the game "
                        ++ event.gameMasterName
                        ++ ". Use the game token \""
                        ++ event.gameToken
                        ++ "\" to invite players to your game."
            }


handleGameFoundEvent : String -> Model -> Model
handleGameFoundEvent message model =
    let
        result =
            decodeGameFoundEvent message
    in
    case result of
        Err error ->
            { model | messages = model.messages ++ [ errorToString error ] }

        Ok event ->
            { model
                | gameID = event.gameID
                , gameToken = model.gameTokenInput
                , gameTokenInput = ""
                , playerName = event.playerName
                , gameMasterName = event.gameMasterName
                , players = event.playerNames
                , lobbyPlayers = event.lobbyPlayerNames
                , hand = makePlayerHand event.hand
                , playerCards = makePlayerCards event.playerCards
                , scoreboard = []
                , footerMessage =
                    "Welcome to the game "
                        ++ event.playerName
                        ++ ". Wait for the game host to start a round."
                , messages = model.messages ++ [ "Players: [" ++ String.join "," event.playerNames ++ "]" ]
            }


handlePlayerJoinedEvent : String -> Model -> Model
handlePlayerJoinedEvent message model =
    let
        result =
            decodePlayerJoinedEvent message
    in
    case result of
        Err error ->
            { model | messages = model.messages ++ [ errorToString error ] }

        Ok event ->
            { model
                | players = updatedPlayers event model.players
                , lobbyPlayers = updatedLobbyPlayers event model.lobbyPlayers
                , footerMessage = event.playerName ++ " has joined the game."
                , messages =
                    model.messages
                        ++ [ "Players: [" ++ String.join "," (model.players ++ [ event.playerName ]) ++ "]" ]
            }


handlePlayerQuitEvent : String -> Model -> Model
handlePlayerQuitEvent message model =
    let
        result =
            decodePlayerQuitEvent message
    in
    case result of
        Err error ->
            { model | messages = model.messages ++ [ errorToString error ] }

        Ok event ->
            { model
                | players = List.filter (\a -> a /= event.playerName) model.players
                , footerMessage = event.playerName ++ " has left the game."
                , messages = model.messages ++ [ "Player Quit: " ++ event.playerName ]
            }


handleRoundStartedEvent : String -> Model -> Model
handleRoundStartedEvent message model =
    let
        result =
            decodeRoundStartedEvent message
    in
    case result of
        Err error ->
            { model | messages = model.messages ++ [ errorToString error ] }

        Ok event ->
            { model
                | storyNameInput = ""
                , storyName = event.storyName
                , players = event.playerNames
                , lobbyPlayers = event.lobbyPlayerNames
                , playerCards = []
                , hand = List.map (\name -> makePlayingCardWithCardName name) event.hand
                , footerMessage = "Starting (or replaying) \"" ++ event.storyName ++ ".\""
                , messages = model.messages ++ [ "Round Started: " ++ event.storyName ]
            }


handlePlayerPlayedACardEvent : String -> Model -> Model
handlePlayerPlayedACardEvent message model =
    let
        result =
            decodePlayerPlayedACardEvent message
    in
    case result of
        Err error ->
            { model | messages = model.messages ++ [ errorToString error ] }

        Ok event ->
            { model
                | hand = makePlayerHand event.hand
                , playerCards = makePlayerCards event.playerCards
                , footerMessage = event.playerName ++ " played a card."
                , messages = model.messages ++ [ event.playerName ++ " Played a Card" ]
            }


handleRoundScoredEvent : String -> Model -> Model
handleRoundScoredEvent message model =
    let
        result =
            decodeRoundScoredEvent message
    in
    case result of
        Err error ->
            { model | messages = model.messages ++ [ errorToString error ] }

        Ok event ->
            { model
                | hand = []
                , playerCards = []
                , storyName = ""
                , footerMessage =
                    "\""
                        ++ model.storyName
                        ++ "\" was assigned "
                        ++ pluralized event.faceValue "point"
                        ++ "."
                , messages = model.messages ++ [ "Round Scored with a " ++ event.faceValue ++ " card" ]
            }


handleGameEndedEvent : String -> Model -> Model
handleGameEndedEvent message model =
    let
        result =
            decodeGameEndedEvent message
    in
    case result of
        Err error ->
            { model | messages = model.messages ++ [ errorToString error ] }

        Ok event ->
            let
                roundCount =
                    String.fromInt (List.length event.scoreboard)
            in
            { model
                | gameID = ""
                , gameToken = ""
                , gameTokenInput = ""
                , isGameMaster = False
                , gameMasterName = ""
                , pointScale = linear
                , playerName = ""
                , hand = []
                , players = []
                , playerCards = []
                , storyName = ""
                , scoreboard = makeScoreboard event.scoreboard
                , footerMessage = "The game host ended the game."
                , messages =
                    model.messages
                        ++ [ "Game ended with "
                                ++ roundCount
                                ++ pluralized roundCount "round"
                           ]
            }


handleSocketErrorEvent : String -> Model -> Model
handleSocketErrorEvent message model =
    let
        result =
            decodeSocketErrorEvent message
    in
    case result of
        Err error ->
            { model | messages = model.messages ++ [ errorToString error ] }

        Ok event ->
            { model
                | alertMessage = event.errorMessage
                , messages =
                    model.messages
                        ++ [ "Failed Event: "
                                ++ event.failedEventName
                                ++ ", Error: "
                                ++ event.errorMessage
                           ]
            }


handleGameErrorEvent : String -> Model -> Model
handleGameErrorEvent message model =
    let
        result =
            decodeGameErrorEvent message
    in
    case result of
        Err error ->
            { model | messages = model.messages ++ [ errorToString error ] }

        Ok event ->
            { model
                | alertMessage = event.errorMessage
                , messages =
                    model.messages
                        ++ [ "GameID: "
                                ++ event.gameID
                                ++ ", Failed Event: "
                                ++ event.failedEventName
                                ++ ", Error: "
                                ++ event.errorMessage
                           ]
            }



-- OUTBOUND GAME EVENTS


sendStartGameCommand : Model -> Cmd msg
sendStartGameCommand model =
    sendMessage <|
        encodeStartGameCommand model.clientID <|
            StartGameCommand model.gameMasterName model.pointScale


sendFindGameQuery : Model -> Cmd msg
sendFindGameQuery model =
    sendMessage <|
        encodeFindGameQuery model.clientID <|
            FindGameQuery model.playerName model.gameTokenInput


sendStartRoundCommand : Model -> String -> Cmd msg
sendStartRoundCommand model storyName =
    sendMessage <|
        encodeStartRoundCommand model.clientID <|
            StartRoundCommand model.gameID storyName


sendPlayACardCommand : Model -> PlayerCard -> Cmd msg
sendPlayACardCommand model card =
    sendMessage <|
        encodePlayACardCommand model.clientID <|
            PlayACardCommand model.gameID card.player.name card.playingCard.faceValue


sendReplayRoundCommand : Model -> Cmd msg
sendReplayRoundCommand model =
    sendMessage <|
        encodeReplayRoundCommand model.clientID <|
            ReplayRoundCommand model.gameID model.storyName


sendScoreRoundCommand : Model -> FaceValue -> Cmd msg
sendScoreRoundCommand model faceValue =
    sendMessage <|
        encodeScoreRoundCommand model.clientID <|
            ScoreRoundCommand model.gameID faceValue


sendEndGameCommand : Model -> Cmd msg
sendEndGameCommand model =
    sendMessage <|
        encodeEndGameCommand model.clientID <|
            EndGameCommand model.gameID



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "PlanningGame: Join Game"
    , body = [ layout model ]
    }


layout : Model -> Html Msg
layout model =
    Element.layout [] <|
        column
            [ width fill
            , height fill
            ]
        <|
            selectContent model


selectContent : Model -> List (Element Msg)
selectContent model =
    if not (List.isEmpty model.scoreboard) then
        [ headerRow model
        , scoreboardContentArea model
        , footer model
        ]

    else if model.gameID == "" then
        [ headerRow model
        , startContentArea model
        , footer model
        ]

    else
        [ headerRow model
        , playContentArea model
        , footer model
        ]


headerRow : Model -> Element msg
headerRow model =
    row
        [ Background.color color.paleOrange
        , width fill
        , spacing 10
        , padding 20
        ]
        [ planningGameIconImage
        , el
            [ Font.family teko
            , Font.color color.darkBlue
            , Font.size 52
            ]
          <|
            text "Planning Game"
        , renderIf (showGameTokenView model) (gameTokenView model)
        ]


showGameTokenView : Model -> Bool
showGameTokenView model =
    not (String.isEmpty model.gameToken)


gameTokenView : Model -> Element msg
gameTokenView model =
    row
        [ width fill
        , spacing 6
        ]
        [ el [ alignRight ] <| subheadingText "Game Token:" 20
        , el
            [ alignRight
            , paddingXY 10 6
            , Font.color color.darkCharcoal
            , Border.width 1
            , Border.color color.darkCharcoal
            , Background.color color.softWhite
            ]
          <|
            subheadingText model.gameToken 20
        ]


alertView : Model -> Element Msg
alertView model =
    el
        [ width fill
        , paddingXY 10 8
        , Font.color color.darkCharcoal
        , Border.rounded 10
        , Border.widthXY 0 2
        , Border.color color.darkCharcoal
        , Background.color color.alert
        ]
    <|
        row [ spacing 10 ]
            [ closeButton
            , text model.alertMessage
            ]


closeButton : Element Msg
closeButton =
    Input.button
        [ Font.color color.red

        -- , Border.rounded 6
        -- , Border.width 1
        -- , Border.color color.darkCharcoal
        -- , Background.color color.red
        ]
        { onPress = Just UserClickedAlertCloseButton
        , label =
            image
                [ width <| px 18
                , height <| px 18
                , mouseOver [ alpha 0.7 ]
                ]
                { src = "/images/Close_Button.png"
                , description = "Close alert button"
                }
        }


footer : Model -> Element msg
footer model =
    row
        [ Background.color color.paleOrange
        , alignBottom
        , width fill
        , paddingXY 20 8
        ]
        [ subheadingText model.footerMessage 16 ]


debugConsole : Model -> Element msg
debugConsole model =
    column
        [ alignBottom
        , width fill
        , height (px 100)
        , paddingXY 10 5
        , scrollbars
        , Font.size 14
        , Font.color color.darkCharcoal
        , Border.solid
        , Border.widthXY 0 1
        , Border.color color.darkCharcoal
        , Background.color color.softWhite
        ]
    <|
        List.map (\msg -> el [] (text msg)) model.messages


type ButtonPosition
    = First
    | Mid
    | Last


button : ButtonPosition -> String -> OptionState -> Element msg
button position label state =
    let
        borders =
            case position of
                First ->
                    { left = 2, right = 2, top = 2, bottom = 2 }

                Mid ->
                    { left = 0, right = 2, top = 2, bottom = 2 }

                Last ->
                    { left = 0, right = 2, top = 2, bottom = 2 }

        corners =
            case position of
                First ->
                    { topLeft = 6, bottomLeft = 6, topRight = 0, bottomRight = 0 }

                Mid ->
                    { topLeft = 0, bottomLeft = 0, topRight = 0, bottomRight = 0 }

                Last ->
                    { topLeft = 0, bottomLeft = 0, topRight = 6, bottomRight = 6 }
    in
    el
        [ paddingXY 20 10
        , Border.roundEach corners
        , Border.widthEach borders
        , Border.color color.blue
        , Background.color <|
            if state == Input.Selected then
                color.lightBlue

            else
                color.white
        ]
    <|
        el [ centerX, centerY ] <|
            text label


renderIf : Bool -> Element msg -> Element msg
renderIf condition content =
    if condition then
        content

    else
        none


cardLabel : String -> Element msg
cardLabel msg =
    el
        [ centerX
        , Font.size 18
        , Font.color color.paleOrange
        , Font.shadow { offset = ( 3, 3 ), blur = 5, color = rgb 0 0 0 }
        ]
        (text msg)


gameBoardText : String -> Element msg
gameBoardText msg =
    paragraph []
        [ el
            [ Font.size 18
            , Font.color color.paleOrange
            , Font.shadow { offset = ( 3, 3 ), blur = 5, color = rgb 0 0 0 }
            ]
            (text msg)
        ]



-- VIEW START/JOIN


startContentArea : Model -> Element Msg
startContentArea model =
    column
        [ width fill
        , height fill
        ]
        [ column
            [ Background.color color.mediumGreen
            , width fill
            , height fill
            , padding 20
            , spacing 50
            , scrollbars
            ]
            [ renderIf (not (String.isEmpty model.alertMessage)) (alertView model)
            , inputContainer model
            ]
        , renderIf model.showConsole (debugConsole model)
        ]


inputContainer : Model -> Element Msg
inputContainer model =
    row
        [ spacing 25
        , centerX
        , paddingXY 20 100
        ]
        [ inputPanel <| startGamePanel model
        , el
            [ Font.color color.paleOrange
            , Font.size 20
            ]
          <|
            text "OR"
        , inputPanel <| joinGamePanel model
        ]


inputPanel : Element msg -> Element msg
inputPanel content =
    column
        [ width <| px 400
        , height <| px 400
        , padding 20
        , Background.color color.paleOrange
        ]
        [ content ]


inputLabel : String -> Int -> Label msg
inputLabel label padding =
    Input.labelAbove
        [ centerX
        , Font.color color.darkBlue
        , paddingEach { bottom = padding, top = 0, left = 0, right = 0 }
        ]
    <|
        text label


gameMasterNameInputView : String -> Element Msg
gameMasterNameInputView name =
    Input.text [ width <| maximum 300 fill, centerX ]
        { onChange = UserTypedGameMasterName
        , text = name
        , placeholder = Just <| Input.placeholder [] <| text "Enter your name"
        , label = inputLabel "Game Host Name" 10
        }


playerNameInputView : String -> Element Msg
playerNameInputView name =
    Input.text [ width <| maximum 300 fill, centerX ]
        { onChange = UserTypedPlayerName
        , text = name
        , placeholder = Just <| Input.placeholder [] <| text "Enter your name"
        , label = inputLabel "Player Name" 10
        }


gameTokenInputView : String -> Element Msg
gameTokenInputView token =
    Input.text [ width <| maximum 300 fill, centerX ]
        { onChange = UserTypedGameToken
        , text = token
        , placeholder = Just <| Input.placeholder [] <| text "Enter the game token"
        , label = inputLabel "Game Token" 10
        }


pointScaleLabelText : PointScale -> String
pointScaleLabelText pointScale =
    case pointScale of
        Linear _ ->
            "Choose a Point Scale" ++ " (0, 1, 2, 3)"

        PowersOfTwo _ ->
            "Choose a Point Scale" ++ " (0, 1, 2, 4, 8)"

        Fibonacci _ ->
            "Choose a Point Scale" ++ " (0, 1, 2, 3, 5, 8)"


pointScaleRadioButtons : PointScale -> Element Msg
pointScaleRadioButtons pointScale =
    Input.radioRow
        [ Border.rounded 6
        , paddingEach { bottom = 2, top = 0, left = 0, right = 0 }
        ]
        { onChange = UserChosePointScale
        , selected = Just pointScale
        , label = inputLabel (pointScaleLabelText pointScale) 15
        , options =
            [ Input.optionWith linear <| button First "Linear"
            , Input.optionWith powersOfTwo <| button Mid "Powers of 2"
            , Input.optionWith fibonacci <| button Last "Fibonacci"
            ]
        }


startGameButton : Element Msg
startGameButton =
    Input.button primaryButtonStyle
        { onPress = Just StartNewGame
        , label = text "Start Game"
        }


findGameButton : Element Msg
findGameButton =
    Input.button primaryButtonStyle
        { onPress = Just FindExistingGame
        , label = text "Find Game"
        }


startGamePanel : Model -> Element Msg
startGamePanel model =
    column
        [ width fill
        , spacing 30
        ]
        [ el [ centerX ] <| subheadingText "Start a Game" 35
        , gameMasterNameInputView model.gameMasterName
        , el [ centerX ] <| pointScaleRadioButtons model.pointScale
        , el [ centerX ] startGameButton
        ]


joinGamePanel : Model -> Element Msg
joinGamePanel model =
    column
        [ width fill
        , spacing 30
        ]
        [ el [ centerX ] <| subheadingText "Join a Game" 35
        , playerNameInputView model.playerName
        , gameTokenInputView model.gameTokenInput
        , el [ centerX ] findGameButton
        ]



-- VIEW PLAY


playContentArea : Model -> Element Msg
playContentArea model =
    column
        [ width fill
        , height fill
        ]
        [ row
            [ width fill
            , height fill
            ]
            [ gameBoardArea model
            , playersView model
            ]
        , renderIf model.showConsole (debugConsole model)
        ]


gameBoardArea : Model -> Element Msg
gameBoardArea model =
    column
        [ Background.color color.mediumGreen
        , width fill
        , height fill
        , padding 20
        , spacing 25
        , scrollbars
        ]
        [ renderIf (not (String.isEmpty model.alertMessage)) (alertView model)
        , renderIf (showStartRoundForm model) (startRoundForm model)
        , renderIf (showReplayRoundButton model) replayRoundButton
        , renderIf (showBlankState model) blankStateView
        , gameBoardView model
        , playerHandView model
        ]


showBlankState : Model -> Bool
showBlankState model =
    not model.isGameMaster && String.isEmpty model.storyName


showStartRoundForm : Model -> Bool
showStartRoundForm model =
    model.isGameMaster && String.isEmpty model.storyName


showReplayRoundButton : Model -> Bool
showReplayRoundButton model =
    model.isGameMaster && not (String.isEmpty model.storyName)


blankStateView : Element msg
blankStateView =
    el
        [ width fill
        , padding 20
        , Border.solid
        , Border.width 2
        , Border.color color.darkCharcoal
        , Background.color color.darkGreen
        ]
    <|
        gameBoardText "Wait for the host to start a game round."


gameBoardView : Model -> Element msg
gameBoardView model =
    if List.isEmpty model.playerCards then
        row
            [ width fill
            , height (px 210)
            ]
            [ el [] (text "") ]

    else
        wrappedRow
            [ width fill
            , spacing 15
            ]
            (playedCardsView model)


playerHandView : Model -> Element Msg
playerHandView model =
    column
        [ spacing 12 ]
        [ row [] [ gameBoardText (storyText model) ]
        , row
            [ height fill
            , spacing -40
            ]
          <|
            List.map (\card -> playableCardView model card) model.hand
        ]


storyText : Model -> String
storyText model =
    if String.isEmpty model.storyName then
        ""

    else if model.isGameMaster then
        "Select a point card after all players have played a card to score \"" ++ model.storyName ++ ".\""

    else
        "Select a point card to estimate the level of effort for \"" ++ model.storyName ++ ".\""


startRoundForm : Model -> Element Msg
startRoundForm model =
    row
        [ width fill, spacing 20 ]
        [ storyNameInputView model.storyNameInput
        , startRoundButton model.storyNameInput
        , endGameButton
        ]


storyNameInputLabel : String -> Label msg
storyNameInputLabel label =
    Input.labelLeft
        [ centerY
        , Font.size 18
        , Font.color color.paleOrange
        , Font.shadow { offset = ( 3, 3 ), blur = 5, color = rgb 0 0 0 }
        , paddingEach { edges | right = 10 }
        ]
    <|
        text label


storyNameInputView : String -> Element Msg
storyNameInputView name =
    Input.text [ width (fill |> maximum 650), alignLeft ]
        { onChange = UserTypedStoryName
        , text = name
        , placeholder = Just <| Input.placeholder [] <| text "Enter a story name"
        , label = storyNameInputLabel "Story Name:"
        }


startRoundButton : String -> Element Msg
startRoundButton storyName =
    Input.button smallButtonStyle
        { onPress = Just (StartNewRound storyName)
        , label = text "Start Round"
        }


replayRoundButton : Element Msg
replayRoundButton =
    Input.button smallButtonStyle
        { onPress = Just ReplayRound
        , label = text "Replay Round"
        }


endGameButton : Element Msg
endGameButton =
    Input.button smallButtonStyle
        { onPress = Just EndGame
        , label = text "End Game"
        }


playersView : Model -> Element msg
playersView model =
    column
        [ width (px 200)
        , height fill
        , Font.size 14
        , Font.color color.paleOrange
        , Border.widthEach { edges | left = 2 }
        , Border.color color.darkCharcoal
        , Background.color color.darkGreen
        ]
        [ playerHeaderView
        , playersListView model
        ]


playerHeaderView : Element msg
playerHeaderView =
    el
        [ width fill
        , padding 10
        , Font.size 18
        , Font.color color.softWhite
        , Border.widthEach { edges | bottom = 1 }
        , Border.color color.darkCharcoal
        , Background.color color.darkBlue
        ]
        (text "Players:")


playersListView : Model -> Element msg
playersListView model =
    column
        [ width fill
        , height fill
        , padding 10
        , spacing 8
        , scrollbarX
        ]
    <|
        el [] (text (model.gameMasterName ++ " (Host)"))
            :: List.map
                (\name -> taggedPlayerName name model)
                model.players
            ++ List.map
                (\name -> taggedPlayerName name model)
                model.lobbyPlayers


taggedPlayerName : String -> Model -> Element msg
taggedPlayerName name model =
    if playerHasPlayedACard name model.playerCards then
        text (name ++ " ✔︎")

    else if List.member name model.lobbyPlayers then
        text (name ++ " ⏱")

    else
        text name


cardImageView : FaceValue -> Bool -> Element msg
cardImageView faceValue isFaceDown =
    el
        [ centerX ]
    <|
        image
            [ width (px 120) ]
            { src = imageSrc faceValue isFaceDown
            , description = "An image of a playing card"
            }


playableCardView : Model -> PlayingCard -> Element Msg
playableCardView model card =
    let
        player =
            makePlayerWithName model.playerName

        playerCard =
            PlayerCard player card
    in
    Input.button
        []
        { onPress = Just (playableCardMsg model playerCard)
        , label =
            el [ alignTop ] (cardImageView card.faceValue False)
        }


playableCardMsg : Model -> PlayerCard -> Msg
playableCardMsg model card =
    if model.isGameMaster then
        ScoreLastRound card.playingCard.faceValue

    else
        UserPlayedACard card


playedCardsView : Model -> List (Element msg)
playedCardsView model =
    List.map (\card -> playedCardView card) model.playerCards


playedCardView : PlayerCard -> Element msg
playedCardView playerCard =
    column
        [ spacing 8 ]
        [ cardImageView playerCard.playingCard.faceValue playerCard.playingCard.isFaceDown
        , cardLabel playerCard.player.name
        ]


imageSrc : FaceValue -> Bool -> String
imageSrc faceValue isFaceDown =
    let
        imageName =
            if isFaceDown then
                getCardBackImageName

            else
                getCardImageName faceValue
    in
    "/images/" ++ imageName



-- VIEW SCOREBOARD


scoreboardContentArea : Model -> Element Msg
scoreboardContentArea model =
    column
        [ width fill
        , height fill
        ]
        [ column
            [ Background.color color.mediumGreen
            , width fill
            , height fill
            , padding 20
            , spacing 50
            , scrollbars
            ]
            [ scoreboardPanelView model
            ]
        , renderIf model.showConsole (debugConsole model)
        ]


scoreboardPanelView : Model -> Element Msg
scoreboardPanelView model =
    column
        [ centerX
        , width (maximum 800 fill)
        , spacing 20
        ]
        [ scoreboardView model
        , doneButton
        ]


scoreboardView : Model -> Element msg
scoreboardView model =
    let
        headerAttrs =
            [ Font.family teko
            , Font.size 26
            , Font.color color.darkBlue
            , Border.color color.darkCharcoal
            , Border.widthEach { edges | bottom = 1 }
            ]
    in
    column
        [ centerX
        , width <| maximum 650 fill
        , height <| px 400
        , padding 5
        , spacing 10
        , Background.color color.softWhite
        , Border.color color.darkCharcoal

        -- , explain Debug.todo
        ]
        [ row [ width fill ]
            [ el (width fill :: headerAttrs) <| text "Story Name"
            , el (width (px 60) :: headerAttrs) <| text "Points"
            ]
        , el
            [ width fill ]
          <|
            table
                [ width fill
                , height <| px 350
                , spacingXY 0 6
                , Font.color color.darkCharcoal
                , scrollbarY
                ]
                { data = model.scoreboard
                , columns =
                    [ { header = none
                      , width = fill
                      , view =
                            \round ->
                                text round.storyName
                      }
                    , { header = none
                      , width = px 40
                      , view =
                            \round ->
                                text round.pointValue
                      }
                    ]
                }
        ]


doneButton : Element Msg
doneButton =
    el [ centerX ] <|
        Input.button smallButtonStyle
            { onPress = Just HideScoreboard
            , label = text "Done"
            }
