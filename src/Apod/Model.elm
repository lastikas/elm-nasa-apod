module Apod.Model exposing (Model, PicOfDay, MediaType(..), Status(..), decodePicOfDay)

import Json.Decode as Decode
import Date
import Apod.DateHelper exposing (dateFromString)


{-| TODO: date should be a Maybe Date.Date
    DateHelper.dateFromString could fail when parsing,
    instead of returning some crazy date the user didn't asked for
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


{-| TODO: study other ways of dealing with errors
-}
type alias Model =
    { picOfDay : Maybe PicOfDay
    , status : Status
    }


type MediaType
    = Image
    | Video


type Status
    = Loading
    | Loaded
    | Error


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
