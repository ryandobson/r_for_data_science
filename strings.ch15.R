### R for Data Science 
#Second Edition: Chapter 15, Strings   

#Restart the console to start fresh! 
#ctrl + shift + F10 

library(tidyverse)
##install.packages("babynames")
library(babynames)

#> You can quickly tell when you are using a stringr function because they all 
#> start with str_ 
#> Typing str_ will trigger autocomplete and you can see all of your options. 
#> 
#> Creating Strings ----- 
#> 
#> You can use either ' or " to create strings. Recommends follow: 
string1 <- "This is a string"
string2 <- 'If I want to include a "quote" inside a string, I use single quotes'

#Escapes 
#> To include a literal single or double quote in a string, you can use \ to 
#> "escape" it: 
double_quote <- "\"" # or '"'
single_quote <- '\'' # or "'"
#So if you want to include a backslash in your string, you'll need to escape it: 
#"\\": 
backslash <- "\\"

#> Beware that the printed representation of the string is not the same as the 
#> string itself because the printed representation shows the escapes. 
#> To see the raw contents of the string use str_view() 
x <- c(single_quote, double_quote, backslash)
x
#> [1] "'"  "\"" "\\"

str_view(x)
#> [1] │ '
#> [2] │ "
#> [3] │ \


#> Raw Strings 
#> 
#> Creating a string with multiple quotes or backslashes gets confusing quickly. 
#> 
tricky <- "double_quote <- \"\\\"\" # or '\"'
single_quote <- '\\'' # or \"'\""
str_view(tricky)
#> [1] │ double_quote <- "\"" # or '"'
#>     │ single_quote <- '\'' # or "'"

#> A raw string usually starts with r"( and finishes with )". But if your string
#>  contains )" you can instead use r"[]" or r"{}", and if that’s still not 
#>  enough, you can insert any number of dashes to make the opening and closing 
#>  pairs unique, e.g., `r"--()--", `r"---()---", etc. Raw strings are flexible 
#>  enough to handle any text.
#>  

#> Other Special Characters 
#> 
#> \n  -a new line 
#> \t  -tab 
#> \u or \U -writing non-english characters 
x <- c("one\ntwo", "one\ttwo", "\u00b5", "\U0001f604")
x
#> [1] "one\ntwo" "one\ttwo" "µ"        "😄"
str_view(x)
#> [1] │ one
#>     │ two
#> [2] │ one{\t}two
#> [3] │ µ
#> [4] │ 😄


#> Creating Many Strings From Data ------
#> 
#> Solve the common problem where you have some text you wrote that you want to
#> combine with strings from a data frame. 
#> 
#> str_c() 
#> takes any number of vectors as arguments and returns a character vector 
str_c("x", "y")
#> [1] "xy"
str_c("x", "y", "z")
#> [1] "xyz"
str_c("Hello ", c("John", "Susan"))
#> [1] "Hello John"  "Hello Susan"

#> str_c() is very similar to the base past0(), but it is designed to be used with
#> mutate() by obeying the usual tidyverse rules for recycling and propogating
#> missing values:
df <- tibble(name = c("Flora", "David", "Terra", NA))
df |> mutate(greeting = str_c("Hi ", name, "!"))
#> # A tibble: 4 × 2
#>   name  greeting 
#>   <chr> <chr>    
#> 1 Flora Hi Flora!
#> 2 David Hi David!
#> 3 Terra Hi Terra!
#> 4 <NA>  <NA>

#> If you want missing values to display in another way, use coalesce() to 
#> replace them. 
#> Depending on what you want, you might use it either inside or outside of str_c() 
#> 
df |> 
  mutate(
    greeting1 = str_c("Hi ", coalesce(name, "you"), "!"),
    greeting2 = coalesce(str_c("Hi ", name, "!"), "Hi!")
  )
#> # A tibble: 4 × 3
#>   name  greeting1 greeting2
#>   <chr> <chr>     <chr>    
#> 1 Flora Hi Flora! Hi Flora!
#> 2 David Hi David! Hi David!
#> 3 Terra Hi Terra! Hi Terra!
#> 4 <NA>  Hi you!   Hi!

