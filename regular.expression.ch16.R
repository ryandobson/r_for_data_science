### R for Data Science 
#Second Edition: Chapter 16, Regular Expressions   

#Restart the console to start fresh! 
#ctrl + shift + F10 

library(tidyverse)
library(babynames)

#> regular expressions are a concise and powerful language for describing 
#> patterns within strings. 
#> Usually shortened to "regex" or "regexp" 
#> 
#> Pattern Basics ----- 
#> 
#> We'll use str_view() to learn how regex patterns work. 
#> We used this in the last chapter to better understand a string versus its
#> printed representation.
#> Now, we will add the second argument, a regular expression. 
#> 
#> str_view will show only elements of the string vector that match, surrounding
#> each match with <>, and where possible, highlighting the match in blue. 

str_view(fruit, "berry")


#> Letters and numbers match exactly and are called Literal Characters. 
#> Must punctuation characters, like: . + * [ ] and ? 
#> have special meanings and are called Meta-Characters 
#> 
#> . will match any character, so "a." will match any string that contains an 
#> "a" followed by another character: 

str_view(c("a", "ab", "ae", "bd", "ea", "eab"), "a.")
#> [2] │ <ab>
#> [3] │ <ae>
#> [6] │ e<ab>

str_view(fruit, "a...e")
#>  [1] │ <apple>
#>  [7] │ bl<ackbe>rry
#> [48] │ mand<arine>
#> [51] │ nect<arine>
#> [62] │ pine<apple>
#> [64] │ pomegr<anate>
#> ... and 2 more


#> Quantifiers control how many times a pattern can match: 
#> ? makes a pattern optional (it matches 0 or 1 times)
#> + lets a pattern repeat (it matches at least once)
#> * lets a pttern be optional or repeat (it matches any number of times, including 0)
#> 
# ab? matches an "a", optionally followed by a "b".
str_view(c("a", "ab", "abb"), "ab?")
#> [1] │ <a>
#> [2] │ <ab>
#> [3] │ <ab>b

# ab+ matches an "a", followed by at least one "b".
str_view(c("a", "ab", "abb"), "ab+")
#> [2] │ <ab>
#> [3] │ <abb>

# ab* matches an "a", followed by any number of "b"s.
str_view(c("a", "ab", "abb"), "ab*")
#> [1] │ <a>
#> [2] │ <ab>
#> [3] │ <abb>

#> Character classes are defined by [] and let you match a set of character 
#> [abcd]. You can also invert the match by starting with ^ [^abcd] -this matches
#> anything except "a", "b", "c", "d". We can use this to find specific things 
#> such as the words containing an "x" surrounded by vowels, or  "y" surrounded
#> by constants 
#> 
str_view(words, "[aeiou]x[aeiou]")
#> [284] │ <exa>ct
#> [285] │ <exa>mple
#> [288] │ <exe>rcise
#> [289] │ <exi>st
str_view(words, "[^aeiou]y[^aeiou]")
#> [836] │ <sys>tem
#> [901] │ <typ>e


#> You can use alternation | to pick between one or more alternative patterns. 
str_view(fruit, "apple|melon|nut")
#>  [1] │ <apple>
#> [13] │ canary <melon>
#> [20] │ coco<nut>
#> [52] │ <nut>
#> [62] │ pine<apple>
#> [72] │ rock <melon>
#> ... and 1 more
str_view(fruit, "aa|ee|ii|oo|uu")
#>  [9] │ bl<oo>d orange
#> [33] │ g<oo>seberry
#> [47] │ lych<ee>
#> [66] │ purple mangost<ee>n



#> Key Functions ------ 
#> 
#> Detect Matches 
#> 
#> str_detect() returns a logical vector that is TRUE if the pattern matches an 
#> element of the character vector and FALSE otherwise. 
str_detect(c("a", "b", "c"), "[aeiou]")
#> [1]  TRUE FALSE FALSE

#> Since str_detect() returns a logical vector of the same length as the initial 
#> vector, it pairs well with filter(). 
#> This finds all the names with a lowercase "x": 
babynames |> 
  filter(str_detect(name, "x")) |> 
  count(name, wt = n, sort = TRUE)
#> # A tibble: 974 × 2
#>   name           n
#>   <chr>      <int>
#> 1 Alexander 665492
#> 2 Alexis    399551
#> 3 Alex      278705
#> 4 Alexandra 232223
#> 5 Max       148787
#> 6 Alexa     123032
#> # ℹ 968 more rows

