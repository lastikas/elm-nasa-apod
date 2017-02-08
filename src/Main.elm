module Main exposing (..)

import Apod.Model exposing (Model)
import Html exposing (programWithFlags)
import Apod.Update exposing (update)
import Apod.View exposing (view)
import Apod.Messages exposing (Msg(..))
import Apod.Subscriptions exposing (subscriptions)
import WebData exposing (WebData(..))
import Date
import Time


main : Program Options Model Msg
main =
    programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }


initialModel : Model
initialModel =
    { apod = NotAsked
    , loadingImageSrc = ""
    , errorImageSrc = ""
    }


type alias Options =
    { initialDate : Time.Time
    , loadingImageSrc : String
    , errorImageSrc : String
    }


init : Options -> ( Model, Cmd Msg )
init options =
    let
        m =
            { initialModel
                | loadingImageSrc = options.loadingImageSrc
                , errorImageSrc = options.errorImageSrc
            }

        date =
            Date.fromTime options.initialDate
    in
        update (FetchApod date) m
