module Model.Game exposing (..)

-- ENUMS


type FaceValue
    = Question String
    | Skip String
    | One String
    | Two String
    | Three String
    | Four String
    | Five String
    | Eight String


questionCard : FaceValue
questionCard =
    Question "question"


skipCard : FaceValue
skipCard =
    Skip "skip"


oneCard : FaceValue
oneCard =
    One "one"


twoCard : FaceValue
twoCard =
    Two "two"


threeCard : FaceValue
threeCard =
    Three "three"


fourCard : FaceValue
fourCard =
    Four "four"


fiveCard : FaceValue
fiveCard =
    Five "five"


eightCard : FaceValue
eightCard =
    Eight "eight"



-- FACE VALUE STRING CONVERSION


getFaceValueName : FaceValue -> String
getFaceValueName faceValue =
    case faceValue of
        Question name ->
            name

        Skip name ->
            name

        One name ->
            name

        Two name ->
            name

        Three name ->
            name

        Four name ->
            name

        Five name ->
            name

        Eight name ->
            name


faceValueFromString : String -> FaceValue
faceValueFromString name =
    case name of
        "question" ->
            questionCard

        "skip" ->
            skipCard

        "one" ->
            oneCard

        "two" ->
            twoCard

        "three" ->
            threeCard

        "four" ->
            fourCard

        "five" ->
            fiveCard

        "eight" ->
            eightCard

        _ ->
            skipCard


getCardBackImageName : String
getCardBackImageName =
    "Card_Back.png"


getCardImageName : FaceValue -> String
getCardImageName faceValue =
    case faceValue of
        Question _ ->
            "Question_Card.png"

        Skip _ ->
            "Skip_Card.png"

        One _ ->
            "1_Card.png"

        Two _ ->
            "2_Card.png"

        Three _ ->
            "3_Card.png"

        Four _ ->
            "4_Card.png"

        Five _ ->
            "5_Card.png"

        Eight _ ->
            "8_Card.png"


type PointScale
    = Linear String
    | PowersOfTwo String
    | Fibonacci String


linear : PointScale
linear =
    Linear "linear"


powersOfTwo : PointScale
powersOfTwo =
    PowersOfTwo "powersOfTwo"


fibonacci : PointScale
fibonacci =
    Fibonacci "fibonacci"


getPointScaleName : PointScale -> String
getPointScaleName pointScale =
    case pointScale of
        Linear name ->
            name

        PowersOfTwo name ->
            name

        Fibonacci name ->
            name



-- EVENT NAMES


type EventName
    = Connect String
    | GameStarted String
    | GameFound String
    | PlayerJoined String
    | PlayerQuit String
    | RoundStarted String
    | PlayerPlayedACard String
    | RoundScored String
    | GameEnded String
    | SocketError String
    | GameError String
    | FindGame String
    | StartGame String
    | StartRound String
    | PlayACard String
    | ReplayRound String
    | ScoreRound String
    | EndGame String



-- GAME EVENT NAMES


connectEvent : EventName
connectEvent =
    Connect "Connect"


gameStartedEvent : EventName
gameStartedEvent =
    GameStarted "GameStarted"


gameFoundEvent : EventName
gameFoundEvent =
    GameFound "GameFound"


playerJoinedEvent : EventName
playerJoinedEvent =
    PlayerJoined "PlayerJoined"


playerQuitEvent : EventName
playerQuitEvent =
    PlayerQuit "PlayerQuit"


roundStartedEvent : EventName
roundStartedEvent =
    RoundStarted "RoundStarted"


playerPlayedACardEvent : EventName
playerPlayedACardEvent =
    PlayerPlayedACard "PlayerPlayedACard"


roundScoredEvent : EventName
roundScoredEvent =
    RoundScored "RoundScored"


gameEndedEvent : EventName
gameEndedEvent =
    GameEnded "GameEnded"



-- ERROR EVENT NAMES


socketError : EventName
socketError =
    SocketError "SocketError"


gameError : EventName
gameError =
    GameError "GameError"