#> We can also use str_detect() with summarize() by pairing it with sum() or 
#> mean() 
#> sum(str_detect(x, pattern)) tells ou the number of observations that match 
#> mean(str_detect(x, pattern)) tells you the proportion that match. 
#> 
#> The following computes and visualizes the proportion of baby names that 
#> contain "x", broken down by year. 
#> 
babynames |> 
  group_by(year) |> 
  summarize(prop_x = mean(str_detect(name, "x"))) |> 
  ggplot(aes(x = year, y = prop_x)) + 
  geom_line()

#> Two closely related functions are: 
#> str_subset() which returns a character vector containing only the strings that
#> match.
#> str_which() which returns an integer vector giving the positions of the strings
#> that match 
#> 
#> 
#> Count Matches 
#> 
#> str_count() tells you how many matches there are in each string (rather than a
#> true and false as str_detect() returns)
#> 
x <- c("apple", "banana", "pear")
str_count(x, "p")
#> [1] 2 0 1

#> Note that each match starts at the end of the previous match. Thus, matches
#> never overlap.
str_count("abababa", "aba")
#> [1] 2
str_view("abababa", "aba")
#> [1] │ <aba>b<aba>
#> 
#> str_count() goes well with mutate() 
#> 
#> Here we use str_count() with character classes to count the number of vowels
#> and consonants in each name
babynames |> 
  count(name) |> 
  mutate(
    vowels = str_count(name, "[aeiou]"),
    consonants = str_count(name, "[^aeiou]")
  )
#> # A tibble: 97,310 × 4
#>   name          n vowels consonants
#>   <chr>     <int>  <int>      <int>
#> 1 Aaban        10      2          3
#> 2 Aabha         5      2          3
#> 3 Aabid         2      2          3
#> 4 Aabir         1      2          3
#> 5 Aabriella     5      4          5
#> 6 Aada          1      2          2
#> # ℹ 97,304 more rows
#> 
#> You may notice that our calculations are a bit off, Aaban contains three 
#> vowels but we are only getting back that there is two. This is because regex's
#> are case sensitive
#> There are a few ways to fix this: 
#> 1: Add the uppercase vowels to the character class 
#> 2: Tell the regular expression to ignore case: 
#>    str_count(regex(name, ignore_case = TRUE), "[aeiou])
#> 3: Use str_to_lower() to conver the names to lower case: 
#>    str_count(str_to_lower(name), "[aeiou])
#>    
babynames |> 
  count(name) |> 
  mutate(
    name = str_to_lower(name),
    vowels = str_count(name, "[aeiou]"),
    consonants = str_count(name, "[^aeiou]")
  )
#> # A tibble: 97,310 × 4
#>   name          n vowels consonants
#>   <chr>     <int>  <int>      <int>
#> 1 aaban        10      3          2
#> 2 aabha         5      3          2
#> 3 aabid         2      3          2
#> 4 aabir         1      3          2
#> 5 aabriella     5      5          4
#> 6 aada          1      3          1
#> # ℹ 97,304 more rows


#> Replace Values 
#> 
#> Beyond detecting and counting matches, we can also modify them with 
#> str_replace() -replaces the first match  
#> str_replace_all() -replaces all matches 
#> 
x <- c("apple", "pear", "banana")
str_replace_all(x, "[aeiou]", "-")
#> [1] "-ppl-"  "p--r"   "b-n-n-"
#> 
#> str_remove() and str_remove_all() are handy shortcuts for 
#> str_replace(x, pattern, ""): 
x <- c("apple", "pear", "banana")
str_remove_all(x, "[aeiou]")
#> [1] "ppl" "pr"  "bnn"

#> These functions are naturally paired with mutate() when doing data cleaning, 
#> you'll often apply them repeatedly to peel off layers of inconsistent 
#> formatting! 
#> 
#> Extracting Variables 
#> 
#> Uses regular expressions to extract data out of one column into one or more
#> new coluns: 
#> separate_wider_regex() 
#> Its similar to the functions we covered in chapter 15. 
#> These functions live in tidyr because they operate on columns of data frames, 
#> rather than individual vectors. 
#> 
#> Creating a simple data set to show the power of this 
df <- tribble(
  ~str,
  "<Sheryl>-F_34",
  "<Kisha>-F_45", 
  "<Brandon>-N_33",
  "<Sharon>-F_38", 
  "<Penny>-F_58",
  "<Justin>-M_41", 
  "<Patricia>-F_84", 
)

#> To extract this data, we just need to construct a sequence of regex's that 
#> match each piece. If we want the contents of that piece to appear in the 
#> output, we give it a name: 
df |> 
  separate_wider_regex(
    str,
    patterns = c(
      "<", 
      name = "[A-Za-z]+", 
      ">-", 
      gender = ".", "_", 
      age = "[0-9]+"
    )
  )
