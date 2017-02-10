module Apod.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Apod.Model exposing (Model, PicOfDay, MediaType(..))
import Apod.Messages exposing (Msg(..))
import WebData exposing (WebData(..))
import DatePicker
import Apod.DateHelper exposing (dayBefore, dayAfter, formatToYMD, isDisabled)
import Date


attrData : String -> String -> Attribute msg
attrData name value =
    attribute ("data-" ++ name) value


view : Model -> Html Msg
view model =
    div [ class "page-container" ]
        [ navbarHeader
        , div [ class "container" ]
            [ div
                [ class ("row row-offcanvas row-offcanvas-left" ++ (sidebarClass model))
                ]
                ([ div
                    [ class "col-xs-6 col-sm-3 sidebar-offcanvas"
                    , id "sidebar"
                    ]
                    [ datePickerView model.datepicker ]
                 ]
                    ++ (imageTextView model)
                )
            ]
        ]


imageTextView : Model -> List (Html Msg)
imageTextView model =
    let
        ( imageView, descriptionView ) =
            case model.apod of
                Loading ->
                    loadingView model

                NotAsked ->
                    loadingView model

                WebData.Failure e ->
                    errorView model

                WebData.Success apod ->
                    picView model apod
    in
        [ div [ class "col-xs-12 col-sm-9" ]
            (imageView ++ descriptionView)
        ]


loadingView : Model -> ( List (Html.Html Msg), List (Html.Html Msg) )
loadingView model =
    let
        leftColumn =
            figure_ model.loadingImageSrc

        rightColumn =
            [ h1_ "Looking for start-stuff"
            , p_ "Traversing the cosmos in search of beauty"
            , p_ "You hang in there. We'll be right back"
            , p_ "The universe has 13.82 billion years. You can spare a few secondsm i'm sure"
            ]
    in
        ( leftColumn, rightColumn )


errorView : Model -> ( List (Html.Html Msg), List (Html.Html Msg) )
errorView model =
    let
        leftColumn =
            figure_ model.errorImageSrc

        rightColumn =
            [ h1_ "The fabric of spacetime ripped apart!"
            , h3_ (formatToYMD model.date)
            , p_ "It seems like the data we were expecting fell into a blackhole and is now trapped beyond the event horizon, inaccessible for all eternity."
            , p_ "Give the Reload button bellow a try and see if that works."
            , p_ "If the error persists, please select another date or try again later"
            , reloadButton
            , div [ class "controls" ]
                [ prevButton model.date model.today
                , nextButton model.date model.today
                ]
            ]
    in
        ( leftColumn, rightColumn )


picView : Model -> PicOfDay -> ( List (Html.Html Msg), List (Html.Html Msg) )
picView model apod =
    let
        leftColumn =
            [ figureCaption apod ]

        rightColumn =
            [ h1_ apod.title
            , h3_ (formatToYMD model.date)
            , p_ apod.explanation
            , hd_button apod.hdurl
            , div [ class "controls" ]
                [ prevButton model.date model.today
                , nextButton model.date model.today
                ]
            ]
    in
        ( leftColumn, rightColumn )


datePickerView : DatePicker.DatePicker -> Html Msg
datePickerView datepicker =
    div [ class "date-picker-holder" ]
        [ h3_ "Pick a Date"
        , DatePicker.view datepicker
            |> Html.map ToDatePicker
        ]


navbarHeader : Html Msg
navbarHeader =
    div [ class "navbar navbar-default navbar-fixed-top", (attribute "role" "navigation") ]
        [ div [ class "container" ]
            [ div [ class "navbar-header" ]
                [ button
                    [ type_ "button"
                    , class "navbar-toggle"
                    , (attrData "toggle" "offcanvas")
                    , (attrData "target" ".sidebar-nav")
                    , onClick ToggleSidebar
                    ]
                    [ span [ class "icon-bar" ]
                        []
                    , span [ class "icon-bar" ]
                        []
                    , span [ class "icon-bar" ]
                        []
                    ]
                , a [ class "navbar-brand", href "#" ]
                    [ text "Elm-Apod" ]
                ]
            ]
        ]


sidebarClass : Model -> String
sidebarClass model =
    if model.sidebarOpen == True then
        " active"
    else
        ""


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


br_ : Html msg
br_ =
    br [] []


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


hd_button : Maybe String -> Html Msg
hd_button hdurl =
    case hdurl of
        Nothing ->
            text ""

        Just url ->
            a
                [ class "btn btn-primary"
                , target "_blank"
                , href url
                ]
                [ span [ class "glyphicon glyphicon-picture" ] []
                , text " see hi-res"
                ]


reloadButton : Html Msg
reloadButton =
    clickableTextIconButton "Reload" (IconLeft "glyphicon glyphicon-refresh") (onClick Reload) False


nextButton : Date.Date -> Date.Date -> Html Msg
nextButton date today =
    let
        tomorrow =
            dayAfter date
    in
        clickableTextIconButton
            "next"
            (IconRight "glyphicon glyphicon-chevron-right")
            (onClick (FetchApod tomorrow))
            (isDisabled today tomorrow)


prevButton : Date.Date -> Date.Date -> Html Msg
prevButton date today =
    let
        yesterday =
            dayBefore date
    in
        clickableTextIconButton
            "prev"
            (IconLeft "glyphicon glyphicon-chevron-left")
            (onClick (FetchApod yesterday))
            (isDisabled today yesterday)


button_ : String -> Maybe String -> Attribute msg -> Html msg
button_ textToShow customClass onClickHandler =
    button
        (onClickHandler
            :: [ type_ "button"
               , class ("btn btn-default " ++ (Maybe.withDefault "" customClass))
               ]
        )
        [ text textToShow ]


type IconPosition
    = IconLeft String
    | IconRight String


clickableTextIconButton : String -> IconPosition -> Attribute Msg -> Bool -> Html Msg
clickableTextIconButton buttonText icon onClickHandler isDisabled =
    let
        btn markup =
            button
                (onClickHandler
                    :: [ type_ "button"
                       , class "btn btn-default"
                       , disabled isDisabled
                       ]
                )
                markup
    in
        case icon of
            IconLeft iconClass ->
                btn [ span [ class iconClass ] [], text (" " ++ buttonText) ]

            IconRight iconClass ->
                btn [ text (buttonText ++ " "), span [ class iconClass ] [] ]


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
