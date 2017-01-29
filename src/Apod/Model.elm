module Apod.Model exposing (PicOfDay, MediaType(..), emptyPic, decodePicOfDay)

import Json.Decode as Decode


type alias PicOfDay =
    { copyright : Maybe String
    , date : String
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


emptyPic : PicOfDay
emptyPic =
    PicOfDay Nothing "" "" Nothing Image "" "" ""


decodeMediaType : String -> Decode.Decoder MediaType
decodeMediaType mediaType =
    if mediaType == "image" then
        Decode.succeed Image
    else
        Decode.succeed Video


decodePicOfDay : Decode.Decoder PicOfDay
decodePicOfDay =
    Decode.map8 PicOfDay
        (Decode.maybe (Decode.field "copyright" Decode.string))
        (Decode.field "date" Decode.string)
        (Decode.field "explanation" Decode.string)
        (Decode.maybe (Decode.field "hdurl" Decode.string))
        (Decode.field "media_type" Decode.string |> Decode.andThen decodeMediaType)
        (Decode.field "service_version" Decode.string)
        (Decode.field "title" Decode.string)
        (Decode.field "url" Decode.string)



-- PicOfDay
--     Nothing
--     "2017-01-28"
--     "Over 150 light-years across, this cosmic maelstrom of gas and dust is not too far away. It lies south of the Tarantula Nebula in our satellite galaxy the Large Magellanic Cloud a mere 180,000 light-years distant. Massive stars have formed within. Their energetic radiation and powerful stellar  winds sculpt the gas and dust and power the glow of this HII region, entered into the Henize catalog of emission stars and nebulae in the Magellanic Clouds as N159. The bright, compact, butterfly-shaped nebula above and left of center likely contains massive stars in a very early stage of formation. Resolved for the first time in Hubble images, the compact blob of ionized gas has come to be known as the Papillon Nebula. Participate: Take an Aesthetics & Astronomy Survey"
--     Nothing
--     Image
--     "v1"
--     "N159 in the Large Magellanic Cloud"
--     "http://apod.nasa.gov/apod/image/1701/potw1636aN159_HST_1024.jpg"