#> # A tibble: 7 × 3
#>   name    gender age  
#>   <chr>   <chr>  <chr>
#> 1 Sheryl  F      34   
#> 2 Kisha   F      45   
#> 3 Brandon N      33   
#> 4 Sharon  F      38   
#> 5 Penny   F      58   
#> 6 Justin  M      41   
#> # ℹ 1 more row

#> If the match fails, you can use too_short = "debug" to figure out what 
#> went wrong. 
#> 
#> 
#> Pattern Details ------ 
#> 
#> Now we get into the weeds of using stringr. 
#> escaping - allows you to match metacharacters that would otherwise be treated
#> specially 
#> anchors - allow you to match the start or end of the string 
#> character classes and their shortcuts which allow ou to match any character
#> from a set. 
#> quantifiers - control how many times a pattern can match 
#> operator precedence and parentheses 
#> grouping components of the pattern 
#> 
#> 
#> Escaping 
#> 
#> In order to match a literal ., you need an escape which tells the regular
#> expression to match metacharacters. 
#> Reexps use the backslash for escaping \
#> Since we also use strings to represent regular expressions and they have the 
#> same escape we actually need two backslashes for rexps "\\."
# To create the regular expression \., we need to use \\.
dot <- "\\."

# But the expression itself only contains one \
str_view(dot)
#> [1] │ \.

# And this tells R to look for an explicit .
str_view(c("abc", "a.c", "bef"), "a\\.c")
#> [2] │ <a.c>

#> To match a backslash in a regular expression you actually need four of them
x <- "a\\b"
str_view(x)
#> [1] │ a\b
str_view(x, "\\\\")
#> [1] │ a<\>b

#> Or you can use raw strings to avoid one layer of escaping: 
str_view(x, r"{\\}")
#> [1] │ a<\>b
#> 
str_view(c("abc", "a.c", "a*c", "a c"), "a[.]c")
#> [2] │ <a.c>
str_view(c("abc", "a.c", "a*c", "a c"), ".[*]c")
#> [3] │ <a*c>

#> Anchors 
#> 
#> By default, regular expressions will match any part of a string. 
#> If you want to match at the start or end you need to anchor the regular 
#> expression using ^ to match the start or $ to match the end 

str_view(fruit, "^a")
#> [1] │ <a>pple
#> [2] │ <a>pricot
#> [3] │ <a>vocado
str_view(fruit, "a$")
#>  [4] │ banan<a>
#> [15] │ cherimoy<a>
#> [30] │ feijo<a>
#> [36] │ guav<a>
#> [56] │ papay<a>
#> [74] │ satsum<a>


#>to force a regular expression to match only the full string, anchor it with
#>both ^ and $
str_view(fruit, "apple")
#>  [1] │ <apple>
#> [62] │ pine<apple>
str_view(fruit, "^apple$")
#> [1] │ <apple>


#> You can also match the boundary between words (the start or end of a word) 
#> with \b 
#> Can be useful when using Rstudio's find and replace tool. 

x <- c("summary(x)", "summarize(df)", "rowsum(x)", "sum(x)")
str_view(x, "sum")
#> [1] │ <sum>mary(x)
#> [2] │ <sum>marize(df)
#> [3] │ row<sum>(x)
#> [4] │ <sum>(x)
str_view(x, "\\bsum\\b")
#> [4] │ <sum>(x)


#> When used alone, anchors will produce a zero-width match
str_view("abc", c("$", "^", "\\b"))
#> [1] │ abc<>
#> [2] │ <>abc
#> [3] │ <>abc<>
#> 
#> This helps yo understand what happens when you replace a standalone anchor: 
str_replace_all("abc", c("$", "^", "\\b"), "--")


#> Character Classes 
#> 
#> A character class or character set allows you to match any character in a set. 
#> You can construct your own sets with[] where [abc] matches "a", "b", or "c".
#> Using the "^" at the start matches anything that is not what follows. 
#> - defines a range, e.g. [a-g] matches any lowercase letter and [0-9] matches
#> any number
#> \ escapes special characters, so [\^\-\]] matches ^, -, or ] 

x <- "abcd ABCD 12345 -!@#%."
str_view(x, "[abc]+")
#> [1] │ <abc>d ABCD 12345 -!@#%.
str_view(x, "[a-z]+")
#> [1] │ <abcd> ABCD 12345 -!@#%.
str_view(x, "[^a-z0-9]+")
#> [1] │ abcd< ABCD >12345< -!@#%.>

