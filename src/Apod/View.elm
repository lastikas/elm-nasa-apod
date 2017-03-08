module Apod.View exposing (view)

import Apod.Model exposing (Model, PicOfDay, MediaType(..))
import Apod.Messages exposing (Msg(..))
import Apod.DateHelper exposing (dayBefore, dayAfter, formatToYMD, isDisabled)
import Html exposing (..)
import Html.Attributes exposing (..)
import WebData exposing (WebData(..))
import Html.Events exposing (..)
import Date
import DatePicker


-- views


view : Model -> Html Msg
view model =
    div []
        [ nav_ model
        , div [ class "container-fluid" ]
            [ contentView model ]
        ]


contentView : Model -> Html Msg
contentView model =
    case model.apod of
        WebData.Success apod ->
            apodView apod

        WebData.Failure _ ->
            errorView model

        _ ->
            loadingView model


apodView : PicOfDay -> Html Msg
apodView picOfDay =
    let
        formatedDate =
            formatToYMD picOfDay.date
    in
        twoColumnView [ apodFigure picOfDay ]
            [ h1 [] [ text picOfDay.title ]
            , time [ datetime formatedDate ] [ text formatedDate ]
            , p [] [ text picOfDay.explanation ]
            , hd_button picOfDay.hdurl
            ]


errorView : Model -> Html Msg
errorView model =
    let
        formatedDate =
            formatToYMD model.date

        header =
            [ h1 [] [ text "The fabric of spacetime ripped apart!" ] ]

        time_ =
            [ time [ datetime formatedDate ] [ text formatedDate ] ]

        ps =
            paragraphs
                [ "It seems like the data we were expecting fell into a blackhole and is now trapped beyond the event horizon, inaccessible for all eternity."
                , "Give the Reload button bellow a try and see if that works."
                , "If the error persists, please select another date or try again later"
                ]

        reload =
            [ reloadButton model ]
    in
        twoColumnView [ figure_ Image model.errorImageSrc Nothing ] (List.concat [ header, time_, ps, reload ])


loadingView : Model -> Html Msg
loadingView model =
    let
        header =
            [ h1 [] [ text "Looking for start-stuff" ] ]

        ps =
            paragraphs
                [ "Traversing the cosmos in search of beauty."
                , "You hang in there. We'll be right back."
                , "The universe is 13.82 billion years old."
                , "You can spare a few seconds, I'm sure."
                ]
    in
        twoColumnView [ figure_ Spinner model.loadingImageSrc Nothing ] (List.append header ps)


datePickerView : DatePicker.DatePicker -> Html Msg
datePickerView datepicker =
    div [ class "date-picker-holder" ]
        [ DatePicker.view datepicker
            |> Html.map ToDatePicker
        ]


twoColumnView : List (Html Msg) -> List (Html Msg) -> Html Msg
twoColumnView columnLeft columnRight =
    div [ class "row" ]
        [ div [ class "col-xs-12 col-lg-7 col-md-8" ]
            columnLeft
        , div [ class "col-xs-12 col-lg-5 col-md-4" ]
            columnRight
        ]



-- navigation


nav_ : Model -> Html Msg
nav_ model =
    nav [ class "navbar navbar-default navbar-fixed-top" ]
        [ div [ class "container-fluid" ]
            [ div [ class "navbar-header" ]
                [ brand
                , controls model
                , pickDateButton model
                ]
            ]
        ]


brand : Html msg
brand =
    span [ class "navbar-brand", href "#" ] [ text "APOD" ]


pickDateButton : Model -> Html Msg
pickDateButton model =
    div [ class "navbar-form navbar-left" ]
        [ div [ class "form-group" ]
            [ div [ class "input-group" ]
                [ span [ class "input-group-btn" ]
                    [ button [ class "btn btn-default glyphicon glyphicon-calendar", type_ "button" ]
                        []
                    ]
                , datePickerView model.datepicker
                ]
            ]
        ]


controls : Model -> Html Msg
controls model =
    div [ class "nav-controls" ]
        [ fetchPrevButton model
        , fetchNextButton model
        ]



-- media


apodFigure : PicOfDay -> Html Msg
apodFigure { media_type, url, copyright } =
    figure_ media_type url copyright


figure_ : MediaType -> String -> Maybe String -> Html Msg
figure_ media_type url copyright =
    let
        m =
            [ (media media_type url) ]

        c =
            case copyright of
                Nothing ->
                    []

                Just _ ->
                    [ (figcaption [] [ text <| copyright_ copyright ]) ]
    in
        figure [] (List.append m c)


copyright_ : Maybe String -> String
copyright_ copyright =
    "copyright: " ++ (Maybe.withDefault "public domain" copyright)


media : MediaType -> String -> Html Msg
media mediaType mediaUrl =
    case mediaType of
        Image ->
            responsiveImg [ "img-thumbnail" ] mediaUrl

        Video ->
            responsiveEmbed16by9 mediaUrl

        Spinner ->
            responsiveImg [ "loading-image" ] mediaUrl


responsiveImg : List String -> String -> Html msg
responsiveImg classes source =
    let
        classes_ =
            "img-responsive center-block "
                ++ (List.foldl (++) "" classes)
    in
        img [ src source, class classes_ ] []


responsiveEmbed16by9 : String -> Html msg
responsiveEmbed16by9 source =
    let
        responsiveEmbed =
            class "embed-responsive embed-responsive-16by9"

        responsiveItem =
            class "embed-responsive-item"
    in
        div [ responsiveEmbed ]
            [ iframe [ responsiveItem, src source ] [] ]



-- buttons


fetchPrevButton : Model -> Html Msg
fetchPrevButton =
    fetchButton
        dayBefore
        (iconLeft "Prev" "glyphicon-chevron-left")


fetchNextButton : Model -> Html Msg
fetchNextButton =
    fetchButton
        dayAfter
        (iconRight "Next" "glyphicon-chevron-right")


reloadButton : Model -> Html Msg
reloadButton model =
    actionButton model.date (iconLeft "Reload" "glyphicon-refresh") Reload model


fetchButton : (Date.Date -> Date.Date) -> List (Html Msg) -> Model -> Html Msg
fetchButton transformDate markup model =
    let
        newDate =
            transformDate model.date
    in
        actionButton newDate markup (LoadApod newDate) model


actionButton : Date.Date -> List (Html Msg) -> Msg -> Model -> Html Msg
actionButton date markup msg model =
    let
        dizabled =
            isDisabled model.today date
    in
        button
            [ type_ "button"
            , class "btn btn-primary navbar-btn"
            , onClick msg
            , disabled dizabled
            ]
            markup


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
                (iconLeft "see hi-res" "glyphicon-picture")



-- icons


iconRight : String -> String -> List (Html msg)
iconRight btnText iconClass =
    [ text <| btnText ++ " "
    , span [ class <| "glyphicon " ++ iconClass ] []
    ]


iconLeft : String -> String -> List (Html msg)
iconLeft btnText iconClass =
    [ span [ class <| "glyphicon " ++ iconClass ] []
    , text <| " " ++ btnText
    ]



-- helpers


paragraphs : List String -> List (Html.Html Msg)
paragraphs texts =
    List.map (\t -> p [] [ text t ]) texts


attrData : String -> String -> Attribute msg
attrData name value =
    attribute ("data-" ++ name) value
