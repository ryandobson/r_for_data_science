### R for Data Science 
#Second Edition: Chapter 13, Logical Vectors  

#Restart the console to start fresh! 
#ctrl + shift + F10 

library(tidyverse)
library(nycflights13)

#> Most of what we do with logical vectors is done with base R 
#> 
#> We will use the flight data set and create some of our own data when needed
#> to explore things. 
#> 
#> Remember, any manipulation we do to a free-floating vector, you can do to a 
#> variable inside a data frame with mutuate() and related functions 
#> For example: 
x <- c(1, 2, 3, 5, 7, 11, 13)
x * 2

df <- tibble(x)
df |> 
  mutate(y = x *  2)


#> Comparisons ---- 
#> 
#> A very common way to create a logical vector is via a numeric comparison with: 
#> <, <=, >, >=, !=, and ==. 
#> So far, we have mostly created logical variables transiently within filter() 
#> For example, in filter the vectors are computed, used, and then thrown away. 
flights |> 
  filter(dep_time > 600 & dep_time < 2000 & abs(arr_delay) < 20)
#> This code finds all the flights that leave roughly on time

#> When we do that with filter, it is actually a shortcut and you can explicitly 
#> create the underlying logical variables with mutate() 
flights |> 
  mutate(
    daytime = dep_time > 600 & dep_time < 2000,
    approx_ontime = abs(arr_delay) < 20,
    .keep = "used"
  )
#> Doing something like this is particularly useful for more complicated logic 
#> because it helps you see the intermediate steps and allows you to understand
#> what is happening more fully. 
#> 
#> The initial filter is equal to: 
flights |> 
  mutate(
    daytime = dep_time > 600 & dep_time < 2000,
    approx_ontime = abs(arr_delay) < 20,
  ) |> 
  filter(daytime & approx_ontime)

#> Floating point comparison: 
#> Beware of using == with numbers. For example, it looks like this vector 
#> contains numbers 1 and 2: 
x <- c(1/49* 49, sqrt(2)^2)
x
#> But if you test them for equality, you get false: 
x == c(1, 2)
#> Computers store numbers with a fixed number of decimal places so there's no 
#> way to exactly represent 1/49 or sqrt(2) and subsequent computations will be
#> very slightly off. We can see the exactly values by calling print() with the 
#> digits argument: 
print(x, digits = 16)
#> You can see why R just rounds these numbers. 
#> 
#> Missing Values -----
#> 
#> Missing values represent the unknown so they are "contagious": almost any 
#> operation involving an unknown value will also be unknown: 
NA > 5
10 == NA
NA == NA 

#> After the first expression, both that follow should return true. 
#>Its easiest to understand this with some context. 

# We don't know how old Mary is
age_mary <- NA

# We don't know how old John is
age_john <- NA

# Are Mary and John the same age?
age_mary == age_john
#> [1] NA
# We don't know!

#> So if you want to find all flights where dep_time is missing, the following
#> code doesn't work because dep_time == NA will yeild NA for every single row, 
#> and filter automatically drops missing values: 
flights |> 
  filter(dep_time == NA)

#> Instead we use a new tool: is.na() 
#> is.na() works with any type of vector and returns TRUE for missing values and
#> FALSE for everything else. 
is.na(c(TRUE, NA, FALSE))
#> [1] FALSE  TRUE FALSE
is.na(c(1, NA, 3))
#> [1] FALSE  TRUE FALSE
is.na(c("a", NA, "b"))
#> [1] FALSE  TRUE FALSE

#Example with finding the missing flight times. 
flights |> 
  filter(is.na(dep_time))

#> is.na() can also be useful in arrange() 
#> arrange() usually puts all the missing values at the end but ou can override 
#> this defautl by first sorting by is.na() 
#> Example without is.na() 
flights |> 
  filter(month == 1, day == 1) |> 
  arrange(dep_time)
#>Example using is.na() 
flights |> 
  filter(month == 1, day == 1) |> 
  arrange(desc(is.na(dep_time)), dep_time)
#We specified dep_time a second time so that we still have the none NA departure
#> sorted in a manner that we want! 
#> 
#> You can just type the name of the function to see its source code: 
near


#> Boolean Algebra ------ 
#> 
#> Once you have multiple logical vectors, you can combine them together using
#> Boolean algebra. 
#> & is equal to "and" 
#> | is equal to "or" 
#> ! is equal to "not" 
#> xor() is exclusive or (a or b, but not both) 
#> 
#> As well as & and |, R also has && and ||. Don't use them in dplyr functions! 
#> These are called short-circuiting operators and only ever return a single 
#> TRUE or FALSE. They're important for programming, not data science. 
#> 
#> Missing Values ------
#> 
df <- tibble(x = c(TRUE, FALSE, NA))

