### R for Data Science 
#Second Edition: Chapter 26, Functions         

#Restart the console to start fresh! 
#ctrl + shift + F10 

library(tidyverse) 

#> Functions are one of the best ways for you to improve your coding. 
#> Functions allow you to automate common tasks instead of copy-and-pasting
#> 
#> Four Big Advantages of Functions (over copy and paste)
#> 1: You can give your function an evocative name and make your code easier to
#> understand
#> 2: As requirements change, you only need to update code in one place, instead
#> of many 
#> 3: You eliminate the chance of making incidental mistakes when you copy and
#> paste
#> 4: It makes it easier to reuse work from project-to-project, increasing your
#> productivity over time 
#> 
#> Good rule of thumb: If you have to copy and paste code more than twice, write
#> a function instead! 
#> 
#> Three Useful Types of Functions: 
#> Vector functions - take one or more vectors as input and return a vector as
#> output 
#> Data frame functions - take a data frame as input and return a data frame as
#> output
#> Plot functions - take a data frame as input and return a plot as output 
#> 
library(nycflights13)

#> Vector Functions ------
#> 
#> Take a look at this code: 
df <- tibble(
  a = rnorm(5),
  b = rnorm(5),
  c = rnorm(5),
  d = rnorm(5),
)

df |> mutate(
  a = (a - min(a, na.rm = TRUE)) / 
    (max(a, na.rm = TRUE) - min(a, na.rm = TRUE)),
  b = (b - min(b, na.rm = TRUE)) / 
    (max(b, na.rm = TRUE) - min(a, na.rm = TRUE)),
  c = (c - min(c, na.rm = TRUE)) / 
    (max(c, na.rm = TRUE) - min(c, na.rm = TRUE)),
  d = (d - min(d, na.rm = TRUE)) / 
    (max(d, na.rm = TRUE) - min(d, na.rm = TRUE)),
)
#> this code re scales each column to have a range from 0 to 1. 
#> But, a mistake was made when copying and pasting and an "a" was not changed to
#> a "b" 
#> Writing a function in place of this code block can solve that error!
#> 
#> Writing a Function: 
#> You first need to analyze your repeated code to figure out what parts are 
#> constant and what parts vary. 
#> If we take the code above and pull it outside of mutate(), we can more easily
#> get an idea of whats happening: 
(a - min(a, na.rm = TRUE)) / (max(a, na.rm = TRUE) - min(a, na.rm = TRUE))
(b - min(b, na.rm = TRUE)) / (max(b, na.rm = TRUE) - min(b, na.rm = TRUE))
(c - min(c, na.rm = TRUE)) / (max(c, na.rm = TRUE) - min(c, na.rm = TRUE))
(d - min(d, na.rm = TRUE)) / (max(d, na.rm = TRUE) - min(d, na.rm = TRUE))  

#> We can replace each spot that varies with this: 
#(█ - min(█, na.rm = TRUE)) / (max(█, na.rm = TRUE) - min(█, na.rm = TRUE))

#> To turn this  into a function you need three things: 
#> 1: A name (make it something understandable, what the function does)
#> 2: The arguments (the things that vary across calls and our analysis above 
#> tells us that we just have one vector that varies per line)
#> 3: The body (code that's repeated across all the calls)

#> You can create a function by following the template: 
name <- function(arguments) {
  body
}

#> For this case: 
rescale01 <- function(x) {
  (x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
}


#> Now you  an test this with a few simple inputs: 
rescale01(c(-10, 0, 10))
rescale01(c(1, 2, 3, NA, 5))

#> It all looks good so we can rewrite our above code! 
df |> mutate(
  a = rescale01(a),
  b = rescale01(b),
  c = rescale01(c),
  d = rescale01(d),
)

#> In chapter 27 you'll learn how to use across so you can reduce the duplication
#> even further! 
#> All you really need is: 
df |> mutate(across(a:d, rescale01))


#> Improving our function 
#> 
#> Instead of computing the min twice and max once we could simplify things by 
#> just using the range. 
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}
#> You might try this function on a vector that includes an infinite value:
x <- c(1:10, Inf)
rescale01(x)
#> That isn't particularly useful so we could also ask the function to ignore
#> infinite values 
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE, finite = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}

