module Apod.Update exposing (update)

import Apod.Model exposing (Model, MediaType(..), decodePicOfDay)
import Apod.Messages exposing (Msg(..))
import Apod.DateHelper exposing (formatToYMD, initDatePicker)
import WebData.Http
import WebData exposing (WebData(..))
import DatePicker exposing (defaultSettings)


{-| get your apiKey at https://api.nasa.gov/index.html#apply-for-an-api-key
    TODO: is there any way to use a config file for this?

    DEMO_KEY limits:
    Hourly Limit: 30 requests per IP address per hour
    Daily Limit: 50 requests per IP address per day
    see: https://api.nasa.gov/api.html#demo_key-rate-limits
-}
apiKey : String
apiKey =
    "SegrXvHUjcfYVpMck51MH02BiF0e8vcCaBxx7JTn"


apodEndpoint : String
apodEndpoint =
    "https://api.nasa.gov/planetary/apod?api_key=" ++ apiKey ++ "&date="


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
                    ( { model
                        | apod = Loading
                        , date = date
                      }
                    , fetchApod (formatToYMD date)
                    )
    in
        { m | datepicker = newDatePicker }
            ! [ Cmd.map ToDatePicker datePickerFx, cmd ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
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
                , sidebarOpen = False
            }
                ! [ Cmd.none ]

        Reload ->
            ( { model
                | sidebarOpen = False
              }
            , fetchApod (formatToYMD model.date)
            )

        ToDatePicker msg ->
            updateDatePicker msg model

        ToggleSidebar ->
            { model
                | sidebarOpen = not model.sidebarOpen
            }
                ! [ Cmd.none ]


fetchApod : String -> Cmd Msg
fetchApod date =
    WebData.Http.getWithCache
        (apodEndpoint ++ date)
        HandleApod
        decodePicOfDay
