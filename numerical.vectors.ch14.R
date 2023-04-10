### R for Data Science 
#Second Edition: Chapter 14, Numerical Vectors   

#Restart the console to start fresh! 
#ctrl + shift + F10 

library(tidyverse)
library(nycflights13)

#> Making Numbers ---- 
#> 
#> In most cases, you'll get numbers already recorded in one of R's numeric 
#> types: integer or double. 
#> In some cases, you'll encounter them as  strings. This can happen for a few
#> random reasons. 
#> 
#> readr provides two useful functions for parsing strings into numbers: 
#> parse_double() and parse_number() 
#> 
#> Use parse_double() when you have numbers that have been written as strings: 
x <- c("1.2", "5.6", "1e3")
parse_double(x)
#> [1]    1.2    5.6 1000.0

#> Use parse_number() when the string contains non-numeric text that you want
#> to ignore. Particularly useful for currency data and percentages 
x <- c("$1,234", "USD 3,513", "59%")
parse_number(x)
#> [1] 1234 3513   59


#> Counts ----- 
#> 
#> #> count() 
#> Here we just see how many flights are going to each destination: 
flights |> count(dest)

#> If you want to see the most common values, add sort = TRUE 
flights |> count(dest, sort = TRUE)
#> And remember, to see all of the values you can use view() or |> print(n = Inf)
#> 
#> You can compute the same computation "by hand" with group_by(), summarize() 
#> and n(). This is useful because you can compute other things at the same time
flights |> 
  group_by(dest) |> 
  summarize(
    n = n(),
    delay = mean(arr_delay, na.rm = TRUE)
  )
#> n() is a special summary function that doesn't take any arguments and instead
#> accesses information about the current group. (only works inside dplyr verbs)
#> 
#> Variants of n() 
#> 
#> n_distinct() counts the number of distinct (unique) values of one or more 
#> variables. 
flights |> 
  group_by(dest) |> 
  summarize(carriers = n_distinct(carrier)) |> 
  arrange(desc(carriers))

#> A weighted count is a sum. For example, you could "count" the number of miles
#> each plan flew: 
flights |> 
  group_by(tailnum) |> 
  summarize(miles = sum(distance))
#> weighted counts are a common problem so count() has a wt argument that does 
#> the same thing: 
flights |> count(tailnum, wt = distance)


#> You can count missing values by combining sum() and is.na() 
#> In the flights data set, this represents flights that are cancelled.
flights |> 
  group_by(dest) |> 
  summarize(n_cancelled = sum(is.na(dep_time))) 


#> Numeric Transformations ----- 
#> 
#> R's recycling rules 
#> 
#> For example, with the operation: flights |> mutate(air_time = air_time / 60)
#> There are some 300,000 numbers in the left vector (air_time) but only one 
#> number in the right vector. 
#> R handles this by repeating, the short vector. 
x <- c(1, 2, 10, 20)
x / 5
#> [1] 0.2 0.4 2.0 4.0
# is shorthand for
x / c(5, 5, 5, 5)
#> [1] 0.2 0.4 2.0 4.0

#> Generally, you only want to recycle single numbers (vectors of length 1), but
#>  R will recycle any shorter length vector. 
#>  It usually gives you a warning if the longer vector isn't a multiple of the 
#>  shorter: 
x * c(1, 2)
#> [1]  1  4 10 40
x * c(1, 2, 3)
#> Warning in x * c(1, 2, 3): longer object length is not a multiple of shorter
#> object length
#> [1]  1  4 30 20
#> 

#> Minimum and Maximum ------ 
#> 
#> Closely related functions are pmin() and pmax() 
#> Which when given two or more variables, will return the smallest or legest 
#> value in each row: 
#> 
df <- tribble(
  ~x, ~y,
  1,  3,
  5,  2,
  7, NA,
)

df |> 
  mutate(
    min = pmin(x, y, na.rm = TRUE),
    max = pmax(x, y, na.rm = TRUE)
  )
#> # A tibble: 3 × 4
#>       x     y   min   max
#>   <dbl> <dbl> <dbl> <dbl>
#> 1     1     3     1     3
#> 2     5     2     2     5
#> 3     7    NA     7     7#> 

#> These are a bit different than min() and max() which take multiple observations
#> and return a single value. You can tell that you've used the wrong form when
#> every min and max value is the same.

df |> 
  mutate(
    min = min(x, y, na.rm = TRUE),
    max = max(x, y, na.rm = TRUE)
  )
