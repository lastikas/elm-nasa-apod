module Apod.Model exposing (Model, PicOfDay, MediaType(..), decodePicOfDay)

import Json.Decode as Decode
import Date
import Apod.DateHelper exposing (dateFromString)
import WebData exposing (WebData(..))
import DatePicker exposing (defaultSettings)


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


type alias Model =
    { apod : WebData PicOfDay
    , datepicker : DatePicker.DatePicker
    , date : Date.Date
    , today : Date.Date
    , sidebarOpen : Bool
    , loadingImageSrc : String
    , errorImageSrc : String
    }


type MediaType
    = Image
    | Video


decodeMediaType : String -> Decode.Decoder MediaType
decodeMediaType mediaType =
    if mediaType == "image" then
        Decode.succeed Image
    else
        Decode.succeed Video


decodeDate : String -> Decode.Decoder Date.Date
decodeDate dateString =
    let
        dateResult =
            dateFromString dateString
    in
        case dateResult of
            Ok date ->
                Decode.succeed date

            Err error ->
                Decode.fail error


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