# You need an escape to match characters that are otherwise
# special inside of []
str_view("a-b-c", "[a-c]")
#> [1] │ <a>-<b>-<c>
str_view("a-b-c", "[a\\-c]")
#> [1] │ <a><->b<-><c>
#> 
#> Some character classes are used so commonly that they get their own shortcut
#> 
#> \d matches and digit
#> \D matches anything that isn't a digit 
#> \s matches any whitespace (space, tab, newline)
#> \S matches anything that isn't whitespace
#> \w matches any "word" character, i.e. letters and numbers
#> \W matches any "non-word" character 
#> 
#> Examples of each: 
x <- "abcd ABCD 12345 -!@#%."
str_view(x, "\\d+")
#> [1] │ abcd ABCD <12345> -!@#%.
str_view(x, "\\D+")
#> [1] │ <abcd ABCD >12345< -!@#%.>
str_view(x, "\\s+")
#> [1] │ abcd< >ABCD< >12345< >-!@#%.
str_view(x, "\\S+")
#> [1] │ <abcd> <ABCD> <12345> <-!@#%.>
str_view(x, "\\w+")
#> [1] │ <abcd> <ABCD> <12345> -!@#%.
str_view(x, "\\W+")
#> [1] │ abcd< >ABCD< >12345< -!@#%.>


#> Quantifiers control how many times a pattern matches. 
#> 
#> You can specify the number of matches precisely with {}
#> {n} matches exactly n times
#> {n,} matches at least n times 
#> {n,m} matches between n and m times 
#> 
#> Operator Precedence and Parentheses 
#> 
#> Similar to PEMDAS with algebra, rexps have their own precedence rules: 
#> quantifiers have higher precedence and alternation has low precedence which
#> means that ab+ is equivalent to a(b+), and ^a|b$ is equivalent to (^a)|(b$)
#> Just like with algebra, you can use parenthesis to override the usual order. 
#> But you will probably forget the operation order with rexps so use the 
#> parenthesis as much as you need! 
#> 
#> Grouping and Capturing 
#> 
#> Parenthesis have another important effect: they create capturing groups that
#> allow you to use sub-components of each match. 
#> 
#> The first way to use a capturing group is to refer back to it within a match
#> with back reference: \1 refers to the match contained in the first parenthesis,
#> \2 in the second parenthsis, and so on. 
#> For example, the following pattern finds all fruits that have a repeated pair
#> of letters: 
str_view(fruit, "(..)\\1")
#>  [4] │ b<anan>a
#> [20] │ <coco>nut
#> [22] │ <cucu>mber
#> [41] │ <juju>be
#> [56] │ <papa>ya
#> [73] │ s<alal> berry
#> 
#> This one finds all words that start and end with the same pair of letters: 
str_view(words, "^(..).*\\1$")
#> [152] │ <church>
#> [217] │ <decide>
#> [617] │ <photograph>
#> [699] │ <require>
#> [739] │ <sense>
#> 
#> You can also use back references in str_replace() 
#> This code switches the order of the second and third words in sentences: 
sentences |> 
  str_replace("(\\w+) (\\w+) (\\w+)", "\\1 \\3 \\2") |> 
  str_view()
#> [1] │ The canoe birch slid on the smooth planks.
#> [2] │ Glue sheet the to the dark blue background.
#> [3] │ It's to easy tell the depth of a well.
#> [4] │ These a days chicken leg is a rare dish.
#> [5] │ Rice often is served in round bowls.
#> [6] │ The of juice lemons makes fine punch.
#> ... and 714 more
#> 
#> If you want to extract the matches for each group you can use str_match() 
#> But str_match() returns a matrix that isn't very easy to work with. 

sentences |> 
  str_match("the (\\w+) (\\w+)") |> 
  head()
#>      [,1]                [,2]     [,3]    
#> [1,] "the smooth planks" "smooth" "planks"
#> [2,] "the sheet to"      "sheet"  "to"    
#> [3,] "the depth of"      "depth"  "of"    
#> [4,] NA                  NA       NA      
#> [5,] NA                  NA       NA      
#> [6,] NA                  NA       NA
#> 
#> Could convert to a tibble and name the columns 
#> 

sentences |> 
  str_match("the (\\w+) (\\w+)") |> 
  as_tibble(.name_repair = "minimal") |> 
  set_names("match", "word1", "word2")
