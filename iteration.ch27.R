### R for Data Science 
#Second Edition: Chapter 27, Iteration          

#Restart the console to start fresh! 
#ctrl + shift + F10 

library(tidyverse) 


#> Iteration  repeatedly performing the same action on different objects 
#> Iteration in R generally looks different than in other programming languages. 
#> 
#> We have already seen a few tools that perform the same action for multiple
#> things: 
#> facet_wrap() and facet_grid() 
#> group_by() and summarize() 
#> unnest_wider() and unnest_longer() 
#> 
#> Now we will learn some more general tools, often called functional programming
#> tools. 
#> They are built around functions that take other functions as inputs. 
#> 
#> We will focus on three common tasks: modifying multiple columns, reading 
#> multiple files, and saving multiple objects 
#> 
#> We will learn a bit about the purrr package from the tidyverse. This is a great
#> package to explore as you improve your programming skills. 
#> 
#> Modifying Multiple Columns ------
#> 
#> You have this simple tibble and you want to compute n and median of every column
df <- tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)
#> You could do this with copy and paste: 
df |> summarize(
  n = n(),
  a = median(a),
  b = median(b),
  c = median(c),
  d = median(d),
)
#> This breaks our rule of thumb to never copy and paste more than twice! 
#> You can also imagine that this will get very tedious. 
#> 
#> Instead you can use across: 
df |> summarize(
  n = n(),
  across(a:d, median),
)

#> across() has three important arguments. 
#> You'll use the first two every time you use across: 
#> the first argument .cols, specifies which columns you want to iterate over 
#> the second argument, .fns, specifies what to do with each column.
#> You can use the .names argument when you need additional control over the 
#> names of output columns. This is important when you use across() with mutate()
#> 
#> Two important variations, if_any() and if_all(), which work with filter() 
#> 
#> Selecting Columns with .cols 
#> This argument uses the same specifications as select() (chapter 4.3.2), so you
#> can use functions like starts_with() and ends_with() to select columns based
#> on their name. 
#> everything() and where() are also particularly useful here. 
#> everything() is straightforward: it selects every (non-grouping) column: 
df <- tibble(
  grp = sample(2, 10, replace = TRUE),
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)

df |> 
  group_by(grp) |> 
  summarize(across(everything(), median))
#> # A tibble: 2 × 5
#>     grp       a       b     c     d
#>   <int>   <dbl>   <dbl> <dbl> <dbl>
#> 1     1 -0.0935 -0.0163 0.363 0.364
#> 2     2  0.312  -0.0576 0.208 0.565


#> where() allows you to select columns based on their type: 
#> where(is.numeric)
#> where(is.character)
#> where(is.Date)
#> where(is.POSIXct) - date-time columns 
#> where(is.logical)
#> 
#> Just like other selectors, you can combine these with Boolean algebra. 
#> !where(is.numeric) selects all non-numeric columns. 
#> starts_with("a") & where(is.logical) selects all logical columns whose name 
#> starts with "a" 
#> 
#> Calling a single function 
#> 
#> The second argument to across() defines how each column will be transformed 
#> In simple cases, this will be a single existing function. 
#> This is a pretty special feature of R: we're passing one function (mean, median,
#> str_flatten,...) to another function (across). This is one of the features
#> that makes R a functional programming language. 
#> 
df |> 
  group_by(grp) |> 
  summarize(across(everything(), median()))
#> Error in `summarize()`:
#> ℹ In argument: `across(everything(), median())`.
#> Caused by error in `is.factor()`:
#> ! argument "x" is missing, with no default
#> 
#> The above error occurs because you're calling a function with no input, e.g.:
median()
#> Error in is.factor(x): argument "x" is missing, with no default

#> Calling multiple functions 
#> Sometimes you might want to supply additional arguments or perform multiple
#> transformations. 
#> Here is an example with some missing values in our data. 
rnorm_na <- function(n, n_na, mean = 0, sd = 1) {
  sample(c(rnorm(n - n_na, mean = mean, sd = sd), rep(NA, n_na)))
}

