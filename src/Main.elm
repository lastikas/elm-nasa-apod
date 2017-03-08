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
import Apod.DateHelper exposing (initDatePicker)


main : Program Options Model Msg
main =
    programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }


type alias Options =
    { initialDate : Time.Time
    , loadingImageSrc : String
    , errorImageSrc : String
    }


init : Options -> ( Model, Cmd Msg )
init options =
    let
        initialDate =
            Date.fromTime options.initialDate

        ( datePicker, datePickerFx ) =
            initDatePicker (Just initialDate) initialDate

        initialModel =
            Model NotAsked datePicker initialDate initialDate options.loadingImageSrc options.errorImageSrc
    in
        update (LoadApod initialDate) initialModel
