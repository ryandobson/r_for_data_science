### R for Data Science 
#Second Edition: Chapter 17, Factors   

#Restart the console to start fresh! 
#ctrl + shift + F10 

library(tidyverse)

#> Factors are used for categorical variables, variables that have a fixed and 
#> known set of possible values. 
#> They are also useful wehn you want to display character vectors in a 
#> non-alphabetical order. 
#> 
#> forcats package is used here which is part of the base tidyverse 
#> 
#> Factor Basics -------
#> A variable that records months 
x1 <- c("Dec", "Apr", "Jan", "Mar")
#>Using a string to record this variable has two problems: 
#>1: there are only twelve possible months, and nothing to stop you from a typo 
#>2: it doesn't sort in a useful way (sorts alphabetically)
x2 <- c("Dec", "Apr", "Jam", "Mar")
#>
#>
#>To create a factor you must start by creating a list of the valid levels

month_levels <- c(
  "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
)

#> Now you can create a factor: 

y1 <- factor(x1, levels = month_levels)
y1

sort(y1)

#> Any values not in the level will be silently converted to NA 
y2 <- factor(x2, levels = month_levels)
y2
#> [1] Dec  Apr  <NA> Mar 
#> Levels: Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
#> 
#> This seems risky so ou might want to use forcats::fct() instead 

y2 <- fct(x2, levels = month_levels)
#> Error in `fct()`:
#> ! All values of `x` must appear in `levels` or `na`
#> ℹ Missing level: "Jam"
#> Using this will tell you if there is a missing value - such as "Jam" because
#> of a typo 
#> 
#> If you omit the levels, they'll be taken from the data in alphabetical order
factor(x1)
#> sorting alphabetically is slightly risky because not every computer will sort
#> strings in the same way. 
#> forcats::fct() orders by first appearance: 
fct(x1)


#> If you need to directly access the levels of a factor use levels()
levels(y2)


#>You can also create a factor when reading your data with readr with col_factor()

csv <- "
month,value
Jan,12
Feb,56
Mar,12"

df <- read_csv(csv, col_types = cols(month = col_factor(month_levels)))
df$month
#> [1] Jan Feb Mar
#> Levels: Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
#> 
#> 
#> General Social Survey ------
#> 
#>Looking at the data set we will be using
gss_cat

#> When factors are stored in a tibble, you can't see their levels so easily. 
#> One way to view them is with count. 
gss_cat |> 
  count(race)

#> When working with factors, the two most common operations are changing the 
#> order of the levels and changing the values of the levels. 
#> 
#> 
#> Modifying Factor Order ------ 
#> 
#> Its often useful to change the order of the factor levels in a visualization. 
#> Exploring the average number of hours spent watching TV per day across religions
#>
relig_summary <- gss_cat |>
  group_by(relig) |>
  summarize(
    tvhours = mean(tvhours, na.rm = TRUE),
    n = n()
  )

ggplot(relig_summary, aes(x = tvhours, y = relig)) + 
  geom_point()
#> Its pretty hard to read this plot because there is no overall pattern. 
#> We can improve it by reordering the levels of relig using fct_reorder() 
#> 
#> factor_reoarder() takes three arguments: 
#> f, the factor whose levels you want to modify 
#> x, a numeric vector that you want to use to reorder the levels 
#> optionally, fun, a function thats used if there are multiple values of x for 
#> each value of f. The default value is median. 

ggplot(relig_summary, aes(x = tvhours, y = fct_reorder(relig, tvhours))) +
  geom_point()

#> As you start making more complicated transformations, we recommend moving them
#> out of aes() and into a separate mutate() step: 
relig_summary |>
  mutate(
    relig = fct_reorder(relig, tvhours)
  ) |>
  ggplot(aes(x = tvhours, y = relig)) +
  geom_point()

#> What if we create a similar plot looking at how average age varies across 
#> reported income level? 
rincome_summary <- gss_cat |>
  group_by(rincome) |>
  summarize(
    age = mean(age, na.rm = TRUE),
    n = n()
  )

ggplot(rincome_summary, aes(x = age, y = fct_reorder(rincome, age))) + 
  geom_point()
#> Here, arbitrarily reordering the levels isn't a good idea! Thats because 
#> rincome already has a principled order that we shouldn't mess with. 
#> Reserve fct_reorder() for factors whose levels are arbitrarily ordered. 
#> 
#> However, it does make sense to pull "Not applicable" to the front with the 
#> other special levels. 
#> YOu can use fct_relevel() for this. It takes a factor, f, and then any number
#> of levels that you want to move to the front of the line. 

ggplot(rincome_summary, aes(x = age, y = fct_relevel(rincome, "Not applicable"))) +
  geom_point()


#> Another type of reordering is useful when you are coloring the lines on a plot
#> fct_reorder(f, x, y) reorders the factor f by the y values associated with the
#> largest x values. 

by_age <- gss_cat |>
  filter(!is.na(age)) |> 
  count(age, marital) |>
  group_by(age) |>
  mutate(
    prop = n / sum(n)
  )