df_miss <- tibble(
  a = rnorm_na(5, 1),
  b = rnorm_na(5, 1),
  c = rnorm_na(5, 2),
  d = rnorm(5)
)
df_miss |> 
  summarize(
    across(a:d, median),
    n = n()
  )
#> # A tibble: 1 × 5
#>       a     b     c     d     n
#>   <dbl> <dbl> <dbl> <dbl> <int>
#> 1    NA    NA    NA  1.15     5

#> To remove missing values we need to create a new function that calls median()
#> with the desired arguments:
df_miss |> 
  summarize(
    across(a:d, function(x) median(x, na.rm = TRUE)),
    n = n()
  )
#> This is a little verbose, so R comes with a handy shortcut: for this throw 
#> away, or anonymous function, you can replace function with \ 
df_miss |> 
  summarize(
    across(a:d, \(x) median(x, na.rm = TRUE)),
    n = n()
  )
#> In either case, across() effectively expands to the following code: 
df_miss |> 
  summarize(
    a = median(a, na.rm = TRUE),
    b = median(b, na.rm = TRUE),
    c = median(c, na.rm = TRUE),
    d = median(d, na.rm = TRUE),
    n = n()
  )

#> When we remove the missing values fromt he median(), it would be nice to know
#> just how many values were removed. 
#> We can do this with the following code: 
df_miss |> 
  summarize(
    across(a:d, list(
      median = \(x) median(x, na.rm = TRUE),
      n_miss = \(x) sum(is.na(x))
    )),
    n = n()
  )
#> # A tibble: 1 × 9
#>   a_median a_n_miss b_median b_n_miss c_median c_n_miss d_median d_n_miss
#>      <dbl>    <int>    <dbl>    <int>    <dbl>    <int>    <dbl>    <int>
#> 1    0.139        1    -1.11        1   -0.387        2     1.15        0
#> # ℹ 1 more variable: n <int>

#> Column names 
#> 
#> The result of across() is named according to the specification provided in the
#> .names argument. We could specify our own if we wanted the name of the function
#> to come first: 
df_miss |> 
  summarize(
    across(
      a:d,
      list(
        median = \(x) median(x, na.rm = TRUE),
        n_miss = \(x) sum(is.na(x))
      ),
      .names = "{.fn}_{.col}"
    ),
    n = n(),
  )

#> By default the output of across() is given the same names as the inputs. This
#> means that across() inside of mutate() will replace existing column names. 
#> For example, here we use coalesce() to replace NA's with 0: 
df_miss |> 
  mutate(
    across(a:d, \(x) coalesce(x, 0))
  )
#> # A tibble: 5 × 4
#>        a      b      c     d
#>    <dbl>  <dbl>  <dbl> <dbl>
#> 1  0.434 -1.25   0     1.60 
#> 2  0     -1.43  -0.297 0.776
#> 3 -0.156 -0.980  0     1.15 
#> 4 -2.61  -0.683 -0.785 2.13 
#> 5  1.11   0     -0.387 0.704
#>
#>If you'd like to instead create new columns, you can use the .names argument to
#>give the output new names: 
df_miss |> 
  mutate(
    across(a:d, \(x) abs(x), .names = "{.col}_abs")
  )
#> # A tibble: 5 × 8
#>        a      b      c     d  a_abs  b_abs  c_abs d_abs
#>    <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl>
#> 1  0.434 -1.25  NA     1.60   0.434  1.25  NA     1.60 
#> 2 NA     -1.43  -0.297 0.776 NA      1.43   0.297 0.776
#> 3 -0.156 -0.980 NA     1.15   0.156  0.980 NA     1.15 
#> 4 -2.61  -0.683 -0.785 2.13   2.61   0.683  0.785 2.13 
#> 5  1.11  NA     -0.387 0.704  1.11  NA      0.387 0.704
#> 
#> Filtering 
#> across() is a great match for summarize() and mutate() but its more awkward
#> with filter(). 
#> dplyr provides two variants of across, if_any() and if_all() to help here. 
#> 
# same as df_miss |> filter(is.na(a) | is.na(b) | is.na(c) | is.na(d))
df_miss |> filter(if_any(a:d, is.na))
#> # A tibble: 4 × 4
#>        a      b      c     d
#>    <dbl>  <dbl>  <dbl> <dbl>
#> 1  0.434 -1.25  NA     1.60 
#> 2 NA     -1.43  -0.297 0.776
#> 3 -0.156 -0.980 NA     1.15 
#> 4  1.11  NA     -0.387 0.704

