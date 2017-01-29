module Apod.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (src, type_, class, style)
import Html.Events exposing (onClick, on)
import Apod.Model exposing (PicOfDay, MediaType(..))
import Apod.Messages exposing (Msg(..))
import Apod.DateHelper exposing (dayBefore, dayAfter)


view : PicOfDay -> Html Msg
view model =
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
                , h3 [] [ text model.date ]
                , p [] [ text model.explanation ]
                , prevButton model.date
                , nextButton model.date
                ]
            ]


nextButton : String -> Html Msg
nextButton =
    newPicButton "next" dayAfter


prevButton : String -> Html Msg
prevButton =
    newPicButton "prev" dayBefore


newPicButton : String -> (String -> String) -> String -> Html Msg
newPicButton buttonText transformDate date =
    button
        [ type_ "button"
        , class "btn btn-default"
        , onClick (GetPicFromDay (transformDate date))
        ]
        [ text buttonText ]


mediaFigure : PicOfDay -> Html Msg
mediaFigure model =
    figure [ style [ ( "margin-top", "20px" ) ] ]
        [ media model.media_type model.url
        , captionCopyright model.copyright
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


{-| TODO: redo captionCopyright - this is bad code
-}
captionCopyright : Maybe String -> Html msg
captionCopyright copyright =
    let
        captionText =
            case copyright of
                Nothing ->
                    ""

                Just value ->
                    " copyright: " ++ value
    in
        figcaption [] [ text captionText ]
