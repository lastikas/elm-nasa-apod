module Apod.DateHelper exposing (dayBefore, dayAfter, formatToYMD, dateFromString)

import Date
import Date.Extra.Duration as DateDuration
import Date.Extra.Config.Config_en_au exposing (config)
import Date.Extra.Format as Format exposing (format, formatUtc, isoMsecOffsetFormat)
import Time


dayBefore : Date.Date -> Date.Date
dayBefore =
    shiftDay -1


dayAfter : Date.Date -> Date.Date
dayAfter =
    shiftDay 1


shiftDay : Int -> Date.Date -> Date.Date
shiftDay dayQuantity date =
    addDay dayQuantity date


addDay : Int -> Date.Date -> Date.Date
addDay =
    DateDuration.add DateDuration.Day


{-|
    just to make sure timezones do not alter our date
    since GMT varies only to 11 hours max (either way) this is fairly reliable
-}
middayTimezone : String
middayTimezone =
    "T12:00:00"


{-| TODO: should apodDateLimit be here?
    should it be anywhere at all?

    the APOD began in 1995-06-16
    1995-06-16T12:00:00 = 803304000000 in UTC
    see https://apod.nasa.gov/apod/archivepix.html
-}
apodDateLimit : Time.Time
apodDateLimit =
    803304000000


formatDate : String -> Date.Date -> String
formatDate formatString date =
    format config formatString date


formatToYMD : Date.Date -> String
formatToYMD =
    formatDate "%Y-%m-%-d"


{-|
    TODO: don't do this and treat errors accordingly

    if we cannot convert the given string to a Date.Date
    we fallback to the api earliest available data
-}
dateFromString : String -> Date.Date
dateFromString dateString =
    Date.fromString (dateString ++ middayTimezone)
        |> Result.withDefault (Date.fromTime apodDateLimit)
