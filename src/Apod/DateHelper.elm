module Apod.DateHelper exposing (dayBefore, dayAfter, formatToYMD, dateFromString, initDatePicker, isDisabled)

import Date
import Date.Extra.Duration as DateDuration
import Date.Extra.Config.Config_en_au exposing (config)
import Date.Extra.Format as Format exposing (format, formatUtc, isoMsecOffsetFormat)
import Date.Extra.Compare as DateCompare exposing (Compare2(..))
import DatePicker exposing (defaultSettings)


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


{-| the APOD began in 1995-06-16
    see https://apod.nasa.gov/apod/archivepix.html

    from experience I've learned that the API fails
    for dates before 1995-09-22
-}
apodDateLimit : Date.Date
apodDateLimit =
    Date.fromTime 811727999000


formatDate : String -> Date.Date -> String
formatDate formatString date =
    format config formatString date


formatToYMD : Date.Date -> String
formatToYMD =
    formatDate "%Y-%m-%d"


dateFromString : String -> Result String Date.Date
dateFromString dateString =
    Date.fromString (dateString ++ middayTimezone)


isDisabled : Date.Date -> Date.Date -> Bool
isDisabled todayDate datePickerDate =
    (DateCompare.is Before datePickerDate apodDateLimit)
        || (DateCompare.is After datePickerDate todayDate)


initDatePicker : Maybe Date.Date -> Date.Date -> ( DatePicker.DatePicker, Cmd DatePicker.Msg )
initDatePicker initialDate today =
    DatePicker.init
        { defaultSettings
            | pickedDate = initialDate
            , isDisabled = (isDisabled today)
        }
