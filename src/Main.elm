module Main exposing (..)

import Apod.Model exposing (Model)
import Html exposing (programWithFlags)
import Apod.Update exposing (update)
import Apod.View exposing (view)
import Apod.Messages exposing (Msg(..))
import Apod.Subscriptions exposing (subscriptions)
import Apod.DateHelper exposing (dateFromString)


main : Program String Model Msg
main =
    programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }


initialModel : Model
initialModel =
    { error = False
    , picOfDay = Nothing
    }


init : String -> ( Model, Cmd Msg )
init initDate =
    update (GetPicFromDay (dateFromString initDate)) initialModel
