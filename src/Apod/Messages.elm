module Apod.Messages exposing (Msg(..))

import Http
import Apod.Model exposing (PicOfDay)
import Date


type Msg
    = NewPicOfDay (Result Http.Error PicOfDay)
    | GetPicFromDay Date.Date
    | Reload