#> # A tibble: 720 × 3
#>   match             word1  word2 
#>   <chr>             <chr>  <chr> 
#> 1 the smooth planks smooth planks
#> 2 the sheet to      sheet  to    
#> 3 the depth of      depth  of    
#> 4 <NA>              <NA>   <NA>  
#> 5 <NA>              <NA>   <NA>  
#> 6 <NA>              <NA>   <NA>  
#> # ℹ 714 more rows
#> Doing this is basically recreating the separate_wider_regex() functions. 
#> 
#> Occasionally you want to use parentheses without creating matching groups. 
#> You can create a non-capturing group with (?:)
#> 
x <- c("a gray cat", "a grey dog")
str_match(x, "gr(e|a)y")
#>      [,1]   [,2]
#> [1,] "gray" "a" 
#> [2,] "grey" "e"
str_match(x, "gr(?:e|a)y")
#>      [,1]  
#> [1,] "gray"
#> [2,] "grey"
#> 
#> 
#> Pattern Control ----- 
#> 
#> 
#> 
#> Regex Flags 
#> 
#> There are a number of settings that can be used to control the details of the
#> regexp. These are called flags in other programming languages. 
#> In stringr, you can use these by wrapping the pattern in a call to regex() 
#> The most useful flag is probably ignore_case = TRUE 
#> 
#> 
bananas <- c("banana", "Banana", "BANANA")
str_view(bananas, "banana")
#> [1] │ <banana>
str_view(bananas, regex("banana", ignore_case = TRUE))
#> [1] │ <banana>
#> [2] │ <Banana>
#> [3] │ <BANANA>

#> dotall = TRUE lets . match everything, including \n (new lines)
x <- "Line 1\nLine 2\nLine 3"
str_view(x, ".Line")
str_view(x, regex(".Line", dotall = TRUE))
#> [1] │ Line 1<
#>     │ Line> 2<
#>     │ Line> 3

#> multiline = TRUE makes ^ and $ match the start and end of each line rather 
#> than the start and end of the complete string: 
#> 
x <- "Line 1\nLine 2\nLine 3"
str_view(x, "^Line")
#> [1] │ <Line> 1
#>     │ Line 2
#>     │ Line 3
str_view(x, regex("^Line", multiline = TRUE))
#> [1] │ <Line> 1
#>     │ <Line> 2
#>     │ <Line> 3

#> Finally, if you're writing a complicated regular expression and you're 
#> worried you might not understand it in future, you might try comments = TRUE
#> This allows you to use comments and whitespace to make complex rexps more
#> understandable 

phone <- regex(
  r"(
    \(?     # optional opening parens
    (\d{3}) # area code
    [)\-]?  # optional closing parens or dash
    \ ?     # optional space
    (\d{3}) # another three numbers
    [\ -]?  # optional space or dash
    (\d{4}) # four more numbers
  )", 
  comments = TRUE
)

str_extract(c("514-791-8141", "(123) 456 7890", "123456"), phone)
#> [1] "514-791-8141"   "(123) 456 7890" NA
#> 


#> Fixed Matches 
#> 
#> You can opt-out of the regular expression rules by using fixed() 
str_view(c("", "a", "."), fixed("."))
#> [3] │ <.>
#> This also allows you to ignore case: 
#> 
str_view("x X", "X")
#> [1] │ x <X>
str_view("x X", fixed("X", ignore_case = TRUE))
#> [1] │ <x> <X>


#> Check out the webpage for some good practice examples! 
#> Great overview on how to solve practical problems. 
#>    I'm not taking notes on it here because it does not seem very practical 
#>    for me to learn right now. May as well come back to it when I encounter 
#>    the problem. 
#>    
#>    
#> Some useful places you can use Regular Expressions: 
#> 
#> matches(pattern) will select all variables whose name matches the supplied
#> pattern. 
#> It's a tidyselect function that you can use anywhere in the tidyverse function 
#> that selects variables (e.g. select(), rename_with() and across())
#> 
#> pivot_longer()'s names_pattern argument takes a vector of regular expressions 
#> Just like separate_wider_regex(). It's useful when extracting data out of 
#> variable names with a complex structure. 
#> 
#> delim argument in separate_longer_delim() and separate_wider_delim() usually
#> matches a fixed string, but you can use regex() to make it match a pattern. 
#> this is useful, for example, if you want to match a commoa that is optionally
#> followed by a space regex(",?) 
#> 
#> Base R 
#> apropos(pattern) searches all objects from the global environment that match 
#> the given pattern. 
#> This is useful if you can't quite remember the name of a function: 
apropos("replace")

#> list.files(path, pattern) list all files in path that matches a regular 
#> expression pattern. For example, you can find all of the RMarkdown files 
#> in the current directory: 
head(list.files(pattern = "\\.Rmd$"))
#> character(0)



