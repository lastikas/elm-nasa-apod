module Apod.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (src, type_, class, style)
import Html.Events exposing (onClick, on)
import Apod.Model exposing (Model, PicOfDay, MediaType(..), Status(..))
import Apod.Messages exposing (Msg(..))
import Apod.DateHelper exposing (dayBefore, dayAfter, formatToYMD)
import Date


{-| TODO: study better ways to deal with exceptions
    not feeling good about this

    the case inside Loaded is weird
    PicOfDay as a Maybe makes sense, it won't always be there
    but someone is gonna have to deal with it, right?

    if feels like Model.status is the culprit here
-}
view : Model -> Html Msg
view model =
    case model.status of
        Loading ->
            loadingView model.loadingImageSrc

        Loaded ->
            case model.picOfDay of
                Nothing ->
                    errorView model.errorImageSrc

                Just picOfDay ->
                    picView picOfDay

        Error ->
            errorView model.errorImageSrc


loadingView : String -> Html Msg
loadingView loadingImageSrc =
    let
        leftColumn =
            figure_ loadingImageSrc

        rightColumn =
            [ h1_ "Looking for start-stuff"
            , p_ "Traversing the cosmos in search of beauty"
            , p_ "You hang in there. We'll be right back"
            , p_ "The universe has 13.82 billion years. You can spare a few secondsm i'm sure"
            ]
    in
        twoColumnsView leftColumn rightColumn


errorView : String -> Html Msg
errorView errorImageSrc =
    let
        leftColumn =
            figure_ errorImageSrc

        rightColumn =
            [ h1_ "The fabric of spacetime ripped apart!"
            , p_ "It seems like the data we were expecting fell into a blackhole and is now trapped beyond the event horizon, inaccessible for all eternity."
            , p_ "You can try time-travelling to the current day, this way avoiding the collision with the blackhole before it even happened (yay)"
            , p_ "Give the Reload button bellow a try and see if that works."
            , button_ "Reload" (onClick Reload)
            ]
    in
        twoColumnsView leftColumn rightColumn


picView : PicOfDay -> Html Msg
picView model =
    let
        leftColumn =
            [ figureCaption model ]

        rightColumn =
            [ h1_ model.title
            , h3_ (formatToYMD model.date)
            , p_ model.explanation
            , prevButton model.date
            , nextButton model.date
            ]
    in
        twoColumnsView leftColumn rightColumn


twoColumnsView : List (Html.Html Msg) -> List (Html.Html Msg) -> Html Msg
twoColumnsView leftColumn rightColumn =
    div [ row ]
        [ div [ xs12md6 ] leftColumn
        , div [ xs12md6 ] rightColumn
        ]


nextButton : Date.Date -> Html Msg
nextButton =
    newPicButton "next" dayAfter


prevButton : Date.Date -> Html Msg
prevButton =
    newPicButton "prev" dayBefore


newPicButton : String -> (Date.Date -> Date.Date) -> Date.Date -> Html Msg
newPicButton buttonText transformDate date =
    button_ buttonText
        (onClick (GetPicFromDay (transformDate date)))


figureCaption : PicOfDay -> Html Msg
figureCaption model =
    let
        copyrightLabel =
            "copyright:"

        publicDomain =
            "public domain"

        figureStyle =
            [ ( "margin-top", "20px" ) ]
    in
        figure [ style figureStyle ]
            [ media model.media_type model.url
            , figcaption []
                [ text
                    (copyrightLabel
                        ++ (Maybe.withDefault publicDomain model.copyright)
                    )
                ]
            ]


media : MediaType -> String -> Html Msg
media mediaType mediaUrl =
    case mediaType of
        Image ->
            responsiveImg mediaUrl

        Video ->
            responsiveEmbed16by9 mediaUrl


h1_ : String -> Html msg
h1_ textToShow =
    h1 [] [ text textToShow ]


h3_ : String -> Html msg
h3_ textToShow =
    h3 [] [ text textToShow ]


p_ : String -> Html msg
p_ textToShow =
    p [] [ text textToShow ]


figure_ : String -> List (Html msg)
figure_ imageSrc =
    [ figure [ style [ ( "margin-top", "20px" ) ] ]
        [ responsiveImg imageSrc ]
    ]


button_ : String -> Attribute msg -> Html msg
button_ textToShow onClickHandler =
    button
        (onClickHandler
            :: [ type_ "button"
               , class "btn btn-default"
               ]
        )
        [ text textToShow ]


responsiveImg : String -> Html msg
responsiveImg imgSrc =
    img
        [ src imgSrc
        , class "img-responsive center-block img-thumbnail"
        ]
        []


responsiveEmbed16by9 : String -> Html msg
responsiveEmbed16by9 embedSrc =
    let
        responsiveEmbed =
            class "embed-responsive embed-responsive-16by9"

        responsiveItem =
            class "embed-responsive-item"
    in
        div [ responsiveEmbed ]
            [ iframe [ responsiveItem, src embedSrc ] [] ]


xs12md6 : Attribute msg
xs12md6 =
    class "col-xs-12 col-md-6"


row : Attribute msg
row =
    class "row"