#> str_glue() 
#> You give it a single string that has a special feature: anything inside {} 
#> will be evaluated like it's outside of the quotes: 
df |> mutate(greeting = str_glue("Hi {name}!"))
#> # A tibble: 4 × 2
#>   name  greeting 
#>   <chr> <glue>   
#> 1 Flora Hi Flora!
#> 2 David Hi David!
#> 3 Terra Hi Terra!
#> 4 <NA>  Hi NA!
#> str_glue() currently converts missing values to the string "NA" unfortunately 
#> making it inconsistent with str__c() 
#> If you need to include a {} in your expression, you will have to escape it by 
#> simply doubling it up:
df |> mutate(greeting = str_glue("{{Hi {name}!}}"))
#> # A tibble: 4 × 2
#>   name  greeting   
#>   <chr> <glue>     
#> 1 Flora {Hi Flora!}
#> 2 David {Hi David!}
#> 3 Terra {Hi Terra!}
#> 4 <NA>  {Hi NA!}


#> str_flatten() 
#> 
#> str_c() and glue() work well with mutate() because their output is the same
#> length as their inputs. 
#> If you want something that works well with summarize(), by returning a single 
#> string, str_flatten() is the function. 
#> It takes a character vector and combines each element of the vector into a 
#> single string 
str_flatten(c("x", "y", "z"))
#> [1] "xyz"
str_flatten(c("x", "y", "z"), ", ")
#> [1] "x, y, z"
str_flatten(c("x", "y", "z"), ", ", last = ", and ")
#> [1] "x, y, and z"

#> Making it work well with summarize: 
df <- tribble(
  ~ name, ~ fruit,
  "Carmen", "banana",
  "Carmen", "apple",
  "Marvin", "nectarine",
  "Terence", "cantaloupe",
  "Terence", "papaya",
  "Terence", "mandarin"
)
df |>
  group_by(name) |> 
  summarize(fruits = str_flatten(fruit, ", "))
#> # A tibble: 3 × 2
#>   name    fruits                      
#>   <chr>   <chr>                       
#> 1 Carmen  banana, apple               
#> 2 Marvin  nectarine                   
#> 3 Terence cantaloupe, papaya, mandarin

#> Extracting Data from Strings ------ 
#> 
#> Very common for multiple variables to be crammed together into a single string
#> 
#> Four tidy functions are relevant here: 
#> df |> separate_longer_delim(col, delim)
#> df |> separate_longer_position(col, width)
#> df |> separate_wider_delim(col, delim, names)
#> df |> separate_wider_position(col, width)
#> 
#> These four functions are composed of two simpler primitives: 
#> Just like pivot_longer() and pivot_wider(), _longer functions make the input
#> data frame longer by creating new rows and _wider functions make the input
#> data frame wider by generating new columns 
#>  delim splits up a string with a delimiter like "," or " "; 
#>  position splits at specified widths, like c(3, 5, 2)
#>  
#>  Also is separate_regex_wider() that is covered in Ch 16
#>  
#>  Separating into Rows: 
df1 <- tibble(x = c("a,b,c", "d,e", "f"))
df1 |> 
  separate_longer_delim(x, delim = ",")
#> # A tibble: 6 × 1
#>   x    
#>   <chr>
#> 1 a    
#> 2 b    
#> 3 c    
#> 4 d    
#> 5 e    
#> 6 f
#> You can see how this is useful when the number of components varies from 
#> row to row. 

#> Much rarer to see separate_longer_position() in the wild. Some old data sets
#> do use a very compact format where each character is a different value and they
#> are just jammed together. 
df2 <- tibble(x = c("1211", "131", "21"))
df2 |> 
  separate_longer_position(x, width = 1)
#> # A tibble: 9 × 1
#>   x    
#>   <chr>
#> 1 1    
#> 2 2    
#> 3 1    
#> 4 1    
#> 5 1    
#> 6 3    
#> # ℹ 3 more rows