# same as df_miss |> filter(is.na(a) & is.na(b) & is.na(c) & is.na(d))
df_miss |> filter(if_all(a:d, is.na))
#> # A tibble: 0 × 4
#> # ℹ 4 variables: a <dbl>, b <dbl>, c <dbl>, d <dbl>

#> across() in functions 
#> across() is particularly useful here because it allows you to operate on 
#> multiple columns. 
#> 
#> This code wraps a bunch of lubridate function to expand all date columns
#> into year, month, and day columns:

expand_dates <- function(df) {
  df |> 
    mutate(
      across(where(is.Date), list(year = year, month = month, day = mday))
    )
}

df_date <- tibble(
  name = c("Amy", "Bob"),
  date = ymd(c("2009-08-03", "2010-01-16"))
)

df_date |> 
  expand_dates()
#> # A tibble: 2 × 5
#>   name  date       date_year date_month date_day
#>   <chr> <date>         <dbl>      <dbl>    <int>
#> 1 Amy   2009-08-03      2009          8        3
#> 2 Bob   2010-01-16      2010          1       16

#> this function will compute the means of numeric columns by default. 
#> But by supplying the second argument you can choose to summarize just selected
#> columns: 
summarize_means <- function(df, summary_vars = where(is.numeric)) {
  df |> 
    summarize(
      across({{ summary_vars }}, \(x) mean(x, na.rm = TRUE)),
      n = n()
    )
}
diamonds |> 
  group_by(cut) |> 
  summarize_means()
#> # A tibble: 5 × 9
#>   cut       carat depth table price     x     y     z     n
#>   <ord>     <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <int>
#> 1 Fair      1.05   64.0  59.1 4359.  6.25  6.18  3.98  1610
#> 2 Good      0.849  62.4  58.7 3929.  5.84  5.85  3.64  4906
#> 3 Very Good 0.806  61.8  58.0 3982.  5.74  5.77  3.56 12082
#> 4 Premium   0.892  61.3  58.7 4584.  5.97  5.94  3.65 13791
#> 5 Ideal     0.703  61.7  56.0 3458.  5.51  5.52  3.40 21551

diamonds |> 
  group_by(cut) |> 
  summarize_means(c(carat, x:z))
#> # A tibble: 5 × 6
#>   cut       carat     x     y     z     n
#>   <ord>     <dbl> <dbl> <dbl> <dbl> <int>
#> 1 Fair      1.05   6.25  6.18  3.98  1610
#> 2 Good      0.849  5.84  5.85  3.64  4906
#> 3 Very Good 0.806  5.74  5.77  3.56 12082
#> 4 Premium   0.892  5.97  5.94  3.65 13791
#> 5 Ideal     0.703  5.51  5.52  3.40 21551


#> across() versus pivot_longer()
#> In many cases, you perform the same calculations by first pivoting the data
#> and then performing the operations by group rather than by column. 
#> For example, take this multi-function summary:
df |> 
  summarize(across(a:d, list(median = median, mean = mean)))
#> # A tibble: 1 × 8
#>   a_median a_mean b_median b_mean c_median c_mean d_median d_mean
#>      <dbl>  <dbl>    <dbl>  <dbl>    <dbl>  <dbl>    <dbl>  <dbl>
#> 1   0.0380  0.205  -0.0163 0.0910    0.260 0.0716    0.540  0.508

#> We could compute the same values by pivoting longer and then summarizing: 
long <- df |> 
  pivot_longer(a:d) |> 
  group_by(name) |> 
  summarize(
    median = median(value),
    mean = mean(value)
  )
long
#> # A tibble: 4 × 3
#>   name   median   mean
#>   <chr>   <dbl>  <dbl>
#> 1 a      0.0380 0.205 
#> 2 b     -0.0163 0.0910
#> 3 c      0.260  0.0716
#> 4 d      0.540  0.508
#> 
#> And if you wanted the same structure as across(), you could pivot again: 
long |> 
  pivot_wider(names_from = name,
              values_from = c(median, mean),
              names_vary = "slowest",
              names_glue = "{name}_{.value}"
  )