#> # A tibble: 3 × 4
#>       x     y   min   max
#>   <dbl> <dbl> <dbl> <dbl>
#> 1     1     3     1     7
#> 2     5     2     1     7
#> 3     7    NA     1     7


#> Modular Arithmetic ----- 
#> 
#> Technical name for the type of math you did before you learned about decimal 
#> places. i.e. division that yields a whole number and a remainder. 
#> In R, %/% does integer division and %% computes the remainder: 
1:10 %/% 3
#>  [1] 0 0 1 1 1 2 2 2 3 3
1:10 %% 3
#>  [1] 1 2 0 1 2 0 1 2 0 1

#> Modular arithmetic can be useful at times. With the flight data we can use it 
#> to unpack the sched_dep_time variable into hour and minute: 

flights |> 
  mutate(
    hour = sched_dep_time %/% 100,
    minute = sched_dep_time %% 100,
    .keep = "used"
  )

#> We can combine this with mean(is.na(x)) trick from section 13.4 to see how 
#> the proportion of cancelled flights varies over the course of the day. 
flights |> 
  group_by(hour = sched_dep_time %/% 100) |> 
  summarize(prop_cancelled = mean(is.na(dep_time)), n = n()) |> 
  filter(hour > 1) |> 
  ggplot(aes(x = hour, y = prop_cancelled)) +
  geom_line(color = "grey50") + 
  geom_point(aes(size = n))


#> Logarithms 
#> 
#> Useful transformation for dealing with data that ranges across multiple orders
#> of magnitude and convert exponential growth to linear growth. 
#> In R, you have the choice between three logarithms: 
#> log() -the natural log, base e) 
#> log2() -base 2 
#> log10() -base 10 
#> They recommend using log2 or log10 because they are easier to interpret 
#> 
#> The inverse of log is exp() 
#> To compute the ivnerse of log2() or log10() you'll need to use 2^ or 10^ 
#> 
#> Rounding ------ 
#> 
#> Use round() to round a number to the nearest integer 
round(123.456)

#You can control the precision of the rounding with the second argument:
round(123.456, 2)  # two digits
#> [1] 123.46
round(123.456, 1)  # one digit
#> [1] 123.5
round(123.456, -1) # round to nearest ten
#> [1] 120
round(123.456, -2) # round to nearest hundred
#> [1] 100
#> 
#> One weirdness with round() that seems surprising: 
round(c(1.5, 2.5))
#> [1] 2 2
#>round() uses what's known as "round half to even" or Banker's roudning: if a 
#>number is half way between tow integers, it will be rounded to the even 
#>integer. This is a good strategy because it keeps the rounding unbiased: 
#>half of all .5s are rounded up, half of all .5s are rounded down. 
#>
#>round() is paired with floor() which always rounds down and ceiling() which
#>always rounds up
x <- 123.456

floor(x)
#> [1] 123
ceiling(x)
#> [1] 124

#> These functions don't have a digits argument so you can instead scale down, 
#> round, and then scale back up: 
# Round down to nearest two digits
floor(x / 0.01) * 0.01
#> [1] 123.45
# Round up to nearest two digits
ceiling(x / 0.01) * 0.01
#> [1] 123.46


#> Cutting numbers into ranges ------- 
#> 
#> Use cut() to break up (aka bin) a numeric vector into discrete buckets: 
x <- c(1, 2, 5, 10, 15, 20)
cut(x, breaks = c(0, 5, 10, 15, 20))
#> [1] (0,5]   (0,5]   (0,5]   (5,10]  (10,15] (15,20]
#> Levels: (0,5] (5,10] (10,15] (15,20]

#> The breaks don't need to be evenly spaced: 
cut(x, breaks = c(0, 5, 10, 100))
#> [1] (0,5]    (0,5]    (0,5]    (5,10]   (10,100] (10,100]
#> Levels: (0,5] (5,10] (10,100]
#> 
#> You can optinally supply your own labels.
#> Note that there should be one less labels than breaks 
cut(x, 
    breaks = c(0, 5, 10, 15, 20), 
    labels = c("sm", "md", "lg", "xl")
)
#> [1] sm sm sm md lg xl
#> Levels: sm md lg xl

#> Any values outside of the ranges of the breaks will become NA 
#> 
y <- c(NA, -10, 5, 10, 30)
cut(y, breaks = c(0, 5, 10, 15, 20))
#> [1] <NA>   <NA>   (0,5]  (5,10] <NA>  
#> Levels: (0,5] (5,10] (10,15] (15,20]


