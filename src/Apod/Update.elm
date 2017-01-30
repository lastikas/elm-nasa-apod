module Apod.Update exposing (update)

import Apod.Model exposing (Model, MediaType(..), Status(..), decodePicOfDay)
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
    let
        loadPic date =
            { model
                | picOfDay = Nothing
                , status = Loading
            }
                ! [ getPicOfDay date ]

        picLoaded picOfDay =
            { model
                | picOfDay = Just picOfDay
                , status = Loaded
            }
                ! [ Cmd.none ]

        error =
            { model
                | picOfDay = Nothing
                , status = Error
            }
                ! [ Cmd.none ]
    in
        case msg of
            NewPicOfDay (Ok picOfDay) ->
                picLoaded picOfDay

            NewPicOfDay (Err _) ->
                error

            GetPicFromDay date ->
                loadPic (formatToYMD date)

            Reload ->
                loadPic ""


getPicOfDay : String -> Cmd Msg
getPicOfDay date =
    Http.send NewPicOfDay (Http.get (apodEndpoint ++ date) decodePicOfDay)