#> This is useful to know because sometimes you'll hit a problem that's not 
#> currently possible to solve with across(): when you have groups of columns 
#> that you want to compute with simultaneously. 
#> For example, imagine that our data frame contains both values and weights and
#> we want to compute a weighted mean: 
df_paired <- tibble(
  a_val = rnorm(10),
  a_wts = runif(10),
  b_val = rnorm(10),
  b_wts = runif(10),
  c_val = rnorm(10),
  c_wts = runif(10),
  d_val = rnorm(10),
  d_wts = runif(10)
)
#> Can't do this with across() but its pretty simple with pivot_longer() 
df_long <- df_paired |> 
  pivot_longer(
    everything(), 
    names_to = c("group", ".value"), 
    names_sep = "_"
  )
df_long
#> # A tibble: 40 × 3
#>   group    val   wts
#>   <chr>  <dbl> <dbl>
#> 1 a      0.715 0.518
#> 2 b     -0.709 0.691
#> 3 c      0.718 0.216
#> 4 d     -0.217 0.733
#> 5 a     -1.09  0.979
#> 6 b     -0.209 0.675
#> # ℹ 34 more rows

df_long |> 
  group_by(group) |> 
  summarize(mean = weighted.mean(val, wts))
#> # A tibble: 4 × 2
#>   group    mean
#>   <chr>   <dbl>
#> 1 a      0.126 
#> 2 b     -0.0704
#> 3 c     -0.360 
#> 4 d     -0.248
#> 
#> If needed, you could pivot_wider() this back to the original form 
#> 
#> 
#> Reading Multiple Files -----
#> 
#> purrr::map() is very useful when working with files in a directory. 
#> Imagine you have a directory full of excel spreadsheets you want to read. 
#> Could do that with copy and paste: 
data2019 <- readxl::read_excel("data/y2019.xlsx")
data2020 <- readxl::read_excel("data/y2020.xlsx")
data2021 <- readxl::read_excel("data/y2021.xlsx")
data2022 <- readxl::read_excel("data/y2022.xlsx")

#> And then use dplyr::bind_rows() to combine them all together: 
data <- bind_rows(data2019, data2020, data2021, data2022)

#> This gets tedious fast, especially when you have hundreds of files. 
#> We can automate this though: 
#> 
#> Listing files in a directory
#> 
#> list.files() lists the files in a directory. You'll almost always use three 
#> arguments: 
#> path is the directory to look in 
#> pattern is a regular expression used to filter the file names. The most common
#> pattern is something like [.]xlsx$ or [.]csv$ to find all files with a specified 
#> extension 
#> full.names determines whether or not the directory name should be included
#> in the output. You almost always want this to be TRUE. 
#> 
#> We can use the gapminder data as an example: 
paths <- list.files("data/gapminder", pattern = "[.]xlsx$", full.names = TRUE)
paths
#>  [1] "data/gapminder/1952.xlsx" "data/gapminder/1957.xlsx"
#>  [3] "data/gapminder/1962.xlsx" "data/gapminder/1967.xlsx"
#>  [5] "data/gapminder/1972.xlsx" "data/gapminder/1977.xlsx"
#>  [7] "data/gapminder/1982.xlsx" "data/gapminder/1987.xlsx"
#>  [9] "data/gapminder/1992.xlsx" "data/gapminder/1997.xlsx"
#> [11] "data/gapminder/2002.xlsx" "data/gapminder/2007.xlsx"

#> Now that we have these 12 paths, we could call read_excel() 12 times to get
#> all of our data. 
#> Its easiest to put them in a single object as a list: 
files <- list(
  readxl::read_excel("data/gapminder/1952.xlsx"),
  readxl::read_excel("data/gapminder/1957.xlsx"),
  readxl::read_excel("data/gapminder/1962.xlsx"),
  ...,
  readxl::read_excel("data/gapminder/2007.xlsx")
)

