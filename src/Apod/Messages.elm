module Apod.Messages exposing (Msg(..))

import Http
import Apod.Model exposing (PicOfDay)


type Msg
    = NewPicOfDay (Result Http.Error PicOfDay)
    | GetPicFromDay String
