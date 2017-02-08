module Apod.Messages exposing (Msg(..))

import Apod.Model exposing (PicOfDay)
import Date
import WebData exposing (WebData(..))


type Msg
    = FetchApod Date.Date
    | HandleApod (WebData PicOfDay)
    | Reload
