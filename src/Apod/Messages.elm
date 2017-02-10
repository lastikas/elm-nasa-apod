module Apod.Messages exposing (Msg(..))

import Apod.Model exposing (PicOfDay)
import Date
import WebData exposing (WebData(..))
import DatePicker


type Msg
    = FetchApod Date.Date
    | HandleApod (WebData PicOfDay)
    | Reload
    | ToDatePicker DatePicker.Msg
    | ToggleSidebar