#> Now that you have these files in a list you can use files[[i]] to extract the
#> i-th element. 
files[[3]]


#> purrr::map() and list_rbind() 
#> 
#> The code to collect those data frames in a list "by hand" is just as tedious
#> as typing them all out. 
#> using purrr::map()'s paths vector we can do this easier. 
#> map() is similar to across(), but instead of doing something to each column in 
#> data frame, it does something to each element of a vector map(x, f) is shorthand
#> for:
list(
  f(x[[1]]),
  f(x[[2]]),
  ...,
  f(x[[n]])
)
#> So we can use map() to get a list of all 12 data frames: 
files <- map(paths, readxl::read_excel)
length(files)
#> [1] 12

files[[1]]
#> # A tibble: 142 × 5
#>   country     continent lifeExp      pop gdpPercap
#>   <chr>       <chr>       <dbl>    <dbl>     <dbl>
#> 1 Afghanistan Asia         28.8  8425333      779.
#> 2 Albania     Europe       55.2  1282697     1601.
#> 3 Algeria     Africa       43.1  9279525     2449.
#> 4 Angola      Africa       30.0  4232095     3521.
#> 5 Argentina   Americas     62.5 17876956     5911.
#> 6 Australia   Oceania      69.1  8691212    10040.
#> # ℹ 136 more rows

#> Next we can use purrr::list_bind() to combine that list of data frames into
#> a single data frame: 
list_rbind(files)

#> Or we could do both steps at once in a pipeline: 
paths |> 
  map(\(path) readxl::read_excel(path, n_max = 1)) |> 
  list_rbind()
#> # A tibble: 12 × 5
#>   country     continent lifeExp      pop gdpPercap
#>   <chr>       <chr>       <dbl>    <dbl>     <dbl>
#> 1 Afghanistan Asia         28.8  8425333      779.
#> 2 Afghanistan Asia         30.3  9240934      821.
#> 3 Afghanistan Asia         32.0 10267083      853.
#> 4 Afghanistan Asia         34.0 11537966      836.
#> 5 Afghanistan Asia         36.1 13079460      740.
#> 6 Afghanistan Asia         38.4 14880372      786.
#> # ℹ 6 more rows
#> 
#> This makes it clear that we have a problem here because there is no year 
#> column, that information is included in the path itself, not in the individual
#> files. 
#> 
#> Data in the path 
#> 
#> sometimes the name of the file is data itself. 
#> To get that data into the final data frame, we need to do two things: 
#> First, we name the vector of paths. The easiest way to do this is with 
#> set_names() function, which can take a function. Here we use basename() 
#> to extract just the file name from the full path: 
paths |> set_names(basename) 
#>                  1952.xlsx                  1957.xlsx 
#> "data/gapminder/1952.xlsx" "data/gapminder/1957.xlsx" 
#>                  1962.xlsx                  1967.xlsx 
#> "data/gapminder/1962.xlsx" "data/gapminder/1967.xlsx" 
#>                  1972.xlsx                  1977.xlsx 
#> "data/gapminder/1972.xlsx" "data/gapminder/1977.xlsx" 
#>                  1982.xlsx                  1987.xlsx 
#> "data/gapminder/1982.xlsx" "data/gapminder/1987.xlsx" 
#>                  1992.xlsx                  1997.xlsx 
#> "data/gapminder/1992.xlsx" "data/gapminder/1997.xlsx" 
#>                  2002.xlsx                  2007.xlsx 
#> "data/gapminder/2002.xlsx" "data/gapminder/2007.xlsx"
#> 
#> Those names are automatically carried along by all the map functions, so the 
#> list of data frames will have those same names: 
files <- paths |> 
  set_names(basename) |> 
  map(readxl::read_excel)

#> The above code is shorthand for: 
files <- list(
  "1952.xlsx" = readxl::read_excel("data/gapminder/1952.xlsx"),
  "1957.xlsx" = readxl::read_excel("data/gapminder/1957.xlsx"),
  "1962.xlsx" = readxl::read_excel("data/gapminder/1962.xlsx"),
  ...,
  "2007.xlsx" = readxl::read_excel("data/gapminder/2007.xlsx")
)

