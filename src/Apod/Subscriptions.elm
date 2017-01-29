module Apod.Subscriptions exposing (subscriptions)

import Apod.Model exposing (PicOfDay)
import Apod.Messages exposing (Msg)


subscriptions : PicOfDay -> Sub Msg
subscriptions model =
    Sub.none
