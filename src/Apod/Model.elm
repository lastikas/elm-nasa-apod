module Apod.Model exposing (PicOfDay, MediaType(..), emptyPic, decodePicOfDay)

import Json.Decode as Decode
import Date
import Apod.DateHelper exposing (dateFromString)


{-| TODO: this is not a good model
    maybe change date to Maybe Date.Date
    so we don't have to fallback to the Apod.DateHelper.apodDateLimit

    maybe PicOfDay should be a Maybe PicOfDay in another model
    this way whenever we are loading a new pic or some error has occurred
    the view can decide what to show
-}
type alias PicOfDay =
    { copyright : Maybe String
    , date : Date.Date
    , explanation : String
    , hdurl : Maybe String
    , media_type : MediaType
    , service_version : String
    , title : String
    , url : String
    }


type MediaType
    = Image
    | Video


{-| TODO: do not use emptyPic
    this shows some bullshit data before the first update is complete
    come up with a better model!!!
-}
emptyPic : PicOfDay
emptyPic =
    PicOfDay Nothing (Date.fromTime 0) "" Nothing Image "" "" ""


decodeMediaType : String -> Decode.Decoder MediaType
decodeMediaType mediaType =
    if mediaType == "image" then
        Decode.succeed Image
    else
        Decode.succeed Video


decodeDate : String -> Decode.Decoder Date.Date
decodeDate dateString =
    Decode.succeed (dateFromString dateString)


decodePicOfDay : Decode.Decoder PicOfDay
decodePicOfDay =
    Decode.map8 PicOfDay
        (Decode.maybe (Decode.field "copyright" Decode.string))
        (Decode.field "date" Decode.string |> Decode.andThen decodeDate)
        (Decode.field "explanation" Decode.string)
        (Decode.maybe (Decode.field "hdurl" Decode.string))
        (Decode.field "media_type" Decode.string |> Decode.andThen decodeMediaType)
        (Decode.field "service_version" Decode.string)
        (Decode.field "title" Decode.string)
        (Decode.field "url" Decode.string)