rescale01(x)

#> This illustrates the magic of functions, since we moved the repeated code into
#> a function, we only needed to make the change in one place! 
#> 
#> Mutate Functions 
#> 
#> Maybe you want to compute the Z-Score: 

z_score <- function(x) {
  (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)
}
#> Here we are rescaling a vector "x" to have a mean of 0 and sd of 1
#> 
#> Or maybe you want to wrap up a straightforward case_when() and give it a 
#> useful name. 
#> For example, this clamp function ensures all values of a vector lie in between
#> a minimum or a maximum
clamp <- function(x, min, max) {
  case_when(
    x < min ~ min,
    x > max ~ max,
    .default = x
  )
}

clamp(1:10, min = 3, max = 7)

#> Maybe you want to make the first character of a string upper case: 
first_upper <- function(x) {
  str_sub(x, 1, 1) <- str_to_upper(str_sub(x, 1, 1))
  x
}

first_upper("hello")

#> Or maybe you want to strip percent signs, commas, and dollar signs from a 
#> string before converting it into a number: 
clean_number <- function(x) {
  is_pct <- str_detect(x, "%")
  num <- x |> 
    str_remove_all("%") |> 
    str_remove_all(",") |> 
    str_remove_all(fixed("$")) |> 
    as.numeric(x)
  if_else(is_pct, num / 100, num)
}

clean_number("$12,300")
clean_number("45%")

#> Sometimes your functions will be highly specialized for one data analysis 
#> step. 
#> For example, if you have a bunch of variables that record missing values as
#> 997, 998, or 999, you might want to write a function to replace them with NA
fix_na <- function(x) {
  if_else(x %in% c(997, 998, 999), NA, x)
}

#> We focused on examples that take a single vector because we think they are 
#> most common. 
#> But, there is no reason that your function can't take multiple vector inputs!
#> 
#> Summary Functions ----
#> 
#> These are important functions that return a single value for use in summarize()
#> Sometimes this can just be a matter of setting a default argument or two: 
commas <- function(x) {
  str_flatten(x, collapse = ", ", last = " and ")
}

commas(c("cat", "dog", "pigeon"))

#> Or you might wrap up a simple computation, like for the coefficient of variation,
#> which divides the standard deviation by the mean:; 
cv <- function(x, na.rm = FALSE) {
  sd(x, na.rm = na.rm) / mean(x, na.rm = na.rm)
}

cv(runif(100, min = 0, max = 50))
cv(runif(100, min = 0, max = 500))

#> Or maybe you just want to make a common pattern easier to remember by giving
#> it a memorable name: 
n_missing <- function(x) {
  sum(is.na(x))
} 

#> You can also write functions with multiple vector inputs. For example, maybe
#> you want to compute the mean absolute prediction error to help you compare
#> model predictions with actual values: 
mape <- function(actual, predicted) {
  sum(abs((actual - predicted) / actual)) / length(actual)
}

#> RSTUDIO Shortcuts ----
#> 
#> To find the definition of a function that you've written, place the cursor on
#> the name of the function and press F2 
#> To quickly jump to a function, press Ctrl and . to open the fuzzy file and
#> function finder and type the first few letters of your function name. This is
#> a handy navigate tool in general. 
#> 
#> 
#> Exercises: Turn the following code into functions
mean(is.na(x))
mean(is.na(y))
mean(is.na(z))

mean <- function(x) {
  mean(is.na(x))
}


x / sum(x, na.rm = TRUE)
y / sum(y, na.rm = TRUE)
z / sum(z, na.rm = TRUE)

divide <- function(x) {
  x / sum(x, na.rm = TRUE)
}

round(x / sum(x, na.rm = TRUE) * 100, 1)
round(y / sum(y, na.rm = TRUE) * 100, 1)
round(z / sum(z, na.rm = TRUE) * 100, 1)

