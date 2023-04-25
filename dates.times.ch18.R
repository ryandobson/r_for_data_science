### R for Data Science 
#Second Edition: Chapter 18, Dates and Times   

#Restart the console to start fresh! 
#ctrl + shift + F10 

library(tidyverse)

#> lubridate package of tidyverse is mainly used here. 
#> 
library(nycflights13)

#> There are dates, times, and date-times. 
#> Always use the simplest possible data type that works for your needs. 
#> date-time gets pretty complicated with time zones and what not. 
#> 
#> Get the current date or date-time: 
today()
now()

#> Creating Dates/Date-Times ------
#> 
#> Reading on Import: 
#> 
#> If your CSV contains an ISO8601 date or date-time, you don't need to do 
#> anything; readr will automatically recognize it. 
#> 
#> ISO8601 is just an international standard for writing dates. 
#> 
#> For other date-time formats, you'll need to use col_types plus col_date or 
#> col_datetime() along with a date-time format. 
#> 
#> See textbook for a table of different date formats available. 
#> 
#> One problem is that sometimes dates are listed in an ambiguous format: 
csv <- "
  date
  01/02/15
"

read_csv(csv, col_types = cols(date = col_date("%m/%d/%y")))
#> # A tibble: 1 × 1
#>   date      
#>   <date>    
#> 1 2015-01-02

read_csv(csv, col_types = cols(date = col_date("%d/%m/%y")))
#> # A tibble: 1 × 1
#>   date      
#>   <date>    
#> 1 2015-02-01

read_csv(csv, col_types = cols(date = col_date("%y/%m/%d")))
#> # A tibble: 1 × 1
#>   date      
#>   <date>    
#> 1 2001-02-15



#> From Strings 
#> 
ymd("2017-01-31")
#> [1] "2017-01-31"
mdy("January 31st, 2017")
#> [1] "2017-01-31"
dmy("31-Jan-2017")
#> [1] "2017-01-31"
#> 

ymd_hms("2017-01-31 20:11:59")
#> [1] "2017-01-31 20:11:59 UTC"
mdy_hm("01/31/2017 08:01")
#> [1] "2017-01-31 08:01:00 UTC"

#> forcing a time zone with tz = "" 
ymd("2017-01-31", tz = "UTC")
#> [1] "2017-01-31 UTC"

#> From Individual Components 
#> 
flights |> 
  select(year, month, day, hour, minute)
#> # A tibble: 336,776 × 5
#>    year month   day  hour minute
#>   <int> <int> <int> <dbl>  <dbl>
#> 1  2013     1     1     5     15
#> 2  2013     1     1     5     29
#> 3  2013     1     1     5     40
#> 4  2013     1     1     5     45
#> 5  2013     1     1     6      0
#> 6  2013     1     1     5     58
#> # ℹ 336,770 more rows
#> 
#> Use make_date() or make_datetime() to solve this: 
flights |> 
  select(year, month, day, hour, minute) |> 
  mutate(departure = make_datetime(year, month, day, hour, minute))
#> # A tibble: 336,776 × 6
#>    year month   day  hour minute departure          
#>   <int> <int> <int> <dbl>  <dbl> <dttm>             
#> 1  2013     1     1     5     15 2013-01-01 05:15:00
#> 2  2013     1     1     5     29 2013-01-01 05:29:00
#> 3  2013     1     1     5     40 2013-01-01 05:40:00
#> 4  2013     1     1     5     45 2013-01-01 05:45:00
#> 5  2013     1     1     6      0 2013-01-01 06:00:00
#> 6  2013     1     1     5     58 2013-01-01 05:58:00
#> # ℹ 336,770 more rows
#> 
make_datetime_100 <- function(year, month, day, time) {
  make_datetime(year, month, day, time %/% 100, time %% 100)
}

flights_dt <- flights |> 
  filter(!is.na(dep_time), !is.na(arr_time)) |> 
  mutate(
    dep_time = make_datetime_100(year, month, day, dep_time),
    arr_time = make_datetime_100(year, month, day, arr_time),
    sched_dep_time = make_datetime_100(year, month, day, sched_dep_time),
    sched_arr_time = make_datetime_100(year, month, day, sched_arr_time)
  ) |> 
  select(origin, dest, ends_with("delay"), ends_with("time"))