#> Separating into Columns: 
#> 
#> Tends to be most useful when there are a fixed number of components in each
#> string, and you want to spread them into columns. 
#> Slightly more complicated because you need to name columns. 
#> 
df3 <- tibble(x = c("a10.1.2022", "b10.2.2011", "e15.1.2015"))
df3 |> 
  separate_wider_delim(
    x,
    delim = ".",
    names = c("code", "edition", "year")
  )
#> # A tibble: 3 × 3
#>   code  edition year 
#>   <chr> <chr>   <chr>
#> 1 a10   1       2022 
#> 2 b10   2       2011 
#> 3 e15   1       2015

#> If a specific piece isn't useful you can use an NA name to omit it from the
#> results. 
df3 |> 
  separate_wider_delim(
    x,
    delim = ".",
    names = c("code", NA, "year")
  )
#> # A tibble: 3 × 2
#>   code  year 
#>   <chr> <chr>
#> 1 a10   2022 
#> 2 b10   2011 
#> 3 e15   2015

#> separate_wider_position() works a little different because you typically want
#> to specify the width of each column. So you give it a named integer vector,
#> where the name gives the name of the new column, and the value is the number 
#> of characters it occupies. You can omit values from the output by not naming 
#> them. 
df4 <- tibble(x = c("202215TX", "202122LA", "202325CA")) 
df4 |> 
  separate_wider_position(
    x,
    widths = c(year = 4, age = 2, state = 2)
  )
#> # A tibble: 3 × 3
#>   year  age   state
#>   <chr> <chr> <chr>
#> 1 2022  15    TX   
#> 2 2021  22    LA   
#> 3 2023  25    CA


#> Diagnosing Widening Problems 
#> 
#> separate_wider_delim() requires a fixed and known set of columns 
#> What happens if some of the rows don't have the expected number of pieces? 
df <- tibble(x = c("1-1-1", "1-1-2", "1-3", "1-3-2", "1"))

df |> 
  separate_wider_delim(
    x,
    delim = "-",
    names = c("x", "y", "z")
  )
#> Error in `separate_wider_delim()`:
#> ! Expected 3 pieces in each element of `x`.
#> ! 2 values were too short.
#> ℹ Use `too_few = "debug"` to diagnose the problem.
#> ℹ Use `too_few = "align_start"/"align_end"` to silence this message.

#> The above example is the too_few case. The last row of the df has only 1 piece
#> while the others have 3. 
#> 
#> We can start by debugging the problem: 
debug <- df |> 
  separate_wider_delim(
    x,
    delim = "-",
    names = c("x", "y", "z"),
    too_few = "debug"
  )
#> Warning: Debug mode activated: adding variables `x_ok`, `x_pieces`, and
#> `x_remainder`.
debug
#> # A tibble: 5 × 6
#>   x     y     z     x_ok  x_pieces x_remainder
#>   <chr> <chr> <chr> <lgl>    <int> <chr>      
#> 1 1-1-1 1     1     TRUE         3 ""         
#> 2 1-1-2 1     2     TRUE         3 ""         
#> 3 1-3   3     <NA>  FALSE        2 ""         
#> 4 1-3-2 3     2     TRUE         3 ""         
#> 5 1     <NA>  <NA>  FALSE        1 ""
#> x_ok lets you find the specific cases that failed 
#> x_pieces shows how many pieces were found (compared to the expected) 
#> x_remainder isn't useful here when we only have a few pieces, but we will see
#> it again shortly. 
#> 
#> You can simply specify too_few = "align_start" or 
#> too_few = "align_end" which allow you to fill in missing spots with NA and 
#> allows you to specify where the NAs should go.
#
df |> 
  separate_wider_delim(
    x,
    delim = "-",
    names = c("x", "y", "z"),
    too_few = "align_start"
  )
#> # A tibble: 5 × 3
#>   x     y     z    
#>   <chr> <chr> <chr>
#> 1 1     1     1    
#> 2 1     1     2    
#> 3 1     3     <NA> 
#> 4 1     3     2    
#> 5 1     <NA>  <NA>