df |> 
  mutate(
    and = x & NA,
    or = x | NA
  )
#> To understand what’s going on, think about NA | TRUE. A missing value in a 
#> logical vector means that the value could either be TRUE or FALSE. TRUE | TRUE 
#> and FALSE | TRUE are both TRUE, so NA | TRUE must also be TRUE. 
#> Similar reasoning applies with NA & FALSE.

#> Order of Operations 
#> Note that the order of operations doesn't work like English. 
#> This below code finds all the flights that departed in November or December
flights |> 
  filter(month == 11 | month == 12)
#> You might be tempted to write the above code as: 
flights |> 
  filter(month == 11 | 12)
#> The code doesn't error but it also does not return what you want. 
#> First R evaluates month == 11 creating a logical vector, which we call nov. 
#> It then computes nov | 12. When ou use a number with a logical operator it 
#> converts everything apart from 0 to TRUE, so this is equivalent to nov | TRUE, 
#> which will always be TRUE, so every row will be selected. 
#> An example using mutate to show the above logic: 
flights |> 
  mutate(
    nov = month == 11,
    final = nov | 12,
    .keep = "used"
  )

#> %in% ----- 
#> 
#> An easy way to avoid the problem of getting your ands and ors in the right 
#> order is to use %in%. 
#> x %in% y returns a logical vector the same length as x that is TRUE whenever 
#> a value in x is anywhere in y. 
#> 
#> So, to find all flights in November and December we could write: 
flights |> 
  filter(month %in% c(11, 12))
#> NOTE: %in% obeys different rules for NA to ==, as NA %in% is TRUE. 
#> Example: 
c(1, 2, NA) == NA

#> [1] NA NA NA
c(1, 2, NA) %in% NA
#> [1] FALSE FALSE  TRUE
is.na(c(1, 2, NA)) #> Using is.na operates in the same way as %in% 

#> This can make for a useful short cut: 
flights |> 
  filter(dep_time %in% c(NA, 0800))


#> Summaries ----- 
#> 
#> Useful techniques for summarizing logical vectors 
#> 
#> Two main logical summaries: any() and all() 
#> any(x) is the equivalent of |; it'll return TRUE if there are any TRUE's in x. 
#> all(x) is equivalent of &; it'll return TRUE only if all values of x are TRUE's. 
#> Like all summary functions, they'll return NA if tehre are any missing values,
#> as usual you can make the missing values go away with na.rm = TRUE 
#> 
flights |> 
  group_by(year, month, day) |> 
  summarize(
    all_delayed = all(dep_delay <= 60, na.rm = TRUE),
    any_long_delay = any(arr_delay >= 300, na.rm = TRUE),
    .groups = "drop"
  )

#> In most cases, however, any() and all() are a little too crude. It would be 
#> nice to get a little more detail about how many values are TRUE or FALSE. 
#> 
#> Numeric Summaries of Logical Vectors ------ 
#> 
#> When you use a logical vector in a numeric context, TRUE becomes 1 and FALSE
#> becomes 0. This makes sum() and mean() very useful with logical vectors
#> because sum(x) gives the numbers of TRUE's and mean(x) gives the proportion of
#> TRUE's 
#> 
#> For example, we can see the proportion of flights that were delayed by less 
#> than 60 minutes and the number of flights that were delayed by over 5 hours 
flights |> 
  group_by(year, month, day) |> 
  summarize(
    all_delayed = mean(dep_delay <= 60, na.rm = TRUE),
    any_long_delay = sum(arr_delay >= 300, na.rm = TRUE),
    .groups = "drop"
  )

#> Logical Subsetting ----- 
#> 
#> YOu can use a logical vector to filter a single variable to a subset of 
#> interest. This makes use of the base [] operator. 
#> 
#> Imagine we want to look at the average delay just for flights that were 
#> actually delayed. We could do this by filtering flights and then calculating
#> the average delay: 

flights |> 
  filter(arr_delay > 0) |> 
  group_by(year, month, day) |> 
  summarize(
    behind = mean(arr_delay),
    n = n(),
    .groups = "drop"
  )
