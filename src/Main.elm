module Main exposing (..)

import Apod.Model exposing (PicOfDay, emptyPic)
import Html exposing (programWithFlags)
import Apod.Update exposing (update, getPicOfDay)
import Apod.View exposing (view)
import Apod.Messages exposing (Msg(..))
import Apod.Subscriptions exposing (subscriptions)
import Apod.DateHelper exposing (dateFromString)


main : Program String PicOfDay Msg
main =
    programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }


init : String -> ( PicOfDay, Cmd Msg )
init initDate =
    update (GetPicFromDay (dateFromString initDate)) emptyPic