#> Same principles apply when you have too many pieces: 
df <- tibble(x = c("1-1-1", "1-1-2", "1-3-5-6", "1-3-2", "1-3-5-7-9"))

df |> 
  separate_wider_delim(
    x,
    delim = "-",
    names = c("x", "y", "z")
  )
#> Error in `separate_wider_delim()`:
#> ! Expected 3 pieces in each element of `x`.
#> ! 2 values were too long.
#> ℹ Use `too_many = "debug"` to diagnose the problem.
#> ℹ Use `too_many = "drop"/"merge"` to silence this message.

#> Here is where x_remaineder becomes useful. 
#> Debugging: 
#> 
debug <- df |> 
  separate_wider_delim(
    x,
    delim = "-",
    names = c("x", "y", "z"),
    too_many = "debug"
  )
#> Warning: Debug mode activated: adding variables `x_ok`, `x_pieces`, and
#> `x_remainder`.
debug |> filter(!x_ok)
#> # A tibble: 2 × 6
#>   x         y     z     x_ok  x_pieces x_remainder
#>   <chr>     <chr> <chr> <lgl>    <int> <chr>      
#> 1 1-3-5-6   3     5     FALSE        4 -6         
#> 2 1-3-5-7-9 3     5     FALSE        5 -7-9

#> You have two options to fix this, either silently drop additional pieces 
#> or merge them all into the final column: 
df |> 
  separate_wider_delim(
    x,
    delim = "-",
    names = c("x", "y", "z"),
    too_many = "drop"
  )
#> # A tibble: 5 × 3
#>   x     y     z    
#>   <chr> <chr> <chr>
#> 1 1     1     1    
#> 2 1     1     2    
#> 3 1     3     5    
#> 4 1     3     2    
#> 5 1     3     5


df |> 
  separate_wider_delim(
    x,
    delim = "-",
    names = c("x", "y", "z"),
    too_many = "merge"
  )
#> # A tibble: 5 × 3
#>   x     y     z    
#>   <chr> <chr> <chr>
#> 1 1     1     1    
#> 2 1     1     2    
#> 3 1     3     5-6  
#> 4 1     3     2    
#> 5 1     3     5-7-9


#> Letters ----- 
#> 
#> Functions that allow you to work with individual letters within a string.
#> Find the length of a string, extract substrings, and handle long strings in 
#> plots and tables. 
#> 

#> str_length() 
#> tells you the numbers of letters in the string: 
str_length(c("a", "R for data science", NA))
#> [1]  1 18 NA

#> You could use this with count() to find the distribution of lengths of US 
#> babynames and then filter() to look at the longest names, which happen to have
#> 15 letters. 

babynames |>
  count(length = str_length(name), wt = n)
#> # A tibble: 14 × 2
#>   length        n
#>    <int>    <int>
#> 1      2   338150
#> 2      3  8589596
#> 3      4 48506739
#> 4      5 87011607
#> 5      6 90749404
#> 6      7 72120767
#> # ℹ 8 more rows

babynames |> 
  filter(str_length(name) == 15) |> 
  count(name, wt = n, sort = TRUE)
#> # A tibble: 34 × 2
#>   name                n
#>   <chr>           <int>
#> 1 Franciscojavier   123
#> 2 Christopherjohn   118
#> 3 Johnchristopher   118
#> 4 Christopherjame   108
#> 5 Christophermich    52
#> 6 Ryanchristopher    45
#> # ℹ 28 more rows


#> Subsetting 
#> 
#> You can extract parts of a string using str_sub(string, start, end),
#> where start and end are the positions where the substring should start and end. 
#> These arguments are inclusive. 
x <- c("Apple", "Banana", "Pear")
str_sub(x, 1, 3)
#> [1] "App" "Ban" "Pea"
#> 
#> Can use negative values to count from the back of the string. 
str_sub(x, -3, -1)
#> [1] "ple" "ana" "ear"

#> won't fall if the string is too short, just returns as much as possible: 
str_sub("a", 1, 5)
#> [1] "a"