flights_dt
#> # A tibble: 328,063 × 9
#>   origin dest  dep_delay arr_delay dep_time            sched_dep_time     
#>   <chr>  <chr>     <dbl>     <dbl> <dttm>              <dttm>             
#> 1 EWR    IAH           2        11 2013-01-01 05:17:00 2013-01-01 05:15:00
#> 2 LGA    IAH           4        20 2013-01-01 05:33:00 2013-01-01 05:29:00
#> 3 JFK    MIA           2        33 2013-01-01 05:42:00 2013-01-01 05:40:00
#> 4 JFK    BQN          -1       -18 2013-01-01 05:44:00 2013-01-01 05:45:00
#> 5 LGA    ATL          -6       -25 2013-01-01 05:54:00 2013-01-01 06:00:00
#> 6 EWR    ORD          -4        12 2013-01-01 05:54:00 2013-01-01 05:58:00
#> # ℹ 328,057 more rows
#> # ℹ 3 more variables: arr_time <dttm>, sched_arr_time <dttm>, … 
#> 
#> With this we can visualize the distribution of departure times across the 
#> year: 
flights_dt |> 
  ggplot(aes(x = dep_time)) + 
  geom_freqpoly(binwidth = 86400) # 86400 seconds = 1 day
#> or within a single day:
flights_dt |> 
  filter(dep_time < ymd(20130102)) |> 
  ggplot(aes(x = dep_time)) + 
  geom_freqpoly(binwidth = 600) # 600 s = 10 minutes

#> When you use date-times in a numeric context (like in a histogram), 1 means 1
#> second, so a binwidth of 86400 means one da. 
#> For dates, 1 means 1 day 
#> 
#> From Other Types 
#> 
#> Switching from date to date-time and vice versa 
#> as_datetime() 
#> as_date() 
as_datetime(today())
#> [1] "2023-04-12 UTC"
as_date(now())
#> [1] "2023-04-12"

#> Date-Time Components ------
#> 
#> You can pull out individual parts of the date with the accessor functions 
#> year()
#> month() 
#> mday()
#> yday()
#> wday()
#> hour()
#> minute()
#> second() 
#> 
datetime <- ymd_hms("2026-07-08 12:34:56")

year(datetime)
#> [1] 2026
month(datetime)
#> [1] 7
mday(datetime)
#> [1] 8

yday(datetime)
#> [1] 189
wday(datetime)
#> [1] 4

#> For month() and wday() you can set label = TRUE to return abbreviated names 
month(datetime, label = TRUE)
#> [1] Jul
#> 12 Levels: Jan < Feb < Mar < Apr < May < Jun < Jul < Aug < Sep < ... < Dec
wday(datetime, label = TRUE, abbr = FALSE)
#> [1] Wednesday
#> 7 Levels: Sunday < Monday < Tuesday < Wednesday < Thursday < ... < Saturday

#> We can use wday() to see that more flights depart during the week than on 
#> the weekend: 
flights_dt |> 
  mutate(wday = wday(dep_time, label = TRUE)) |> 
  ggplot(aes(x = wday)) +
  geom_bar()
#> Different examples of graphing by looking at dates 
flights_dt |> 
  mutate(minute = minute(dep_time)) |> 
  group_by(minute) |> 
  summarize(
    avg_delay = mean(dep_delay, na.rm = TRUE),
    n = n()
  ) |> 
  ggplot(aes(x = minute, y = avg_delay)) +
  geom_line()

sched_dep <- flights_dt |> 
  mutate(minute = minute(sched_dep_time)) |> 
  group_by(minute) |> 
  summarize(
    avg_delay = mean(arr_delay, na.rm = TRUE),
    n = n()
  )

ggplot(sched_dep, aes(x = minute, y = avg_delay)) +
  geom_line()


#> Rounding 
#> 
#> You can round a unit of time using a few different functions 
#> floor_date() 
#> round_date() 
#> ceiling_date() 
#> Each function takes a vector of dates to adjust and then the name of the unit
#> round down (floor), round up(ceiling), or round to. 
#> 
flights_dt |> 
  count(week = floor_date(dep_time, "week")) |> 
  ggplot(aes(x = week, y = n)) +
  geom_line() + 
  geom_point()


#> You can use rounding to show the distribution of flights across the course of 
#> a day by computing the difference between dep_time and the earliest instant 
#> of that day. 
flights_dt |> 
  mutate(dep_hour = dep_time - floor_date(dep_time, "day")) |> 
  ggplot(aes(x = dep_hour)) +
  geom_freqpoly(binwidth = 60 * 30)



#> Computing the difference between a pair of date-times yields a difftime. 
#> We can convert that to an hms object to get a more useful x-axis
flights_dt |> 
  mutate(dep_hour = hms::as_hms(dep_time - floor_date(dep_time, "day"))) |> 
  ggplot(aes(x = dep_hour)) +
  geom_freqpoly(binwidth = 60 * 30)


#> Modifying Components 
#> 
#> You can also use each accessor function to modify components of date/time. 
#> Doesn't come up much in practicality. 

