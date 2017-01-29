module Apod.Update exposing (update, getPicOfDay)

import Apod.Model exposing (PicOfDay, MediaType(..), decodePicOfDay)
import Apod.Messages exposing (Msg(..))
import Http


{-| get your api_key at https://api.nasa.gov/index.html#apply-for-an-api-key
    TODO: is there any way to use a config file for this?
-}
api_key : String
api_key =
    "DEMO_KEY"


apod_endpoint : String
apod_endpoint =
    "https://api.nasa.gov/planetary/apod?api_key=" ++ api_key ++ "&date="


update : Msg -> PicOfDay -> ( PicOfDay, Cmd Msg )
update msg model =
    case msg of
        NewPicOfDay (Ok picOfDay) ->
            ( picOfDay, Cmd.none )

        NewPicOfDay (Err _) ->
            ( model, Cmd.none )

        GetPicFromDay date ->
            ( model, getPicOfDay date )


getPicOfDay : String -> Cmd Msg
getPicOfDay date =
    Http.send NewPicOfDay (Http.get (apod_endpoint ++ date) decodePicOfDay)