#> Base R provides cumsum(), cumprod(), cummin(), and cummax() for running, or 
#> cumulative sums, products, mins and maxes. 
#> dplyr provies cummean() for cumulative means 
#> 
#> Cumulative sums tend to come up most in practice: 

x <- 1:10
cumsum(x)
#>  [1]  1  3  6 10 15 21 28 36 45 55
#>  

#> General transformations -------
#> 
#> Often used with numeric vectors, but can be applied to all other column types
#> 
#> Ranks: 
#> 
#> dplyr provides a view different ranking functions 
#> dplyr::min_rank() is where you should start, it uses the typical method for
#> dealing with ties. e.g. 1st, 2nd, 2nd, 4th. 
x <- c(1, 2, 2, 3, 4, NA)
min_rank(x)
#> [1]  1  2  2  4  5 NA
#> 
#> Note that the smallest values get the largest ranks, use desc(x) to reverse this
min_rank(desc(x))
#> [1]  5  3  3  2  1 NA

#> If min_rank() doesn't do what ou need, look at the variants: 
#> dplyr::row_number(), 
#> dplyr::dense_rank() 
#> dplyr::percent_rank() 
#> dplyr::cume_dist() 
#> See each functions documentation for more details. 
#> 
df <- tibble(x = x)
df |> 
  mutate(
    row_number = row_number(x),
    dense_rank = dense_rank(x),
    percent_rank = percent_rank(x),
    cume_dist = cume_dist(x)
  )
#> # A tibble: 6 × 5
#>       x row_number dense_rank percent_rank cume_dist
#>   <dbl>      <int>      <int>        <dbl>     <dbl>
#> 1     1          1          1         0          0.2
#> 2     2          2          2         0.25       0.6
#> 3     2          3          2         0.25       0.6
#> 4     3          4          3         0.75       0.8
#> 5     4          5          4         1          1  
#> 6    NA         NA         NA        NA         NA

#> In base R, you can get many of the same results by picking appropriate 
#> ties.method argument to rank() 
#> You'll probably want to set na.last = "keep" to keep NA as NA 
#> 
#> row_number() can also be used without any arguments when inside a dplyr verb. 
#> 
df <- tibble(id = 1:10)

df |> 
  mutate(
    row0 = row_number() - 1,
    three_groups = row0 %% 3,
    three_in_each_group = row0 %/% 3
  )
#> # A tibble: 10 × 4
#>      id  row0 three_groups three_in_each_group
#>   <int> <dbl>        <dbl>               <dbl>
#> 1     1     0            0                   0
#> 2     2     1            1                   0
#> 3     3     2            2                   0
#> 4     4     3            0                   1
#> 5     5     4            1                   1
#> 6     6     5            2                   1
#> # ℹ 4 more rows


#> Offsets 
#> dplyr::lead() and dplyr::lag() allow you to refer to the values just before 
#> or just after the "current" value. 
#> They return a vector of the same length as the input, padded with NAs at the 
#> start or end: 
x <- c(2, 5, 11, 11, 19, 35)
lag(x)
#> [1] NA  2  5 11 11 19
lead(x)
#> [1]  5 11 11 19 35 NA

#> x - lag(x) gives you the difference between the current and previous value
x - lag(x)

#> x == lag(x) tells you when the current value changes
x == lag(x)

#> You can lead or lag by more than one position by using the second argument, n 

#> Consecutive Identifiers 
#> 
#> Sometimes you want to start a new group every time some event occurs. 
#> This occurs with website data when you want to create a new group for each
#> session that has a gap of more than x minutes since the last activity. 
events <- tibble(
  time = c(0, 1, 2, 3, 5, 10, 12, 15, 17, 19, 20, 27, 28, 30)
)

events <- events |> 
  mutate(
    diff = time - lag(time, default = first(time)),
    has_gap = diff >= 5
  )
events
#> # A tibble: 14 × 3
#>    time  diff has_gap
#>   <dbl> <dbl> <lgl>  
#> 1     0     0 FALSE  
#> 2     1     1 FALSE  
#> 3     2     1 FALSE  
#> 4     3     1 FALSE  
#> 5     5     2 FALSE  
#> 6    10     5 TRUE   
#> # ℹ 8 more rows

events |> mutate(
  group = cumsum(has_gap)
)
#> # A tibble: 14 × 4
#>    time  diff has_gap group
#>   <dbl> <dbl> <lgl>   <int>
#> 1     0     0 FALSE       0
#> 2     1     1 FALSE       0
#> 3     2     1 FALSE       0
#> 4     3     1 FALSE       0
#> 5     5     2 FALSE       0
#> 6    10     5 TRUE        1
#> # ℹ 8 more rows