round < function(x) {
  round(x / sum(x, na.rm = TRUE) * 100, 1)
}


#> Data Frame Functions --------
#> 
#> Vector functions are useful for pulling out code that's repeated within a dplyr
#> verb. But you'll often also repeat the verbs themselves, particularly within
#> a large pipeline. 
#> When you notice yourself copying and pasting multiple verbs multiple times, 
#> you might think about writing a data frame function. 
#> Data frame functions work like dplyr verbs: they take a data frame as the first
#> argument, some extra arguments that say what to do with it, and return a data
#> frame or vector. 
#> 
#> Challenge of Indirection 
#> 
#> Start with a simple function: grouped_mean(). The goal of this function is to
#> compute the mean of mean_var grouped by group_var 
#> (this is highly useful!)
#> 
grouped_mean <- function(df, group_var, mean_var) {
  df |> 
    group_by(group_var) |> 
    summarize(mean(mean_var))
}
#> If we try it, we will get an error: 
diamonds |> grouped_mean(cut, carat)

#> To make this problem more clear, we can use a made up data frame: 
df <- tibble(
  mean_var = 1,
  group_var = "g",
  group = 1,
  x = 10,
  y = 100
)

df |> grouped_mean(group, x)
#> # A tibble: 1 × 2
#>   group_var `mean(mean_var)`
#>   <chr>                <dbl>
#> 1 g                        1
df |> grouped_mean(group, y)
#> # A tibble: 1 × 2
#>   group_var `mean(mean_var)`
#>   <chr>                <dbl>
#> 1 g                        1

#> Regardless of how we call grouped_mean() it always does: 
#> df |> group_by(group_var) |> summarize(mean(mean_var)), instead of: 
#> df |> group_by(group_var) |> summarize(mean(x)) OR
#> df |> group_by(group_var) |> summarize(mean(y))
#> 
#> This is the problem of indirection, and it arises because dplyr uses tidy
#> evaluation to allow you to refer to the names of variables inside your data
#> frame without any special treatment
#> 
#> Embracing ------
#> 
#> Tidy evaluation includes a solution to this problem called embracing. 
#> Embracing a variable means to wrap it in braces, so "var" becomes {{var}}. 
#> Embracing a variable tells dplyr to use the value stored inside the argument,
#> not the argument as the literal variable name. 
#> Think of {{}} as looking down a tunnel -- {{var}} will make a dplyr function
#> look inside of var rather than look for a variable called var. 
#> 
#> So to make our above function work we need to: 
grouped_mean <- function(df, group_var, mean_var) {
  df |> 
    group_by({{ group_var }}) |> 
    summarize(mean({{ mean_var }}))
}

df |> grouped_mean(group, x)

#> When to embrace? 
#> 
#> It is relatively easy to find out when to embrace because you can look it up 
#> in from the documentation. 
#> There are two terms to look for in docs which correspond to the two most 
#> common sub-types of tidy evaluation: 
#> 1: Data-masking: this is used in functions like arrange(), filter(), and 
#> summarize() that compute with variables. 
#> 2: Tidy-selection: this is used for functions like select(), relocate(), and 
#> rename() that select variables. 
#> 
#> Common Use Cases ----
#> 
#> If you commonly perform the same set of summaries when doing initial data
#> exploration, you might consider wrapping them up in a helper function: 
summary6 <- function(data, var) {
  data |> summarize(
    min = min({{ var }}, na.rm = TRUE),
    mean = mean({{ var }}, na.rm = TRUE),
    median = median({{ var }}, na.rm = TRUE),
    max = max({{ var }}, na.rm = TRUE),
    n = n(),
    n_miss = sum(is.na({{ var }})),
    .groups = "drop"
  )
}
#> Whenenver you wrap summarize() in a helper, we think it's good practice to 
#> set .groups = "drop" to both avoid the message and leave the data in an 
#> ungrouped state. 

diamonds |> summary6(carat)

#> Plus, the nice thing about this function is that because it wraps summarize(),
#> you can use it on grouped date: 
diamonds |> 
  group_by(cut) |> 
  summary6(carat)

