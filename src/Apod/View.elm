module Apod.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (src, type_, class, style)
import Html.Events exposing (onClick, on)
import Apod.Model exposing (Model, PicOfDay, MediaType(..))
import Apod.Messages exposing (Msg(..))
import Apod.DateHelper exposing (dayBefore, dayAfter, formatToYMD)
import Date


{-| TODO: study better ways to deal with exceptions
    not feeling good about this
-}
view : Model -> Html Msg
view model =
    if model.error == True then
        errorView
    else
        case model.picOfDay of
            Nothing ->
                loadingView

            Just picOfDay ->
                picView picOfDay


{-| TODO: create loading view
-}
loadingView : Html Msg
loadingView =
    div [] [ text "loading..." ]


{-| TODO: create error view
-}
errorView : Html Msg
errorView =
    div [] [ text "error" ]


picView : PicOfDay -> Html Msg
picView model =
    let
        xs12md6 =
            class "col-xs-12 col-md-6"

        row =
            class "row"
    in
        div [ row ]
            [ div [ xs12md6 ] [ mediaFigure model ]
            , div [ xs12md6 ]
                [ h1 [] [ text model.title ]
                , h3 [] [ text (formatToYMD model.date) ]
                , p [] [ text model.explanation ]
                , prevButton model.date
                , nextButton model.date
                ]
            ]


nextButton : Date.Date -> Html Msg
nextButton =
    newPicButton "next" dayAfter


prevButton : Date.Date -> Html Msg
prevButton =
    newPicButton "prev" dayBefore


newPicButton : String -> (Date.Date -> Date.Date) -> Date.Date -> Html Msg
newPicButton buttonText transformDate date =
    button
        [ type_ "button"
        , class "btn btn-default"
        , onClick (GetPicFromDay (transformDate date))
        ]
        [ text buttonText ]


mediaFigure : PicOfDay -> Html Msg
mediaFigure model =
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
            img
                [ src mediaUrl
                , class "img-responsive center-block img-thumbnail"
                ]
                []

        Video ->
            let
                responsiveEmbed =
                    class "embed-responsive embed-responsive-16by9"

                responsiveItem =
                    class "embed-responsive-item"
            in
                div [ responsiveEmbed ]
                    [ iframe [ responsiveItem, src mediaUrl ] [] ]