#> Another approach for creating grouping variables is consecutive_id() 
#> which starts a new group every time one of its arguments changes. 
#> Imagine you have a data frame with a bunch of repeated values: 
df <- tibble(
  x = c("a", "a", "a", "b", "c", "c", "d", "e", "a", "a", "b", "b"),
  y = c(1, 2, 3, 2, 4, 1, 3, 9, 4, 8, 10, 199)
)
#> If you want to keep the first row from each repeated x, you could use group_by(),
#> consecutive_id() and slice_head() 
df |> 
  group_by(id = consecutive_id(x)) |> 
  slice_head(n = 1)


#> Numeric Summaries ------ 
#> 
#> Center 
#> 
#> mean()
#> median() 
flights |>
  group_by(year, month, day) |>
  summarize(
    mean = mean(dep_delay, na.rm = TRUE),
    median = median(dep_delay, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  ) |> 
  ggplot(aes(x = mean, y = median)) + 
  geom_abline(slope = 1, intercept = 0, color = "white", linewidth = 2) +
  geom_point()

#> There is no mode() function included with base R. Mostly because its useless 
#> in stats. And can be found in many other ways. 
#> 
#> 
#> Minimum, maximum, and quantiles 
#> 
#> min() 
#> max() 
#> quantile()
#> 
#> quantile(x, .25) will find the value of x that is greater than 25% of values
#> quantile(x, .87) will find the value of x that is greater than 87% of values 

flights |>
  group_by(year, month, day) |>
  summarize(
    max = max(dep_delay, na.rm = TRUE),
    q95 = quantile(dep_delay, 0.95, na.rm = TRUE),
    .groups = "drop"
  )
#> # A tibble: 365 × 5
#>    year month   day   max   q95
#>   <int> <int> <int> <dbl> <dbl>
#> 1  2013     1     1   853  70.1
#> 2  2013     1     2   379  85  
#> 3  2013     1     3   291  68  
#> 4  2013     1     4   288  60  
#> 5  2013     1     5   327  41  
#> 6  2013     1     6   202  51  
#> # ℹ 359 more rows

#> Spread 
#> 
#> sd() 
#> IQR() 
#> 
#> IQR(x) gives you the middle 50% of your data range. 25%-75% 
#> 
flights |> 
  group_by(origin, dest) |> 
  summarize(
    distance_sd = IQR(distance), 
    n = n(),
    .groups = "drop"
  ) |> 
  filter(distance_sd > 0)
#> # A tibble: 2 × 4
#>   origin dest  distance_sd     n
#>   <chr>  <chr>       <dbl> <int>
#> 1 EWR    EGE             1   110
#> 2 JFK    EGE             1   103
#> 
#> 
#> Distributions 
#> 
#> Its useful to remember that all of the summary statitics are a way of reducing
#> the distribution down to a single number. Since they are reductive, sometimes 
#> you can pick a bad way of reducing them which is why its useful to look at
#> the distribution yourself. 
#> 
#> Whenever creating numerical summaries, its a good idea to include the number
#> of observations in each group 
#> 
#> Positions 
#> 
#> first(x)
#> last(x) 
#> nth(x, n)
flights |> 
  group_by(year, month, day) |> 
  summarize(
    first_dep = first(dep_time, na_rm = TRUE), 
    fifth_dep = nth(dep_time, 5, na_rm = TRUE),
    last_dep = last(dep_time, na_rm = TRUE)
  )
#> `summarise()` has grouped output by 'year', 'month'. You can override using
#> the `.groups` argument.
#> # A tibble: 365 × 6
#> # Groups:   year, month [12]
#>    year month   day first_dep fifth_dep last_dep
#>   <int> <int> <int>     <int>     <int>    <int>
#> 1  2013     1     1       517       554     2356
#> 2  2013     1     2        42       535     2354
#> 3  2013     1     3        32       520     2349
#> 4  2013     1     4        25       531     2358
#> 5  2013     1     5        14       534     2357
#> 6  2013     1     6        16       555     2355
#> # ℹ 359 more rows

#> With mutate() 
#> 
#> x / sum(x) calculates the proportion of a total 
#> (x - mean(x)) / sd(x) computes a z-score (standardized to mean 0 and sd 1)
#> (x - min(x)) / (max(x) - minx(x)) standardizes to range 0,1 
#> x / first(x) computes an index based on the first observation 