#> Further, since the arguments to summarize are data-masking also means that var
#> argument to summary6() is data-masking. that means you can also summarize 
#> computed variables: 
diamonds |> 
  group_by(cut) |> 
  summary6(log10(carat))


#> To summarize multiple variables at once you'll need to wait until Chapter 27
#> to learn how to use across()
#> 
#> Another popular summarize() helper function is a version of count() that also
#> computes proportions: 
count_prop <- function(df, var, sort = FALSE) {
  df |>
    count({{ var }}, sort = sort) |>
    mutate(prop = n / sum(n))
}

diamonds |> count_prop(clarity)

#> We use a default value for sort so that if the user doesn't supply their own 
#> value it will default to FALSE. 


unique_where <- function(df, condition, var) {
  df |> 
    filter({{ condition }}) |> 
    distinct({{ var }}) |> 
    arrange({{ var }})
}


#> Here we embrace condition because its passed to filter() and var because its
#> passed to distinct() and arrange()

# Find all the destinations in December
flights |> unique_where(month == 12, dest)


#>
#> 
#> We've made all these examples to take a data frame as the first argument, but 
#> if you are working repeatedly with the same data, it can make sense to 
#> hardcode it. 
#> For example, the following functions always works with the flight dataset and
#> always selects time_hour, carrier, and flight since they form the compound
#> primary key that allows you to identify a row. 
subset_flights <- function(rows, cols) {
  flights |> 
    filter({{ rows }}) |> 
    select(time_hour, carrier, flight, {{ cols }})
}

#> Data-masking vs. tidy-selection -----
#> 
#> Sometimes you want to select variables inside a function that uses data-masking
#> Imagine you want to write a count_missing() that counts the number of missing
#> observations in rows. You might try: 
count_missing <- function(df, group_vars, x_var) {
  df |> 
    group_by({{ group_vars }}) |> 
    summarize(
      n_miss = sum(is.na({{ x_var }})),
      .groups = "drop"
    )
}

flights |> 
  count_missing(c(year, month, day), dep_time)
#> This doesn't work because group_by uses data-masking, not tidy-selection. 
#> We can work around that problem by using the handy pick() function, which 
#> allows you to use tidy-selection inside data-masking functions

count_missing <- function(df, group_vars, x_var) {
  df |> 
    group_by(pick({{ group_vars }})) |> 
    summarize(
      n_miss = sum(is.na({{ x_var }})),
      .groups = "drop"
    )
}

flights |> 
  count_missing(c(year, month, day), dep_time)

#> Another convenient use of pick() is to make a 2D table of counts. 
#> Here we count using all the variables in the rows and columns, then use 
#> pivot_wider() to rearrange the counts into a grid: 
count_wide <- function(data, rows, cols) {
  data |> 
    count(pick(c({{ rows }}, {{ cols }}))) |> 
    pivot_wider(
      names_from = {{ cols }}, 
      values_from = n,
      names_sort = TRUE,
      values_fill = 0
    )
}

diamonds |> count_wide(c(clarity, color), cut)



#> Plot Functions ---------
#> 
#> If ou want to return a plot you can use the same techniques with ggplot2 
#> because aes() is a data-masking function. 
#> 
#> Imagine you're making a lot of histograms: 
diamonds |> 
  ggplot(aes(x = carat)) +
  geom_histogram(binwidth = 0.1)

diamonds |> 
  ggplot(aes(x = carat)) +
  geom_histogram(binwidth = 0.05)

#> Its super simple to make a function of this after you know aes() is data-masking
#> and you will need to embrace it:
histogram <- function(df, var, binwidth = NULL) {
  df |> 
    ggplot(aes(x = {{ var }})) + 
    geom_histogram(binwidth = binwidth)
}

diamonds |> histogram(carat, 0.1)
#> NOTE that histogram() returns a ggplot2 plot, meaning you can still add on 
#> additional componenets if you want! Just remember to switch from |>  to +

diamonds |> 
  histogram(carat, 0.1) +
  labs(x = "Size (in carats)", y = "Number of diamonds")


