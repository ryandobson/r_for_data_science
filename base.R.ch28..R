### R for Data Science 
#Second Edition: Chapter 28, Base R          

#Restart the console to start fresh! 
#ctrl + shift + F10 

library(tidyverse) 

#> Selecting multiple elements with [ -----
#> 
#> [ is used to extract sub-components from vectors and data frames; it is called
#> like x[i] or x[i,j]
#> 
#> Subsetting Vectors: 
#> 
#> A vector of positive integers
x <- c("one", "two", "three", "four", "five")
x[c(3, 2, 5)]
#> [1] "three" "two"   "five"
#> By repeating a position, you can actually make a longer output than input. 
x[c(1, 1, 5, 5, 5, 2)]
#> [1] "one"  "one"  "five" "five" "five" "two"
#> 
#> A Vector of Negative Integers 
x[c(-1, -3, -5)]
#> [1] "two"  "four"
#> negative values drop the elements at the specified positions (here we dropped
#> the 1st, 3rd, and 5th elements of the vector X)
#> 
#> A Logical Vector 
x <- c(10, 3, NA, 5, 8, 1, NA)
#> Subsetting with a logical vector keeps all values corresponding to TRUE. 
#> Most useful with comparison functions 

# All non-missing values of x
x[!is.na(x)]
#> [1] 10  3  5  8  1

# All even (or missing!) values of x
x[x %% 2 == 0]
#> [1] 10 NA  8 NA
#> 
#> A Character Vector 
#> 
x <- c(abc = 1, def = 2, xyz = 5)
x[c("xyz", "def")]
#> xyz def 
#>   5   2
#>   
#> Nothing 
#> You can subset with x[], which actually just returns the whole x. This isn't 
#> useful for vectors but is useful to remember when working with data frames 
#> 
#> Subsetting Data Frames 
#> 
#> df[rows, cols]
#> Here, rows and columns are vectors as described above. 
#> df[rows,] selects just rows
#> df[, cols] selects just columns 
#> 
#> Examples: 
df <- tibble(
  x = 1:3, 
  y = c("a", "e", "f"), 
  z = runif(3)
)

# Select first row and second column
df[1, 2]
#> # A tibble: 1 × 1
#>   y    
#>   <chr>
#> 1 a

# Select all rows and columns x and y
df[, c("x" , "y")]
#> # A tibble: 3 × 2
#>       x y    
#>   <int> <chr>
#> 1     1 a    
#> 2     2 e    
#> 3     3 f

# Select rows where `x` is greater than 1 and all columns
df[df$x > 1, ]
#> # A tibble: 2 × 3
#>       x y         z
#>   <int> <chr> <dbl>
#> 1     2 e     0.834
#> 2     3 f     0.601

#> There is an important difference between data frames and tibbles when it comes
#> to [. 
#> 
#> dplyr Equivalents ----
#> 
#> filter() is equivalent to subsetting the rows with a logical vector, taking 
#> care to exclude missing values: 
df <- tibble(
  x = c(2, 3, 1, 1, NA), 
  y = letters[1:5], 
  z = runif(5)
)
df |> filter(x > 1)

# same as
df[!is.na(df$x) & df$x > 1, ]
#> another common technique in the wild is to use which() for its side-effect
#> of dropping missing values: 
df[which(df$x >1), ]


#> arrange() is equivalent to subsetting the rows with an integer vector, usually
#> created with order() 
df |> arrange(x, y)

# same as
df[order(df$x, df$y), ]


#> Both select() and relocate() are similar to subsetting the columns with a 
#> character vector: 
df |> select(x, z)

# same as
df[, c("x", "z")]


#> R also provides a function that combines the features of filter() and select()
#> called subset() 
df |> 
  filter(x > 1) |> 
  select(y, z)
#> # A tibble: 2 × 2
#>   y           z
#>   <chr>   <dbl>
#> 1 a     0.157  
#> 2 b     0.00740
#> 
#> This function actually inspired much of dplyr's syntax 
#> 
#> Selecting a single element with $ and [[  ------
#> 
#> [[ and $ can be used to extract columns out of a data frame. [[ can also 
#> access by position or by name, and $ is specialized for access by name 
tb <- tibble(
  x = 1:4,
  y = c(10, 4, 1, 21)
)

# by position
tb[[1]]
#> [1] 1 2 3 4

# by name
tb[["x"]]
#> [1] 1 2 3 4
tb$x
#> [1] 1 2 3 4

#> This can also be used to create new columns, the base R equivalent of mutate()
tb$z <- tb$x + tb$y
tb
#> # A tibble: 4 × 3
#>       x     y     z
#>   <int> <dbl> <dbl>
#> 1     1    10    11
#> 2     2     4     6
#> 3     3     1     4
#> 4     4    21    25

#> $ is convenient when performing quick summaries. For example, if you just want 
#> to find the size of the biggest diamond or the possible values of cut, 
#> there's no need to use summarize() 
max(diamonds$carat)
#> [1] 5.01

levels(diamonds$cut)
#> [1] "Fair"      "Good"      "Very Good" "Premium"   "Ideal"


#> dplyr also provides an equivalent to [[ / $ that wasn't mentioned in Chapter 4. 
#> pull() takes either a variable name or variable position and returns just that 
#> column. 
#> 
#> So we could rewrite the above code to use the pipe:
diamonds |> pull(carat) |> mean()
#> [1] 0.7979397