ggplot(by_age, aes(x = age, y = prop, color = marital)) +
  geom_line(linewidth = 1) + 
  scale_color_brewer(palette = "Set1")

ggplot(by_age, aes(x = age, y = prop, color = fct_reorder2(marital, age, prop))) +
  geom_line(linewidth = 1) +
  scale_color_brewer(palette = "Set1") + 
  labs(color = "marital") 

#> Finally, for bar plots, you can use fct_infreq() to order levels in decreasing
#> frequency: combine it with fct_rev() if you want them in increasing ferquency.
#> 
gss_cat |>
  mutate(marital = marital |> fct_infreq() |> fct_rev()) |>
  ggplot(aes(x = marital)) +
  geom_bar()


#> Modifying Factor Levels ------ 
#> 
#> fct_recode() is the function here. 
#> It allows you to recode, or change, the value of each level. 

gss_cat |> count(partyid)
#> # A tibble: 10 × 2
#>   partyid                n
#>   <fct>              <int>
#> 1 No answer            154
#> 2 Don't know             1
#> 3 Other party          393
#> 4 Strong republican   2314
#> 5 Not str republican  3032
#> 6 Ind,near rep        1791
#> # ℹ 4 more rows
#> The levels in the above partyid column are pretty rough names. 
#> 
gss_cat |>
  mutate(
    partyid = fct_recode(partyid,
                         "Republican, strong"    = "Strong republican",
                         "Republican, weak"      = "Not str republican",
                         "Independent, near rep" = "Ind,near rep",
                         "Independent, near dem" = "Ind,near dem",
                         "Democrat, weak"        = "Not str democrat",
                         "Democrat, strong"      = "Strong democrat"
    )
  ) |>
  count(partyid)
#> # A tibble: 10 × 2
#>   partyid                   n
#>   <fct>                 <int>
#> 1 No answer               154
#> 2 Don't know                1
#> 3 Other party             393
#> 4 Republican, strong     2314
#> 5 Republican, weak       3032
#> 6 Independent, near rep  1791
#> # ℹ 4 more rows


#> fct_recode() will leave the levels that aren't explicitly mentioned and will 
#> warn you if you refer to a level that does not exist. 
#> 
#> To combine groups you can assign multiple old levels to the same new level: 
gss_cat |>
  mutate(
    partyid = fct_recode(partyid,
                         "Republican, strong"    = "Strong republican",
                         "Republican, weak"      = "Not str republican",
                         "Independent, near rep" = "Ind,near rep",
                         "Independent, near dem" = "Ind,near dem",
                         "Democrat, weak"        = "Not str democrat",
                         "Democrat, strong"      = "Strong democrat",
                         "Other"                 = "No answer",
                         "Other"                 = "Don't know",
                         "Other"                 = "Other party"
    )
  )


#> If you want to collapse a lot of levels, fct_collaspe() is a useful variant
#> of fct_recode() 
#> For each new variable, you can provide a vector of old levels: 
gss_cat |>
  mutate(
    partyid = fct_collapse(partyid,
                           "other" = c("No answer", "Don't know", "Other party"),
                           "rep" = c("Strong republican", "Not str republican"),
                           "ind" = c("Ind,near rep", "Independent", "Ind,near dem"),
                           "dem" = c("Not str democrat", "Strong democrat")
    )
  ) |>
  count(partyid)
#> # A tibble: 4 × 2
#>   partyid     n
#>   <fct>   <int>
#> 1 other     548
#> 2 rep      5346
#> 3 ind      8409
#> 4 dem      7180


#> Sometimes you just want to lump together all of the small groups to make a 
#> plot or table simpler. 
#> fct_lump_ functions will help with this. 
#> fct_lump_lowfreq() is a simple starting point. 
#> It progressively lumps the smallest groups categories into "other" 
#>  Always keeping "other" as the smallest category 
gss_cat |>
  mutate(relig = fct_lump_lowfreq(relig)) |>
  count(relig)
#> # A tibble: 2 × 2
#>   relig          n
#>   <fct>      <int>
#> 1 Protestant 10846
#> 2 Other      10637

#> That reduces are groups a bit more than necessary though. 
#> We can use fct_lump_n() to specify that we want exactly 10 groups: 
gss_cat |>
  mutate(relig = fct_lump_n(relig, n = 10)) |>
  count(relig, sort = TRUE)
#> # A tibble: 10 × 2
#>   relig          n
#>   <fct>      <int>
#> 1 Protestant 10846
#> 2 Catholic    5124
#> 3 None        3523
#> 4 Christian    689
#> 5 Other        458
#> 6 Jewish       388
#> # ℹ 4 more rows

#> There are also 
#> fct_lump_min() 
#> fct_lump_prop() 


#> Ordered Factors ------
#> 
#> Ordered factors, created with ordered(), imply a strict ordering and equal
#> distance between levels: the first level is "less than" the second level 
#> by the same amount that the second level is "less than" the third level...
#> 
#> You can recognize them in print because they use < between factor levels. 
ordered(c("a", "b", "c"))
#> [1] a b c
#> Levels: a < b < c

#> Not generally recommended to use ordered factors. 
#> 

