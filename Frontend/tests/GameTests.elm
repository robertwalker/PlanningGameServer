module GameTests exposing (..)

import Expect
import Model.Game exposing (..)
import Test exposing (..)


initPlayingCard : Test
initPlayingCard =
    describe "Initializing a playing card"
        [ test "should initialize the Question card from card name" <|
            \_ ->
                makePlayingCardWithCardName "question"
                    |> .faceValue
                    |> Expect.equal questionCard
        , test "should initialize the Skip card from card name" <|
            \_ ->
                makePlayingCardWithCardName "skip"
                    |> .faceValue
                    |> Expect.equal skipCard
        , test "should initialize the One card from card name" <|
            \_ ->
                makePlayingCardWithCardName "one"
                    |> .faceValue
                    |> Expect.equal oneCard
        , test "should initialize the Two card from card name" <|
            \_ ->
                makePlayingCardWithCardName "two"
                    |> .faceValue
                    |> Expect.equal twoCard
        , test "should initialize the Three card from card name" <|
            \_ ->
                makePlayingCardWithCardName "three"
                    |> .faceValue
                    |> Expect.equal threeCard
        , test "should initialize the Four card from card name" <|
            \_ ->
                makePlayingCardWithCardName "four"
                    |> .faceValue
                    |> Expect.equal fourCard
        , test "should initialize the Five card from card name" <|
            \_ ->
                makePlayingCardWithCardName "five"
                    |> .faceValue
                    |> Expect.equal fiveCard
        , test "should initialize the Eight card from card name" <|
            \_ ->
                makePlayingCardWithCardName "eight"
                    |> .faceValue
                    |> Expect.equal eightCard
        , test "should default to initializing a Skip card given an invalid name" <|
            \_ ->
                makePlayingCardWithCardName "invallid"
                    |> .faceValue
                    |> Expect.equal skipCard
        ]