#> You can also use [[]] to extract elements by name: 
files[["1962.xlsx"]]

#> Then we use the names_to argument to list_rbind() to tell it so save the names
#> into a new column called year then use readr::parse_number() to extract the 
#> number from the string: 
paths |> 
  set_names(basename) |> 
  map(readxl::read_excel) |> 
  list_rbind(names_to = "year") |> 
  mutate(year = parse_number(year))


#> If there is more complex data or multiple bits of data in the path you can 
#> use things such as the following:
paths |> 
  set_names() |> 
  map(readxl::read_excel) |> 
  list_rbind(names_to = "year") |> 
  separate_wider_delim(year, delim = "/", names = c(NA, "dir", "file")) |> 
  separate_wider_delim(file, delim = ".", names = c("file", "ext"))

#> Save your work! 
gapminder <- paths |> 
  set_names(basename) |> 
  map(readxl::read_excel) |> 
  list_rbind(names_to = "year") |> 
  mutate(year = parse_number(year))

write_csv(gapminder, "gapminder.csv")

#> Might be best to save this as a parquet file depending on its size and use. 
#> If you're working on a project, we'd suggest calling the file that does this
#> sort of prep work something like 0-cleanup.R. 
#> the 0 in the file name suggest that this should be run before anything else
#> 
#> If your input data files change over time, you might consider learning a tool
#> like targets (see link in textbook) to setup your data cleaning code to 
#> automatically re-run whenever one of the input files is modified. 
#> 
#> Many Simple Iterations 
#> 
#> When we loaded in all of these data frames we were lucky enough to get a 
#> tidy data set at load in. 
#> That typically isn't the case and you will typically need to do more tidying.
#> You  have two basic options:
#> one round of iteration with a complex function
#> multiple rounds of iteration with simple functions 
#> They suggest multiple rounds of iteration with simple functions 
#> 
#> Imagine you want to read in a bunch of files, filter out missing values, pivot,
#> and then combine. One way to approach the problem is to write a function that
#> takes a file and does all those steps then call map() once:
process_file <- function(path) {
  df <- read_csv(path)
  
  df |> 
    filter(!is.na(id)) |> 
    mutate(id = tolower(id)) |> 
    pivot_longer(jan:dec, names_to = "month")
}

paths |> 
  map(process_file) |> 
  list_rbind()

#> Alternatively, you could perform each step of process_file() to every file: 
paths |> 
  map(read_csv) |> 
  map(\(df) df |> filter(!is.na(id))) |> 
  map(\(df) df |> mutate(id = tolower(id))) |> 
  map(\(df) df |> pivot_longer(jan:dec, names_to = "month")) |> 
  list_rbind()
#> They recommend this alternative because it stops you from getting fixated on
#> getting the first file right before moving on to the rest. 
#> 
#> In this particular example, the code could be further improved by binding 
#> all of the data frames together earlier and then you can rely on regular
#> dplyr behavior: 
paths |> 
  map(read_csv) |> 
  list_rbind() |> 
  filter(!is.na(id)) |> 
  mutate(id = tolower(id)) |> 
  pivot_longer(jan:dec, names_to = "month")


#> Heterogeneous data 
#> occasionally it is impossible to go from map() to list_rbind() because the 
#> data frames are so heterogeneous that the process fails, or yields a useless
#> data frame. 
#> 
#> In that case, its still useful to start by loading all of the files: 
files <- paths |> 
  map(readxl::read_excel) 

#> A useful strategy from here is to use this handy df_types function that 
#> returns a tibble with one row for each column: 
df_types <- function(df) {
  tibble(
    col_name = names(df), 
    col_type = map_chr(df, vctrs::vec_ptype_full),
    n_miss = map_int(df, \(x) sum(is.na(x)))
  )
}

df_types(gapminder)
#> # A tibble: 6 × 3
#>   col_name  col_type  n_miss
#>   <chr>     <chr>      <int>
#> 1 year      double         0
#> 2 country   character      0
#> 3 continent character      0
#> 4 lifeExp   double         0
#> 5 pop       double         0
#> 6 gdpPercap double         0