-- QUERY EVENT NAMES


findGameQuery : EventName
findGameQuery =
    FindGame "FindGame"



-- COMMAND EVENT NAMES


startGameCommand : EventName
startGameCommand =
    StartGame "StartGame"


startRoundCommand : EventName
startRoundCommand =
    StartRound "StartRound"


playACardCommand : EventName
playACardCommand =
    PlayACard "PlayACard"


replayRoundCommand : EventName
replayRoundCommand =
    ReplayRound "ReplayRound"


scoreRoundCommand : EventName
scoreRoundCommand =
    ScoreRound "ScoreRound"


endGameCommand : EventName
endGameCommand =
    EndGame "EndGame"



-- EVENT NAME STRING CONVERSION


getEventName : EventName -> String
getEventName eventName =
    case eventName of
        Connect name ->
            name

        GameStarted name ->
            name

        GameFound name ->
            name

        PlayerJoined name ->
            name

        PlayerQuit name ->
            name

        RoundStarted name ->
            name

        PlayerPlayedACard name ->
            name

        RoundScored name ->
            name

        GameEnded name ->
            name

        SocketError name ->
            name

        GameError name ->
            name

        FindGame name ->
            name

        StartGame name ->
            name

        StartRound name ->
            name

        PlayACard name ->
            name

        ReplayRound name ->
            name

        ScoreRound name ->
            name

        EndGame name ->
            name


eventNameFromString : String -> Maybe EventName
eventNameFromString str =
    case str of
        "Connect" ->
            Just connectEvent

        "GameStarted" ->
            Just gameStartedEvent

        "GameFound" ->
            Just gameFoundEvent

        "PlayerJoined" ->
            Just playerJoinedEvent

        "PlayerQuit" ->
            Just playerQuitEvent

        "RoundStarted" ->
            Just roundStartedEvent

        "PlayerPlayedACard" ->
            Just playerPlayedACardEvent

        "RoundScored" ->
            Just roundScoredEvent

        "GameEnded" ->
            Just gameEndedEvent

        "SocketError" ->
            Just socketError

        "GameError" ->
            Just gameError

        "FindGame" ->
            Just findGameQuery

        "StartGame" ->
            Just startGameCommand

        "StartRound" ->
            Just startRoundCommand

        "PlayACard" ->
            Just playACardCommand

        "ReplayRound" ->
            Just replayRoundCommand

        "ScoreRound" ->
            Just scoreRoundCommand

        "EndGame" ->
            Just endGameCommand

        _ ->
            Nothing



-- GAME MODELS


type alias Player =
    { name : String
    , hand : List PlayingCard
    }


type alias Round =
    { storyName : String
    , pointValue : String
    }


type alias PlayingCard =
    { faceValue : FaceValue
    , isFaceDown : Bool
    }


type alias PlayerCard =
    { player : Player
    , playingCard : PlayingCard
    }



-- GAME EVENTS


type alias ConnectEvent =
    { clientID : String
    , eventName : String
    , event : String
    }


type alias GameStartedEvent =
    { gameID : String
    , gameToken : String
    , gameMasterName : String
    }


type alias GameFoundEvent =
    { gameID : String
    , playerName : String
    , gameMasterName : String
    , playerNames : List String
    , lobbyPlayerNames : List String
    , hand : List String
    , playerCards : List String
    }


type alias PlayerJoinedEvent =
    { gameID : String
    , playerName : String
    , isInLobby : Bool
    }


type alias PlayerQuitEvent =
    { gameID : String
    , playerName : String
    }


type alias RoundStartedEvent =
    { gameID : String
    , storyName : String
    , playerNames : List String
    , lobbyPlayerNames : List String
    , hand : List String
    }


type alias PlayerPlayedACardEvent =
    { gameID : String
    , playerName : String
    , hand : List String
    , playerCards : List String
    }


type alias RoundScoredEvent =
    { gameID : String
    , faceValue : String
    }


type alias GameEndedEvent =
    { gameID : String
    , scoreboard : List String
    }



