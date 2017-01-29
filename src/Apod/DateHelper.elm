module Apod.DateHelper exposing (dayBefore, dayAfter)

import Date
import Date.Extra.Duration as DateDuration
import Date.Extra.Config.Config_en_au exposing (config)
import Date.Extra.Format as Format exposing (format, formatUtc, isoMsecOffsetFormat)
import Time


dayBefore : String -> String
dayBefore =
    shiftDay -1


dayAfter : String -> String
dayAfter =
    shiftDay 1


shiftDay : Int -> String -> String
shiftDay quantity dateString =
    formatToYMD (addDay quantity (dateFromString dateString))


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
    the APOD dates back to 1995-06-16
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
    if we cannot convert the given string to a Date.Date
    we fallback to the api earliest available data
-}
dateFromString : String -> Date.Date
dateFromString dateString =
    Date.fromString (dateString ++ middayTimezone)
        |> Result.withDefault (Date.fromTime apodDateLimit)