#> This works, but what if we wanted to also compute the average delay for 
#> flights that arrived early? 
#> We'd need to perform a separate filter step, and then figure out how to 
#> combine the two data frames together. 
#> Instead you could use [ to perform an inline filtering: 
#> arr_delay[arr_delay > 0]  - this will yeild only postiive arrival delays. 
flights |> 
  group_by(year, month, day) |> 
  summarize(
    behind = mean(arr_delay[arr_delay > 0], na.rm = TRUE),
    ahead = mean(arr_delay[arr_delay < 0], na.rm = TRUE),
    n = n(),
    .groups = "drop"
  )


#> Conditional Transformations ------ 
#> 
#> One of the most powerful features of logical vectors are their use for 
#> conditional transformations: 
#> doing one thing for condition x, and something different for condition y. 
#> There are two important functions here: if_else() and case_when() 
#> 
#> if_else() 
#> If you want to use one value when a condition is TRUE and another value when 
#> its FALSE, you can use dplyr::if_else(). 
#> You'll always use the first three arguments of if_else() 
#> The first argument, condition, is a logical vector, 
#> The second, true, gives the output when the condition is TRUE, 
#> The third, false, gives the output if the condition is FALSE. 
#> 
#> Example: 
x <- c(-3:3, NA)
if_else(x > 0, "+ve", "-ve")

#> Optional fourth argument, missing , which will be used if the input is NA: 
if_else(x > 0, "+ve", "-ve", "???")

#>You can also use vectors for the true and false arguments. 
if_else(x < 0, -x, x)

#> You can of course mix and match vectors that you are using: 
x1 <- c(NA, 1, 2, NA)
y1 <- c(3, NA, 4, 6)
if_else(is.na(x1), y1, x1)
#> This above code is a simple version of coalesce() 

#This is to fix a small error in the first if_else's we were doing. 
#> 0 is not positive or negative so we add a second if_else to represent that.
if_else(x == 0, "0", if_else(x < 0, "-ve", "+ve"), "???")
#> [1] "-ve" "-ve" "-ve" "0"   "+ve" "+ve" "+ve" "???"

#> 
#> case_when() 
#> 
#> Inspired by SQL's CASE statement and provides a flexible way of performing 
#> different computations for different conditions. 
#> It has a special syntax that is unlike anything else in the tidyverse. 
#> 
#> It has the advantage of simplifying our nested if_else() function created above
x <- c(-3:3, NA)
case_when(
  x == 0   ~ "0",
  x < 0    ~ "-ve", 
  x > 0    ~ "+ve",
  is.na(x) ~ "???"
)
#> Its a bit more code but it is much more explicit. 
#> If no cases match, then we get an NA: 
case_when(
  x < 0 ~ "-ve",
  x > 0 ~ "+ve"
)
#> If you want a default, "catch/all" value, use TRUE on the left hand side: 
case_when(
  x < 0 ~ "-ve",
  x > 0 ~ "+ve",
  TRUE ~ "???"
)
#> [1] "-ve" "-ve" "-ve" "???" "+ve" "+ve" "+ve" "???"
#>If multiple conditions match, only the first will be used! 
case_when(
  x > 0 ~ "+ve",
  x > 2 ~ "big"
)
#> [1] NA    NA    NA    NA    "+ve" "+ve" "+ve" NA


#> A practical application of case_when() is to add some human readable labels
#> for the arrival delay: 
flights |> 
  mutate(
    status = case_when(
      is.na(arr_delay)      ~ "cancelled",
      arr_delay < -30       ~ "very early",
      arr_delay < -15       ~ "early",
      abs(arr_delay) <= 15  ~ "on time",
      arr_delay < 60        ~ "late",
      arr_delay < Inf       ~ "very late",
    ),
    .keep = "used"
  )
#> Be careful when writing this sort of statements! Its easy to accidentally 
#> create overlapping conditions. 


#> Compatible Types 
#> 
#> Note that both if_else() and case_when() require compatible types in the 
#> output. 
#> If they are not compatible, you'll see errors like this: 
if_else(TRUE, "a", 1)
#> Error in `if_else()`:
#> ! Can't combine `true` <character> and `false` <double>.

case_when(
  x < -1 ~ TRUE,  
  x > 0  ~ now()
)
#> Error in `case_when()`:
#> ! Can't combine `..1 (right)` <logical> and `..2 (right)` <datetime<local>>.

#> Important Cases that ARE compatible: 
#>  Numeric and logical vectors 
#>  Strings and factors - because you can think of a factor as a string with a
#>  restricted set of values 
#>  Dates and date-times - you can think of dates as a special case of date-time
#>  NA, which is technically a logical vector, is compatible with everything. 
#>  
#>  
#>  
#>  