-- ERROR EVENTS


type alias SocketErrorEvent =
    { failedEventName : String
    , errorMessage : String
    }


type alias GameErrorEvent =
    { gameID : String
    , failedEventName : String
    , errorMessage : String
    }



-- GAME QUERY EVENTS


type alias FindGameQuery =
    { playerName : String
    , gameToken : String
    }



-- GAME COMMAND EVENTS


type alias StartGameCommand =
    { gameMasterName : String
    , pointScale : PointScale
    }


type alias StartRoundCommand =
    { gameID : String
    , storyName : String
    }


type alias PlayACardCommand =
    { gameID : String
    , playerName : String
    , faceValue : FaceValue
    }


type alias ReplayRoundCommand =
    { gameID : String
    , storyName : String
    }


type alias ScoreRoundCommand =
    { gameID : String
    , faceValue : FaceValue
    }


type alias EndGameCommand =
    { gameID : String }



-- CONVENIENCE INITIALIZERS


makePlayerHand : List String -> List PlayingCard
makePlayerHand cardNames =
    List.map (\name -> makePlayingCardWithCardName name) cardNames


makePlayerCards : List String -> List PlayerCard
makePlayerCards list =
    List.map (\components -> playerCardFromComponents components) list


makePlayerWithName : String -> Player
makePlayerWithName name =
    Player name []


makePlayingCardWithCardName : String -> PlayingCard
makePlayingCardWithCardName cardName =
    PlayingCard (faceValueFromString cardName) False


playerCardFromComponents : String -> PlayerCard
playerCardFromComponents str =
    let
        components =
            String.split "," str
    in
    case components of
        a :: b :: c :: _ ->
            makePlayerCardWithPlayerNameAndFaceValue a (faceValueFromString b) (parseBoolString c)

        _ ->
            PlayerCard (makePlayerWithName "Unknown") (makePlayingCardWithCardName "skip")


makePlayerCardWithPlayerNameAndFaceValue : String -> FaceValue -> Bool -> PlayerCard
makePlayerCardWithPlayerNameAndFaceValue playerName faceValue isFaceDown =
    let
        player =
            makePlayerWithName playerName

        card =
            PlayingCard faceValue isFaceDown
    in
    PlayerCard player card


makeScoredRound : String -> Round
makeScoredRound str =
    let
        components =
            String.split "," str
    in
    case components of
        a :: b :: _ ->
            Round a b

        _ ->
            Round "Unknown" "0"


makeScoreboard : List String -> List Round
makeScoreboard scoreboard =
    List.map makeScoredRound scoreboard



-- GAME HELPER FUNCTIONS


updatedPlayers : PlayerJoinedEvent -> List String -> List String
updatedPlayers event players =
    if not event.isInLobby then
        players ++ [ event.playerName ]

    else
        players


updatedLobbyPlayers : PlayerJoinedEvent -> List String -> List String
updatedLobbyPlayers event lobbyPlayers =
    if event.isInLobby then
        lobbyPlayers ++ [ event.playerName ]

    else
        lobbyPlayers


playerHasPlayedACard : String -> List PlayerCard -> Bool
playerHasPlayedACard playerName playerCards =
    let
        playerNames =
            List.map (\card -> card.player.name) playerCards
    in
    List.any (\name -> name == playerName) playerNames


removeCardFromHand : FaceValue -> List PlayingCard -> List PlayingCard
removeCardFromHand cardToRemove hand =
    List.filter (\card -> card.faceValue /= cardToRemove) hand


parseBoolString : String -> Bool
parseBoolString str =
    case str of
        "true" ->
            True

        _ ->
            False


boolToString : Bool -> String
boolToString value =
    if value then
        "true"

    else
        "false"


pluralized : String -> String -> String
pluralized intString str =
    let
        intValue =
            Maybe.withDefault 0 (String.toInt intString)
    in
    if intValue == 1 then
        intString ++ " " ++ str

    else
        intString ++ " " ++ str ++ "s"
