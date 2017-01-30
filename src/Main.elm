module Main exposing (..)

import Apod.Model exposing (Model, Status(..))
import Html exposing (programWithFlags)
import Apod.Update exposing (update)
import Apod.View exposing (view)
import Apod.Messages exposing (Msg(..))
import Apod.Subscriptions exposing (subscriptions)
import Apod.DateHelper exposing (dateFromString)


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
    { picOfDay = Nothing
    , status = Loading
    , loadingImageSrc = ""
    , errorImageSrc = ""
    }


type alias Options =
    { initialDate : String
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
    in
        update (GetPicFromDay (dateFromString options.initialDate)) m
