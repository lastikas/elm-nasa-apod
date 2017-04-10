module Apod.Update exposing (update)

import Apod.Model exposing (Model, MediaType(..), decodePicOfDay)
import Apod.Messages exposing (Msg(..))
import Apod.DateHelper exposing (formatToYMD, initDatePicker)
import WebData.Http
import WebData exposing (WebData(..))
import DatePicker exposing (defaultSettings)
import Process
import Time
import Task
import Date


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


apodEndpoint : String -> String
apodEndpoint date =
    "https://api.nasa.gov/planetary/apod?api_key=" ++ apiKey ++ "&date=" ++ date


updateDatePicker : DatePicker.Msg -> Model -> ( Model, Cmd Msg )
updateDatePicker msg model =
    let
        ( newDatePicker, datePickerFx, mDate ) =
            DatePicker.update msg model.datepicker

        ( m, cmd ) =
            case mDate of
                Nothing ->
                    ( model, Cmd.none )

                Just date ->
                    delayFetch date model
    in
        { m | datepicker = newDatePicker }
            ! [ Cmd.map ToDatePicker datePickerFx, cmd ]


delay : Time.Time -> msg -> Cmd msg
delay time msg =
    -- see http://stackoverflow.com/a/40610172
    Process.sleep time
        |> Task.andThen (always <| Task.succeed msg)
        |> Task.perform identity


delayFetch : Date.Date -> Model -> ( Model, Cmd Msg )
delayFetch date model =
    -- delay the fetching just so we can see the loading gif <| terrible, I know. but ¯\_(ツ)_/¯
    { model
        | apod = Loading
        , date = date
    }
        ! [ delay (Time.second * 2) <| FetchApod date ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadApod date ->
            delayFetch date model

        FetchApod date ->
            let
                ( datePicker, datePickerFx ) =
                    initDatePicker (Just date) model.today
            in
                ( { model
                    | apod = Loading
                    , date = date
                    , datepicker = datePicker
                  }
                , fetchApod (formatToYMD date)
                )

        HandleApod webData ->
            { model
                | apod = webData
            }
                ! [ Cmd.none ]

        Reload ->
            delayFetch model.date model

        ToDatePicker msg ->
            updateDatePicker msg model


fetchApod : String -> Cmd Msg
fetchApod date =
    WebData.Http.getWithCache
        (apodEndpoint date)
        HandleApod
        decodePicOfDay
