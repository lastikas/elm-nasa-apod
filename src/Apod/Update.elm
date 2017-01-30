module Apod.Update exposing (update)

import Apod.Model exposing (Model, MediaType(..), decodePicOfDay)
import Apod.Messages exposing (Msg(..))
import Apod.DateHelper exposing (formatToYMD)
import Http


{-| get your apiKey at https://api.nasa.gov/index.html#apply-for-an-api-key
    TODO: is there any way to use a config file for this?

    DEMO_KEY limits:
    Hourly Limit: 30 requests per IP address per hour
    Daily Limit: 50 requests per IP address per day
    see: https://api.nasa.gov/api.html#demo_key-rate-limits
-}
apiKey : String
apiKey =
    "DEMO_KEY"


apodEndpoint : String
apodEndpoint =
    "https://api.nasa.gov/planetary/apod?api_key=" ++ apiKey ++ "&date="


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewPicOfDay (Ok picOfDay) ->
            ( { model
                | picOfDay = Just picOfDay
                , error = False
              }
            , Cmd.none
            )

        NewPicOfDay (Err _) ->
            ( { model
                | picOfDay = Nothing
                , error = True
              }
            , Cmd.none
            )

        GetPicFromDay date ->
            ( { model
                | picOfDay = Nothing
                , error = False
              }
            , getPicOfDay (formatToYMD date)
            )


getPicOfDay : String -> Cmd Msg
getPicOfDay date =
    Http.send NewPicOfDay (Http.get (apodEndpoint ++ date) decodePicOfDay)