(datetime <- ymd_hms("2026-07-08 12:34:56"))
#> [1] "2026-07-08 12:34:56 UTC"

year(datetime) <- 2030
datetime
#> [1] "2030-07-08 12:34:56 UTC"
month(datetime) <- 01
datetime
#> [1] "2030-01-08 12:34:56 UTC"
hour(datetime) <- hour(datetime) + 1
datetime
#> [1] "2030-01-08 13:34:56 UTC"

#> Alternatively, rather than modifying an existing variable, you can create
#> a new date-time with update() 
#> This allows you to set multiple values in one-step 
#> 
update(datetime, year = 2030, month = 2, mday = 2, hour = 2)
#> [1] "2030-02-02 02:34:56 UTC"
#> 
#> If values are too big they will roll over: 
update(ymd("2023-02-01"), mday = 30)
#> [1] "2023-03-02"
update(ymd("2023-02-01"), hour = 400)
#> [1] "2023-02-17 16:00:00 UTC"


#> Time Spans --------
#> 
#> Duration - an exact number of seconds 
#> Periods - represent human units like week sand months 
#> Intervals - represent a starting and ending point 
#> 
#> Duration 
#> In R, when you subtract two date-times, you get a difftime: 
# How old is Hadley?
h_age <- today() - ymd("1979-10-14")
h_age
#> Time difference of 15886 days

my_age <- today() -ymd("2000-11-17")
my_age

#> A difftime class object records a time span of seconds, minutes, hours, days, 
#> or weeks. This ambiguity can make them a little painful to work with. 
#> Lubridate provides an alternative which always uses seconds: duration. 
#> 
as.duration(my_age)

#> Duration comes with a bunch of convenient constructors:
dseconds(15)
#> [1] "15s"
dminutes(10)
#> [1] "600s (~10 minutes)"
dhours(c(12, 24))
#> [1] "43200s (~12 hours)" "86400s (~1 days)"
ddays(0:5)
#> [1] "0s"                "86400s (~1 days)"  "172800s (~2 days)"
#> [4] "259200s (~3 days)" "345600s (~4 days)" "432000s (~5 days)"
dweeks(3)
#> [1] "1814400s (~3 weeks)"
dyears(1)
#> [1] "31557600s (~1 years)"

#> You can multiply and add duration: 
2 * dyears(1)
#> [1] "63115200s (~2 years)"
dyears(1) + dweeks(12) + dhours(15)
#> [1] "38869200s (~1.23 years)"

#> You can add and subtract duration to and from days: 
tomorrow <- today() + ddays(1)
last_year <- today() - dyears(1)

#> Because duration represent an exact number of seconds, sometimes you might 
#> get an unexpected result: 
one_am <- ymd_hms("2026-03-08 01:00:00", tz = "America/New_York")

one_am
#> [1] "2026-03-08 01:00:00 EST"
one_am + ddays(1)
#> [1] "2026-03-09 02:00:00 EDT"
#> This discrepancy is caused by it being the day of day lights savings so it 
#> calculates it incorrectly. 
#> 
#> Periods 
#> 
#> Periods are time spans but don't have a fixed length in seconds. Instead they
#> work with human time units that allows for a more intuitive understanding. 
one_am
#> [1] "2026-03-08 01:00:00 EST"
one_am + days(1)
#> [1] "2026-03-09 01:00:00 EDT"
#> This also solves the problem that arose with duration and day light savings 
#> time. 
#> 
#> Period also comes with constructor functions: 
hours(c(12, 24))
#> [1] "12H 0M 0S" "24H 0M 0S"
days(7)
#> [1] "7d 0H 0M 0S"
months(1:6)
#> [1] "1m 0d 0H 0M 0S" "2m 0d 0H 0M 0S" "3m 0d 0H 0M 0S" "4m 0d 0H 0M 0S"
#> [5] "5m 0d 0H 0M 0S" "6m 0d 0H 0M 0S"
#> 

#>Can add and multiply periods 
10 * (months(6) + days(1))
#> [1] "60m 10d 0H 0M 0S"
days(50) + hours(25) + minutes(2)
#> [1] "50d 25H 2M 0S"


#> Compared to durations, periods are more likely to do what you expect: 
#> 
# A leap year
ymd("2024-01-01") + dyears(1)
#> [1] "2024-12-31 06:00:00 UTC"
ymd("2024-01-01") + years(1)
#> [1] "2025-01-01"

# Daylight Savings Time
one_am + ddays(1)
#> [1] "2026-03-09 02:00:00 EDT"
one_am + days(1)
#> [1] "2026-03-09 01:00:00 EDT"

#> An oddity in the flight data is that some flights seem to have arrived before
#> they departed. 

flights_dt |> 
  filter(arr_time < dep_time) 
