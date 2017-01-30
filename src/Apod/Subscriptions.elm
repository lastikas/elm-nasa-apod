module Apod.Subscriptions exposing (subscriptions)

import Apod.Model exposing (Model)
import Apod.Messages exposing (Msg)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