#> Can youse str_sub() with mutate() to find the first and last letter of each
#> name: 
babynames |> 
  mutate(
    first = str_sub(name, 1, 1),
    last = str_sub(name, -1, -1)
  )
#> # A tibble: 1,924,665 × 7
#>    year sex   name          n   prop first last 
#>   <dbl> <chr> <chr>     <int>  <dbl> <chr> <chr>
#> 1  1880 F     Mary       7065 0.0724 M     y    
#> 2  1880 F     Anna       2604 0.0267 A     a    
#> 3  1880 F     Emma       2003 0.0205 E     a    
#> 4  1880 F     Elizabeth  1939 0.0199 E     h    
#> 5  1880 F     Minnie     1746 0.0179 M     e    
#> 6  1880 F     Margaret   1578 0.0162 M     t    
#> # ℹ 1,924,659 more rows


#> Non-English Text -------
#> 
#> Biggest challenges you might encounter here: encoding, letter variations, and
#> locale-dependent functions 
#> 
#> Encoding 
#> 
#> To understand what's going on, we need to look at how comptuers represent 
#> strings. 
#> In R, we can get to the underlying representation of a string using 
#> charToRaw() 

charToRaw("Hadley")
#> [1] 48 61 64 6c 65 79
#> Each of these hexadecimal numbers represents one letter: 48 is H, 1 is a, so on. 
#> 
#> This is based off of the ASCII which is the American Standard Code for 
#> information exchange. It does a good job with english but not so well for 
#> other languages. 
#> 
#> Today, UTF-8 is the standard encoding and can encode pretty much everything.
#> 
#> readr uses UTF-8 everywhere. 
#> This is good but might fail if loading things from older systems. 
#> Your strings will start to look weird. 
#> 
#> Here are two inline CSVs with unusual encodings: 
#> 
x1 <- "text\nEl Ni\xf1o was particularly bad this year"
read_csv(x1)
#> # A tibble: 1 × 1
#>   text                                       
#>   <chr>                                      
#> 1 "El Ni\xf1o was particularly bad this year"

x2 <- "text\n\x82\xb1\x82\xf1\x82\xc9\x82\xbf\x82\xcd"
read_csv(x2)
#> # A tibble: 1 × 1
#>   text                                      
#>   <chr>                                     
#> 1 "\x82\xb1\x82\xf1\x82\xc9\x82\xbf\x82\xcd"

#> To read them you need to specify the encoding via the locale argument:
read_csv(x1, locale = locale(encoding = "Latin1"))
#> # A tibble: 1 × 1
#>   text                                  
#>   <chr>                                 
#> 1 El Niño was particularly bad this year

read_csv(x2, locale = locale(encoding = "Shift-JIS"))
#> # A tibble: 1 × 1
#>   text      
#>   <chr>     
#> 1 こんにちは

#> If you don't know which encoding to use, guess_encoding() from readr can 
#> attempt to help you. 
#> 
#> Letter Variations 
#> 
#> Working with languages with accents poses a challenge when determining the 
#> position of letters. 
#> accented letters might be encoded as a single individual character, or as 
#> two characters. 
u <- c("\u00fc", "u\u0308")
str_view(u)
#> [1] │ ü
#> [2] │ ü

#> Both strings differ in length, but their first characters are different: 
str_length(u)
#> [1] 1 2
str_sub(u, 1, 1)
#> [1] "ü" "u"
#> 
#> You can also note the comparison of these strings with == versus with the 
#> handy str_equal() function of stringr 
#> 
u[[1]] == u[[2]]
#> [1] FALSE

str_equal(u[[1]], u[[2]])
#> [1] TRUE


#> Locale-dependent functions 
#> 
#> A locale is similar to a language but includes an optional region specifier 
#> to handle regional variations within a language. Specified b a lower-case 
#> language abbreviation, optionally followed by a _ and an upper-case region 
#> identified. 
#> en_GB is English British 
#> en_US is English American 
#> 
#> This is relevant because your code might work differently for someone if they
#> are in a different country. 
#> 