#> You could apply this function to all of the files and perhaps do some pivoting
#> to make it more clear where things are weird. 
#> 
#> This makes it pretty clear that the gapminder data we have been working with 
#> are quite homogenous:
files |> 
  map(df_types) |> 
  list_rbind(names_to = "file_name") |> 
  select(-n_miss) |> 
  pivot_wider(names_from = col_name, values_from = col_type)
#> # A tibble: 12 × 6
#>   file_name country   continent lifeExp pop    gdpPercap
#>   <chr>     <chr>     <chr>     <chr>   <chr>  <chr>    
#> 1 1952.xlsx character character double  double double   
#> 2 1957.xlsx character character double  double double   
#> 3 1962.xlsx character character double  double double   
#> 4 1967.xlsx character character double  double double   
#> 5 1972.xlsx character character double  double double   
#> 6 1977.xlsx character character double  double double   
#> # ℹ 6 more rows
#> 
#> If they aren't looking good, you will have to figure out how to handle that 
#> yourself. 
#> But, map_if() and map_at() can be helpful functions 
#> 
#> Handling failures 
#> 
#> When map() failes purrr comes with a helper to tackle problems. 
#> pissibly() is what's known as a function operator: it takes a function and 
#> returns a function with modified behavior. In particular, possibly() changes 
#> a function from erroring to returning a value that you specify: 
files <- paths |> 
  map(possibly(\(path) readxl::read_excel(path), NULL))

data <- files |> list_rbind()
#> This works particularly well because list_rbind() automatically ignores NULL
#> 
#> Now that you have all the data that can be read easily, its time to tackle the
#> hard part of figuring out why some files failed to load and what to do about 
#> it. 
#> Start by getting the paths that failed:
failed <- map_vec(files, is.null)
paths[failed]
#> character(0)
#> 
#> Then call the import function again for each failure and figure out what
#> went wrong.
#> 
#> Saving Multiple Columns -------
#> 
#> How can you take one or more R objects and save it to one or more files? 
#> 
#> Three examples: 
#> saving multiple data frames into one database 
#> saving multiple data frames into multiple .csv files 
#> saving multiple plots to multiple .png files 
#> 
#> Writing to database 
#> 
#> Sometimes when you are working with many files it isn't possible to load them
#> all into memory at once. One fix to this is to load them into a database 
#> so you can just access what you need at one time. 
#> 
#> 
#> First we will see how to load a bunch of files in by hand.
#> We need to start by creating a table that will fill in with data. The easiest
#> way to do this is by creating a template, a dummy data frame that contains
#> all the columns we want, but only a sampling of the data. 
#> For the gapminder data, we can make that template by reading a single file 
#> and adding the year to it: 
template <- readxl::read_excel(paths[[1]])
template$year <- 1952
template
#> # A tibble: 142 × 6
#>   country     continent lifeExp      pop gdpPercap  year
#>   <chr>       <chr>       <dbl>    <dbl>     <dbl> <dbl>
#> 1 Afghanistan Asia         28.8  8425333      779.  1952
#> 2 Albania     Europe       55.2  1282697     1601.  1952
#> 3 Algeria     Africa       43.1  9279525     2449.  1952
#> 4 Angola      Africa       30.0  4232095     3521.  1952
#> 5 Argentina   Americas     62.5 17876956     5911.  1952
#> 6 Australia   Oceania      69.1  8691212    10040.  1952
#> # ℹ 136 more rows
#> 
#> Now we can connect to the database, and use DBI::dbCreateTable() to turn our
#> template into a database table: 
con <- DBI::dbConnect(duckdb::duckdb())
DBI::dbCreateTable(con, "gapminder", template)
#> When we do this dbCreateTable doesn't use the data in template, just the 
#> variable names and types. 
#> If we inspect it we will see exactly that: 
con |> tbl("gapminder")
#> # Source:   table<gapminder> [0 x 6]
#> # Database: DuckDB 0.7.1 [unknown@Linux 5.15.0-1035-azure:R 4.2.3/:memory:]
#> # ℹ 6 variables: country <chr>, continent <chr>, lifeExp <dbl>, pop <dbl>,
#> #   gdpPercap <dbl>, year <dbl>

