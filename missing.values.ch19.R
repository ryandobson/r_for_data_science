### R for Data Science 
#Second Edition: Chapter 19, Missing Values    

#Restart the console to start fresh! 
#ctrl + shift + F10 

library(tidyverse) 


#> Explicit Missing Values -----
#> 
#> Last observation carried forward: 
#> 
#> A common use for missing values is as a data entry convenience. When data
#> is entered by hand, missing values sometimes indicate that the value in the
#> previous raw has been repeated (or carried forward): 
treatment <- tribble(
  ~person,           ~treatment, ~response,
  "Derrick Whitmore", 1,         7,
  NA,                 2,         10,
  NA,                 3,         NA,
  "Katherine Burke",  1,         4
)

#> You can fill in these missing values with tidyr::fill(). 
#> It works like select(), taking a set of columns: 
treatment |> 
  fill(everything())
#> # A tibble: 4 × 3
#>   person           treatment response
#>   <chr>                <dbl>    <dbl>
#> 1 Derrick Whitmore         1        7
#> 2 Derrick Whitmore         2       10
#> 3 Derrick Whitmore         3       10
#> 4 Katherine Burke          1        4
#> Doing this is sometimes called "last observation carried forward" or locf. 
#> You can use the .direction argument to fill in missing values that have been
#> generated in more exotic ways. 
#> 
#> 
#> Fixed Values: 
#> 
#> Some times missing values represent some fixed and known value, most commonly 
#> 0. You can use dplyr::coalesce() to replace them. 
#> 
x <- c(1, 4, 5, 7, NA)
coalesce(x, 0)
#> [1] 1 4 5 7 0

#> Sometimes you'll hit the opposite problem where some concrete value actually
#> represents a missing value. This sometimes happens with older data files that
#> don't know how to represent a missing value so they use something like 99 or 
#> -999 
#> 
#> If possible, handle this problem when reading the date file. 
#> readr::read_csv() e.g. read_csv(path, na = "99")
#> If you discover the problem later on, you can use dplyr::na_if() to solve it. 
#> 
x <- c(1, 4, 5, 7, -99)
na_if(x, -99)
#> [1]  1  4  5  7 NA
#> 
#> There's one special type of missing value that you'll encounter from time to 
#> time: a NaN (prounaounced "nan") 
#> not a number. 
#> It generally behaves just like NA 
x <- c(NA, NaN)
x * 10
#> [1]  NA NaN
x == 1
#> [1] NA NA
is.na(x)
#> [1] TRUE TRUE
#> 
#> In the rare case that you need to distinguish it from NA ou can use 
#> is.nan()
#> In general, you'll encounter these when you perform a mathematical operation
#> that has an indeterminate result: 
0 / 0 
#> [1] NaN
0 * Inf
#> [1] NaN
Inf - Inf
#> [1] NaN
sqrt(-1)
#> Warning in sqrt(-1): NaNs produced
#> [1] NaN

#> Implicit Missing Values ------- 
#> 
#> If an entire row of data is simply absent from the data. 
stocks <- tibble(
  year  = c(2020, 2020, 2020, 2020, 2021, 2021, 2021),
  qtr   = c(   1,    2,    3,    4,    2,    3,    4),
  price = c(1.88, 0.59, 0.35,   NA, 0.92, 0.17, 2.66)
)
#> This data set has two missing observations: 
#> The price in the fourth quarter of 2020, because its value is NA. 
#> AND the price for the first quarter of 2021, because it simply does not appear
#> 
#> An explicit missing value is the presence of absence 
#> An implicit missing value is the absence of presence 
#> 
#> Pivoting 
#> 
#> Making data wider can make implicit missing values explicit because every 
#> combination of the rows and new columns must have some value. 
stocks |>
  pivot_wider(
    names_from = qtr, 
    values_from = price
  )
#> # A tibble: 2 × 5
#>    year   `1`   `2`   `3`   `4`
#>   <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1  2020  1.88  0.59  0.35 NA   
#> 2  2021 NA     0.92  0.17  2.66
#> 
#> By default, making data longer preserves explicit missing values, but if they 
#> are structurally missing values that only exist because the data is not tidy,
#> you can drop them (make them implicit) by setting values_drop_na = TRUE 
#> 
#> Complete 
#> 
#> tidyr::complete() allows you to generate explicity missing values by providing
#> a set of variable that define the combinatin of rows that should exist. 
#> For example, we know that all combinations of year and qtr should exist in the
#> stocks data: 
stocks |>
  complete(year, qtr)
#> # A tibble: 8 × 3
#>    year   qtr price
#>   <dbl> <dbl> <dbl>
#> 1  2020     1  1.88
#> 2  2020     2  0.59
#> 3  2020     3  0.35
#> 4  2020     4 NA   
#> 5  2021     1 NA   
#> 6  2021     2  0.92
#> # ℹ 2 more rows
#> 
#> Typically, you'll call complete() with names of existing variables, filling 
#> in the missing combinations. However, sometimes the individual variables are
#> themselves incomplete, so you can instead provide your own data. 
#> For example, you might know the stocks data set is supposed to run from
#> 2019 to 201, so you could explicity state that: 
stocks |>
  complete(year = 2019:2021, qtr)
