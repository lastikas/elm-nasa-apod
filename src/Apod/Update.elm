module Apod.Update exposing (update)

import Apod.Model exposing (Model, MediaType(..), decodePicOfDay)
import Apod.Messages exposing (Msg(..))
import Apod.DateHelper exposing (formatToYMD)
import WebData.Http
import WebData exposing (WebData(..))


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
        fetch date =
            ( { model | apod = Loading }, getApod date )
    in
        case msg of
            FetchApod date ->
                fetch (formatToYMD date)

            HandleApod webData ->
                { model | apod = webData } ! [ Cmd.none ]

            Reload ->
                fetch ""


getApod : String -> Cmd Msg
getApod date =
    WebData.Http.getWithCache
        (apodEndpoint ++ date)
        HandleApod
        decodePicOfDay