#> # A tibble: 10,633 × 9
#>   origin dest  dep_delay arr_delay dep_time            sched_dep_time     
#>   <chr>  <chr>     <dbl>     <dbl> <dttm>              <dttm>             
#> 1 EWR    BQN           9        -4 2013-01-01 19:29:00 2013-01-01 19:20:00
#> 2 JFK    DFW          59        NA 2013-01-01 19:39:00 2013-01-01 18:40:00
#> 3 EWR    TPA          -2         9 2013-01-01 20:58:00 2013-01-01 21:00:00
#> 4 EWR    SJU          -6       -12 2013-01-01 21:02:00 2013-01-01 21:08:00
#> 5 EWR    SFO          11       -14 2013-01-01 21:08:00 2013-01-01 20:57:00
#> 6 LGA    FLL         -10        -2 2013-01-01 21:20:00 2013-01-01 21:30:00
#> # ℹ 10,627 more rows
#> # ℹ 3 more variables: arr_time <dttm>, sched_arr_time <dttm>, …

#> These are overnight flights. They arrive on the following day. 
flights_dt <- flights_dt |> 
  mutate(
    overnight = arr_time < dep_time,
    arr_time = arr_time + days(overnight),
    sched_arr_time = sched_arr_time + days(overnight)
  )

flights_dt |> 
  filter(overnight, arr_time < dep_time) 
#> # A tibble: 0 × 10
#> # ℹ 10 variables: origin <chr>, dest <chr>, dep_delay <dbl>,
#> #   arr_delay <dbl>, dep_time <dttm>, sched_dep_time <dttm>, …

#> Intervals 
#> 
#> Because of leap year when we ask for what a full year is, we get an estimate. 
years(1) / days(1)
#> [1] 365.25

#> If you want a more accurate measurement, you will have to use an interval. 
#> 
#> An interval is a pair of starting and ending date times. It is basically a 
#> duration with a starting point. 
#> 
#> Creating an Interval 
y2023 <- ymd("2023-01-01") %--% ymd("2024-01-01")
y2024 <- ymd("2024-01-01") %--% ymd("2025-01-01")

y2023
#> [1] 2023-01-01 UTC--2024-01-01 UTC
y2024
#> [1] 2024-01-01 UTC--2025-01-01 UTC
#> 
#> You can then divide it by days to see how many days fit in the year: 
y2023 / days(1)
#> [1] 365
y2024 / days(1)
#> [1] 366
#> 
#> 
#> Time Zones ----- 
#> 
#> Working with time zones is incredibly complicated. 
#> 
#> You can see what R thinkgs your current time zone is with: 
Sys.timezone()

#> Or to see a complete list of time zones: 
length(OlsonNames())
#> [1] 597
head(OlsonNames())
#> [1] "Africa/Abidjan"     "Africa/Accra"       "Africa/Addis_Ababa"
#> [4] "Africa/Algiers"     "Africa/Asmara"      "Africa/Asmera"
#> 
#> In R, the time zone is an attribute of the date-time that only controls 
#> printing. For example, these three objects represent the same isntant in 
#> time: 
x1 <- ymd_hms("2024-06-01 12:00:00", tz = "America/New_York")
x1
#> [1] "2024-06-01 12:00:00 EDT"

x2 <- ymd_hms("2024-06-01 18:00:00", tz = "Europe/Copenhagen")
x2
#> [1] "2024-06-01 18:00:00 CEST"

x3 <- ymd_hms("2024-06-02 04:00:00", tz = "Pacific/Auckland")
x3
#> [1] "2024-06-02 04:00:00 NZST"
#> 
#> Verifying that by subtracting: 
x1 - x2
#> Time difference of 0 secs
x1 - x3
#> Time difference of 0 secs

#> Operations with c() will usually drop the time zone and place yours in 
x4 <- c(x1, x2, x3)
x4
#> [1] "2024-06-01 12:00:00 EDT" "2024-06-01 12:00:00 EDT"
#> [3] "2024-06-01 12:00:00 EDT"
#> 
#> 
#> You can change the time zone in two ways: 
#> 1: Keep the instant in time the same, and change how its diplayed. Use this 
#> when the instant is correct, but you want a more natural display. 
x4a <- with_tz(x4, tzone = "Australia/Lord_Howe")
x4a
#> [1] "2024-06-02 02:30:00 +1030" "2024-06-02 02:30:00 +1030"
#> [3] "2024-06-02 02:30:00 +1030"
x4a - x4
#> Time differences in secs
#> [1] 0 0 0
#> 
#> 2: Change the underlying instant in time. Use this when you have an instant 
#> that has been labelled with the incorrect time zone, and you need to fix it. 