#> More Variables 
#> 
#> Its pretty easy to add more variables to the mix, say to check whether or not
#> a data set is linear by overlaying a smooth line and a straight line: 
linearity_check <- function(df, x, y) {
  df |>
    ggplot(aes(x = {{ x }}, y = {{ y }})) +
    geom_point() +
    geom_smooth(method = "loess", formula = y ~ x, color = "red", se = FALSE) +
    geom_smooth(method = "lm", formula = y ~ x, color = "blue", se = FALSE) 
}

starwars |> 
  filter(mass < 1000) |> 
  linearity_check(mass, height)

#> Or maybe you want an alternative to colored scatterplots for very large datasets
#> where overplotting is a problem: 
hex_plot <- function(df, x, y, z, bins = 20, fun = "mean") {
  df |> 
    ggplot(aes(x = {{ x }}, y = {{ y }}, z = {{ z }})) + 
    stat_summary_hex(
      aes(color = after_scale(fill)), # make border same color as fill
      bins = bins, 
      fun = fun,
    )
}

diamonds |> hex_plot(carat, price, depth)



#> Combining with other tidyverse 
#> 
#> Some of the most useful helpers combine a dash of data manipulation with ggplot2
#> 
#> Example: 
sorted_bars <- function(df, var) {
  df |> 
    mutate({{ var }} := fct_rev(fct_infreq({{ var }})))  |>
    ggplot(aes(y = {{ var }})) +
    geom_bar()
}

diamonds |> sorted_bars(clarity)
#> We have to use a new operator here := 
#> because we are generating the variable name based on user-supplied data. 
#> varaible names go on the left hand side of =, but R's syntax doesn't allow
#> anything to the left of = except for a single literal name. To work around this
#> we use the special operator := which tidy evaluation treats in exaclty the same
#> way as = 
#> 
#> Another example: Making it easy to draw a bar plot for a subset of data
onditional_bars <- function(df, condition, var) {
  df |> 
    filter({{ condition }}) |> 
    ggplot(aes(x = {{ var }})) + 
    geom_bar()
}

diamonds |> conditional_bars(cut == "Good", clarity)


#> Labeling -----
#> 
#> Wouldn't it be nice if we could label the output with the variable and the bin
#> width that was used? 
#> To do so we are going to have to use a low-level package: rlang. 
#> rlang is used by just about every other package in the tidyverse. 
#> 
#> To solve the labeling problem we can use rlang::englue(). This works similarly
#> to str_glue() so any value wrapped in {} will be inserted into the string. 
#> But it also understand {{}} which automatically inserts the appropriate 
#> variable name: 
histogram <- function(df, var, binwidth) {
  label <- rlang::englue("A histogram of {{var}} with binwidth {binwidth}")
  
  df |> 
    ggplot(aes(x = {{ var }})) + 
    geom_histogram(binwidth = binwidth) + 
    labs(title = label)
}

diamonds |> histogram(carat, 0.1)

#> You can use the same approach in any other place that you want to supply a 
#> string in ggplot2!
#> 
#> Style ------
#> 
#> Ideally your function names will be short but clearly evoke what the function 
#> does. 
#> Its better to be clear than short. 
#> function names should be verbs, and arguments should be nouns. 
# Too short
f()

# Not a verb, or descriptive
my_awesome_function()

# Long, but clear
impute_missing()
collapse_years()

#> Take note of white space and how you set things up for easy reading: 
# missing extra two spaces
density <- function(color, facets, binwidth = 0.1) {
diamonds |> 
    ggplot(aes(x = carat, y = after_stat(density), color = {{ color }})) +
    geom_freqpoly(binwidth = binwidth) +
    facet_wrap(vars({{ facets }}))
}

# Pipe indented incorrectly
density <- function(color, facets, binwidth = 0.1) {
  diamonds |> 
    ggplot(aes(x = carat, y = after_stat(density), color = {{ color }})) +
    geom_freqpoly(binwidth = binwidth) +
    facet_wrap(vars({{ facets }}))
}