diamonds |> pull(cut) |> levels()
#> [1] "Fair"      "Good"      "Very Good" "Premium"   "Ideal"

#> Tibbles versus Data Frames ------
#> 
#> Data frames match the prefix of any variable names (so-called partial matching)
#> and don't complain if a column doesn't exist: 
df <- data.frame(x1 = 1)
df$x
#> [1] 1
df$z
#> NULL

#> Tibbles are more strict: they only ever match variable names exactly and they
#> will generate a warning if the column you are trying to access doesn't exist.
tb <- tibble(x1 = 1)

tb$x
#> Warning: Unknown or uninitialised column: `x`.
#> NULL
tb$z
#> Warning: Unknown or uninitialised column: `z`.
#> NULL

#> Lists 
#> 
#> [[ and $ are also really important for working with lists. And its important 
#> to see how they differ from [
l <- list(
  a = 1:3, 
  b = "a string", 
  c = pi, 
  d = list(-1, -5)
)
#> [ extracts a sub-list. It doesn't matter how many elements you extract, the 
#> results will always be a list. 
str(l[1:2])
#> List of 2
#>  $ a: int [1:3] 1 2 3
#>  $ b: chr "a string"

str(l[1])
#> List of 1
#>  $ a: int [1:3] 1 2 3

str(l[4])
#> List of 1
#>  $ d:List of 2
#>   ..$ : num -1
#>   ..$ : num -5
#>   
#>   Like with vectors, you can subset with a logical, integer, or character
#>   vector 
#>   
#>   [[ and $ extract a single component from a list. They remove a level of 
#>   hierarchy from the list: 
str(l[[1]])
#>  int [1:3] 1 2 3

str(l[[4]])
#> List of 2
#>  $ : num -1
#>  $ : num -5

str(l$a)
#>  int [1:3] 1 2 3
#>  
#>  So [ returns a new smaller list, while [[ drills down into a specific element
#>  of a list.
#>  
#>  
#>  Apply Family ------
#>  
#>  In chapter 27 we explored dplyr's across() function. 
#>  Here we will look at R's base equivalent, the apply family. 
#>  
#>  apply and map are synonyms because they are another way of saying "map a 
#>  function over each element of a vector" or "apply a function over each 
#>  element of a vector" 
#>  
#>  lapply() is very similar to purrr::map() 
#>  In fact, because we haven't used any of map's advanced features, every map()
#>  in chapter 27 can be replaced with lapply() 
#>  
#>  There is no exact duplicate for across() but you can get close by using
#>  [ and lapply() on a data frame. 
df <- tibble(a = 1, b = 2, c = "a", d = "b", e = 4)

# First find numeric columns
num_cols <- sapply(df, is.numeric)
num_cols
#>     a     b     c     d     e 
#>  TRUE  TRUE FALSE FALSE  TRUE

# Then transform each column with lapply() then replace the original values
df[, num_cols] <- lapply(df[, num_cols, drop = FALSE], \(x) x * 2)
df
#> # A tibble: 1 × 5
#>       a     b c     d         e
#>   <dbl> <dbl> <chr> <chr> <dbl>
#> 1     2     4 a     b         8
#> 
#> sapply() -used above- always tries to simplify the result, here it produces
#> a logical vector instead of a list. We don't recommend using it for programming
#> because the simplification can fail and give you unexpected types. Its usually
#> fine for interactive purposes though. 
#> purrr has a similar function called map_vec() 
#> 
#> A stricter version of sapply() is vapply(), it takes an additional argument 
#> that specifies the expected type, ensuring that simplification occurs the same
#> way regardless of the input. 
vapply(df, is.numeric, logical(1))
#>     a     b     c     d     e 
#>  TRUE  TRUE FALSE FALSE  TRUE
#>  
#>  The distinction between sapply() and vapply() is really important when they
#>  are inside a function, but it doesn't usually matter in data analysis. 
#>  
#>  Another important member of apply is tapply() which computes a single grouped
#>  summary: 
diamonds |> 
  group_by(cut) |> 
  summarize(price = mean(price))
#> # A tibble: 5 × 2
#>   cut       price
#>   <ord>     <dbl>
#> 1 Fair      4359.
#> 2 Good      3929.
#> 3 Very Good 3982.
#> 4 Premium   4584.
#> 5 Ideal     3458.

tapply(diamonds$price, diamonds$cut, mean)
#>      Fair      Good Very Good   Premium     Ideal 
#>  4358.758  3928.864  3981.760  4584.258  3457.542


#> For Loops ------
#> 
#> for loops are the fundamental building block of iteration that both the apply
#> and map families use under the hood. for loops are powerful and general tools
#> that are important to learn as you become a more experienced R programmer. 
#> Basic Structure of a for loop: 
for (element in vector) {
  # do something with element
}

#> most straightforward use of for loops is to achieve the same affect as walk()
paths |> walk(append_file)
#> could have used a for loop:
for (path in paths) {
  append_file(path)
}


#> Plots --------
#> 
#> The primary major benefit of using Base R for some plots is that it takes very
#> little code. 
#> Two main types y ou will see are plot() and hist() 

hist(diamonds$carat)

plot(diamonds$carat, diamonds$price)




