module Model.Theme exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font exposing (Font)



-- FONTS


teko : List Font
teko =
    [ Font.external
        { url = "https://fonts.googleapis.com/css2?family=Teko:wght@500&display=swap"
        , name = "Teko"
        }
    ]



-- COLORS


type alias ThemeColor =
    { alert : Color
    , red : Color
    , blue : Color
    , darkBlue : Color
    , darkCharcoal : Color
    , lightBlue : Color
    , lightGrey : Color
    , white : Color
    , softWhite : Color
    , paleOrange : Color
    , mediumGreen : Color
    , darkGreen : Color
    }


color : ThemeColor
color =
    { alert = rgb255 255 240 180
    , red = rgb255 255 0 0
    , blue = rgb255 114 159 207
    , darkBlue = rgb255 7 44 133
    , darkCharcoal = rgb255 46 52 54
    , lightBlue = rgb255 197 232 247
    , lightGrey = rgb255 224 224 224
    , white = rgb255 255 255 255
    , softWhite = rgb255 220 220 220
    , paleOrange = rgb255 236 158 68
    , mediumGreen = rgb255 0 100 50
    , darkGreen = rgb255 0 80 40
    }



-- EDGES


type alias Edges number =
    { top : number
    , right : number
    , bottom : number
    , left : number
    }


edges : Edges number
edges =
    { top = 0
    , right = 0
    , bottom = 0
    , left = 0
    }



-- ELEMENT STYLES


primaryButtonStyle : List (Attribute msg)
primaryButtonStyle =
    adjustableButtonStyle 80 18


smallButtonStyle : List (Attribute msg)
smallButtonStyle =
    adjustableButtonStyle 30 12


adjustableButtonStyle : Int -> Int -> List (Attribute msg)
adjustableButtonStyle paddingX paddingY =
    [ paddingXY paddingX paddingY
    , Border.rounded 12
    , Background.color color.darkBlue
    , Font.color color.white
    , mouseDown
        [ Background.color color.blue
        , Font.color color.darkBlue
        ]
    , mouseOver
        [ Background.color color.softWhite
        , Font.color color.darkBlue
        ]
    ]



-- SHARED ELEMENTS


planningGameIconImage : Element msg
planningGameIconImage =
    image
        [ width (px 46) ]
        { src = "/images/favicon-32x32.png"
        , description = "PLanning Game Logo Image"
        }


headingText : String -> Element msg
headingText txt =
    el
        [ Font.color color.darkBlue
        , Font.size 52
        ]
        (text txt)


subheadingText : String -> Int -> Element msg
subheadingText txt size =
    el
        [ Font.color color.darkBlue
        , Font.size size
        ]
        (text txt)