#> Next we need a function that takes a single file path, reads it into R, and 
#> adds the result to the gapminder table. We can do that by combining read_excel()
#> with DBI::dbAppendTable 
append_file <- function(path) {
  df <- readxl::read_excel(path)
  df$year <- parse_number(basename(path))
  
  DBI::dbAppendTable(con, "gapminder", df)
}

#>Next we need to call append_file() once for each element of paths. That's 
#>certainly possible with map():
paths |> map(append_file)

#> Now we can see if we have all the data in our table: 
con |> 
  tbl("gapminder") |> 
  count(year)
#> # Source:   SQL [?? x 2]
#> # Database: DuckDB 0.7.1 [unknown@Linux 5.15.0-1035-azure:R 4.2.3/:memory:]
#>    year     n
#>   <dbl> <dbl>
#> 1  1952   142
#> 2  1957   142
#> 3  1962   142
#> 4  1967   142
#> 5  1972   142
#> 6  1977   142
#> # ℹ more rows
#> 

#> Writing CSV files
#> 
#> The same principles apply if we want to write multiple csv files, one for 
#> each group. 
#> Lets imagine we want to take the ggplot2::diamonds data and save one csv file
#> for each clarity. 
#> First we need to make these individual data sets: 
by_clarity <- diamonds |> 
  group_nest(clarity)

by_clarity
#> # A tibble: 8 × 2
#>   clarity               data
#>   <ord>   <list<tibble[,9]>>
#> 1 I1               [741 × 9]
#> 2 SI2            [9,194 × 9]
#> 3 SI1           [13,065 × 9]
#> 4 VS2           [12,258 × 9]
#> 5 VS1            [8,171 × 9]
#> 6 VVS2           [5,066 × 9]
#> # ℹ 2 more rows
#> 
#> This gives us a new tibble with eight rows and two columns. clarity is our
#> grouping variable and data is a list-colu,mn containing one tibble for each 
#> unique value of clarity 
by_clarity$data[[1]]

#> While we're here, let's create a column that gives the name of output file 
#> using mutate() and str_glue(): 
by_clarity <- by_clarity |> 
  mutate(path = str_glue("diamonds-{clarity}.csv"))

by_clarity

#> So if we were going to save these by hand we might give something like: 
write_csv(by_clarity$data[[1]], by_clarity$path[[1]])
write_csv(by_clarity$data[[2]], by_clarity$path[[2]])
write_csv(by_clarity$data[[3]], by_clarity$path[[3]])
...
write_csv(by_clarity$by_clarity[[8]], by_clarity$path[[8]])

#> This is a bit different than our previous use of map()
#> because there are two arguments that are changing, not just one. 
#> This means we need a new function, map2(), which varies both the first and 
#> second arguments. But because we again don't care about the output, we want
#> walk2() rather than map2() 
walk2(by_clarity$data, by_clarity$path, write_csv)

#> Saving Plots 
#> 
#> We can take the same basic approach to create many plot. First lets make a 
#> function that draws the plot we want: 
carat_histogram <- function(df) {
  ggplot(df, aes(x = carat)) + geom_histogram(binwidth = 0.1)  
}

carat_histogram(by_clarity$data[[1]])

#> Now we can  use map() to create a list of many plots and their eventual file 
#> paths: 
by_clarity <- by_clarity |> 
  mutate(
    plot = map(data, carat_histogram),
    path = str_glue("clarity-{clarity}.png")
  )
#> Then use walk2() with ggsave() to save each plot: 
walk2(
  by_clarity$path,
  by_clarity$plot,
  \(path, plot) ggsave(path, plot, width = 6, height = 6)
)
#> Which is shorthand for: 
ggsave(by_clarity$path[[1]], by_clarity$plot[[1]], width = 6, height = 6)
ggsave(by_clarity$path[[2]], by_clarity$plot[[2]], width = 6, height = 6)
ggsave(by_clarity$path[[3]], by_clarity$plot[[3]], width = 6, height = 6)
...
ggsave(by_clarity$path[[8]], by_clarity$plot[[8]], width = 6, height = 6)