#> # A tibble: 12 × 3
#>    year   qtr price
#>   <dbl> <dbl> <dbl>
#> 1  2019     1 NA   
#> 2  2019     2 NA   
#> 3  2019     3 NA   
#> 4  2019     4 NA   
#> 5  2020     1  1.88
#> 6  2020     2  0.59
#> # ℹ 6 more rows
#> 
#> If the range of a variable is correct, but not all values are present, you 
#> could use full_seq(x, 1) to generate all values from min(x) to max(x) spaced
#> out by 1. 
#> 
#> Joins 
#> 
#> You can often only know that values are missing from one data set when you 
#> compare it to another. 
#> 
#> dplyr::anti_join(x, y) is a particularly useful tool here because it selects
#> only the rows in x that don't have a match in y. 
#> For example, we can use two anti_join()s to reveal that we're missing info
#> for four airports and 722 plans mentioned in flights
library(nycflights13)

flights |> 
  distinct(faa = dest) |> 
  anti_join(airports)
#> Joining with `by = join_by(faa)`
#> # A tibble: 4 × 1
#>   faa  
#>   <chr>
#> 1 BQN  
#> 2 SJU  
#> 3 STT  
#> 4 PSE

flights |> 
  distinct(tailnum) |> 
  anti_join(planes)
#> Joining with `by = join_by(tailnum)`
#> # A tibble: 722 × 1
#>   tailnum
#>   <chr>  
#> 1 N3ALAA 
#> 2 N3DUAA 
#> 3 N542MQ 
#> 4 N730MQ 
#> 5 N9EAMQ 
#> 6 N532UA 
#> # ℹ 716 more rows


#> Factors and Empty Groups -----

#> A group that doesn't contain any observations. Which can happen when working
#> with factors. 
#> 
health <- tibble(
  name   = c("Ikaia", "Oletta", "Leriah", "Dashay", "Tresaun"),
  smoker = factor(c("no", "no", "no", "no", "no"), levels = c("yes", "no")),
  age    = c(34, 88, 75, 47, 56),
)
#> Now we want to count the number of smokers with dplyr::count()
health |> count(smoker)
#> # A tibble: 1 × 2
#>   smoker     n
#>   <fct>  <int>
#> 1 no         5
#> 
#> The data set only contains non-smokers, but we know that smokers exist; the 
#> group of non-smoker is empty. We can request count() to keep all the groups,
#> even those not seen in the data by using .drop = FALSE: 

health |> count(smoker, .drop = FALSE)
#> # A tibble: 2 × 2
#>   smoker     n
#>   <fct>  <int>
#> 1 yes        0
#> 2 no         5

#> The same principle applies to ggplot2's discrete axes, which will also drop
#> levels that dn't have any values. You can force them to display by supplying
#> drop = FALSE to the appropriate discrete axis. 
#> 
ggplot(health, aes(x = smoker)) +
  geom_bar() +
  scale_x_discrete()

ggplot(health, aes(x = smoker)) +
  geom_bar() +
  scale_x_discrete(drop = FALSE)

#> The same problem comes up more genrally with dplyr::group_by() 
#> You can again use .drop = FALSE to retain empty groups. 
health |> 
  group_by(smoker, .drop = FALSE) |> 
  summarize(
    n = n(),
    mean_age = mean(age),
    min_age = min(age),
    max_age = max(age),
    sd_age = sd(age)
  )
#> # A tibble: 2 × 6
#>   smoker     n mean_age min_age max_age sd_age
#>   <fct>  <int>    <dbl>   <dbl>   <dbl>  <dbl>
#> 1 yes        0      NaN     Inf    -Inf   NA  
#> 2 no         5       60      34      88   21.6
#> 
#> We get some interesting results here because when we summarize an empty group
#> we are summarizing a zero-length vector. 
#> 
#> There is an important distinction between empty vectors, which have length 0,
#> and missing values, each of which has length 1. 
# A vector containing two missing values
x1 <- c(NA, NA)
length(x1)
#> [1] 2

# A vector containing nothing
x2 <- numeric()
length(x2)
#> [1] 0

#> Sometimes a simple approach is to perform the summary and then make the 
#> implicit missing values explicit with complete() 
health |> 
  group_by(smoker) |> 
  summarize(
    n = n(),
    mean_age = mean(age),
    min_age = min(age),
    max_age = max(age),
    sd_age = sd(age)
  ) |> 
  complete(smoker)
#> # A tibble: 2 × 6
#>   smoker     n mean_age min_age max_age sd_age
#>   <fct>  <int>    <dbl>   <dbl>   <dbl>  <dbl>
#> 1 yes       NA       NA      NA      NA   NA  
#> 2 no         5       60      34      88   21.6
#> Although, doing this gives you a NA for the count when you know it should be
#> zero. 
#> 




