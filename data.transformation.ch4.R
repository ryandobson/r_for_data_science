### R for Data Science 
#Second Edition: Chapter 4, Data Transformation 

library(tidyverse)
library(nycflights13)

#Notice the conflicts when you load the tidyverse! 
#The conflicts mean that dplyr overwrites some of the base R functions. 
#For example: 
#dplyr::filter() masks stats::filter() 
#Basically this means that base R has a filter() function that is overwritten by 
#dplyr. So when I have the tidyverse active and use filter(), the dplyr version
#is used. 
#If you want to use the base R version of filter you need to specify the full name
#of the function, which is stats::filter() 
#"stats::" is being precise about which package the function comes from. 
#For example, we could type dplyr::filter() in place of filter() if we wanted to 
#be sure about where function is coming from. 

#Now lets take a look at the flights data! 

flights
#remember that the tibble from the tidyverse automatically only prints a few 
#rows and columns so it doesn't take up a ton of space in the console. 
#If you want to see the whole data frame you can use: 
view(flights)

#If you want all of the columns printed to the console you can use: 
print(flights, width = Inf)

#Or you can just use glimpse to take a look at columns too: 
glimpse(flights) 

#Notice what type of data is in each of your columns! 
#int = integers
#dbl = double (aka real numbers) 
#chr = characters (aka strings) 
#dttm = date-time 

###These are the two different pipe operators that can be used! 
flights |> glimpse() 
flights %>% glimpse()



### MANIPULATING ROWS 

# filter() is the most important and allows you to change which rows are present 
# arrange() allows you to change the order of the rows without changing which rows are shown 
# Both of the functions above only impact the rows and do not change columns 
#distinct() finds rows with unique values, but it can also optionally modify the columns 

# Flights that departed on January 1
flights |> 
  filter(month == 1 & day == 1)
#> # A tibble: 842 × 19
#>    year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
#> 1  2013     1     1      517            515         2      830            819
#> 2  2013     1     1      533            529         4      850            830
#> 3  2013     1     1      542            540         2      923            850
#> 4  2013     1     1      544            545        -1     1004           1022
#> 5  2013     1     1      554            600        -6      812            837
#> 6  2013     1     1      554            558        -4      740            728
#> # ℹ 836 more rows
#> # ℹ 11 more variables: arr_delay <dbl>, carrier <chr>, flight <int>, …

# Flights that departed on January 1
flights |> 
  filter(month == 1 & day == 1)

# Flights that departed in January or February
flights |> 
  filter(month == 1 | month == 2)

# A shorter way to select flights that departed in January or February
flights |> 
  filter(month %in% c(1, 2))


# Remove duplicate rows, if any
flights |> 
  distinct()
#If you have a duplicate row, distinct won't find it so its a useful way to 
#get rid of duplicate rows 


# Find all unique origin and destination pairs
flights |> 
  distinct(origin, dest)


#If you want to keep other columns when filtering 
flights |> 
  distinct(origin, dest, .keep_all = TRUE)


#If you want the number of occurences of a variable use count() 

flights |>
  count(origin, dest, sort = TRUE)
#specifying sort = TRUE makes it so they are organized by most frequent to least 
#in the output 




#MANIPULATING COLUMNS 

# mutate() creates new columns that are derived from existing columns 
# select() changes which columns are present 
# rename() changes the names of the columns 
# relocate() changes the positions of the columns 


#By default mutate() places the columns on the far right side of your data frame
#If you want them to pop up on the left side you can use .before = 1 

flights |> 
  mutate(
    gain = dep_delay - arr_delay,
    speed = distance / air_time * 60,
    .before = 1
  )
#optionally, you could use .after (or .before) and specify a specific variable 
#to place the new variable in a specific location 

#You can also specify to only keep the columns that were used in the calculation 
flights |> 
  mutate(
    gain = dep_delay - arr_delay,
    hours = air_time / 60,
    gain_per_hour = gain / hours,
    .keep = "used"
  )


#Using select() to narrow down which columns are present 

#Select columns by name 
flights |> 
  select(year, month, day)

#Select all columns between year and day (inclusive) 
flights |> 
  select(year:day)

#Select all columns except those from year to day (inclusive) 
flights |> 
  select(!year:day)

#can use the "-" sign instead of "!" 
#They recommend "!" because it reads as "not" and combines well with other things


#Select all columns that are characters 
flights |> 
  select(where(is.character))

#Other helper functions with select: 
#starts_with("") 
#ends_with("") 
#contains("") 
#num_range("")

#Once you know regular expressions (chapter 16) you will be able to use matches() 
#to select variables that match a pattern. 


#You can also use select to rename variables 

flights |> 
  select(tail_num = tailnum)

#If you want to keep variables and rename them just use rename() 
flights |> 
  rename(tail_num = tailnum)


#Use relocate to specify where variables are located 

flights |> 
  relocate(time_hour, air_time)
#If you don't specify anything it moves them to the front 

#Can also specify .before and .after as done with mutate() 

flights |> 
  relocate(year:dep_time, .after = time_hour)
flights |> 
  relocate(starts_with("arr"), .before = dep_time)



## What we would need to do if we didn't have the pipe: 

arrange(
  select(
    mutate(
      filter(
        flights, 
        dest == "IAH"
      ),
      speed = distance / air_time * 60
    ),
    year:day, dep_time, carrier, flight, speed
  ),
  desc(speed)
)

#Or you would have to use a bunch of intermediate objects 
flights1 <- filter(flights, dest == "IAH")
flights2 <- mutate(flights1, speed = distance / air_time * 60)
flights3 <- select(flights2, year:day, dep_time, carrier, flight, speed)
arrange(flights3, desc(speed))




#Pipe Operator: 
# |>  is the base R pipe operator and functions perfectly well in the tidyverse 
#Its better to just use the base R pipe since it transfers out and in fine 


#WORKING WITH GROUPS

#Use group_by to divide your data set up based upon a categorical variable 
flights |> 
  group_by(month)

#summarize is used to calculate summary statistics. Reduces the data frame to have 
#a single row for each group

flights |> 
  group_by(month) |> 
  summarize(
    avg_delay = mean(dep_delay, na.rm = TRUE)
  )
#Remember to specify na.rm = TRUE so it doesn't return "NA" 


flights |> 
  group_by(month) |> 
  summarize(
    delay = mean(dep_delay, na.rm = TRUE), 
    n = n()
  )
#n is useful when you specify groups because it returns the n for each group 


# slice_ functions 

#df |> slice_head(n = 1) takes the first row from each group 
#df |> slice_tail(n = 1) takes the last row in each group 
#df |> slice_min(x, n = 1) takes the row with the smallest value of column x 
#df |> slice_max(x, n = 1) takes the row with the largest value of column x 
#df |> slice_sample(n = 1) takes one random row 

#You can vary n to select more than one row! 
#Or you can use prop = 0.1 to select (in this case) 10 of the rows in the group 

#For instance, this code finds the flights that are most delayed upon arrival 
#at each destination 
flights |> 
  group_by(dest) |> 
  slice_max(arr_delay, n = 1) |>
  relocate(dest)


#Can group by several variables 
daily <- flights |>  
  group_by(year, month, day)
daily


daily_flights <- daily |> 
  summarize(n = n())
#when you summarize a tibble grouped by more than one variable the output gets a
#bit hard to read. dplyr displays a message that tells you how to change that 
#You do so by adding .groups = ""

daily_flights <- daily |> 
  summarize(
    n = n(), 
    .groups = "drop_last"
  )
daily_flights

#Can also ungroup variables if you want to 
daily |> 
  ungroup() |>
  summarize(
    avg_delay = mean(dep_delay, na.rm = TRUE), 
    flights = n()
  )

#dplyr is also experimenting with .by as a new way to group within a single function

flights |> 
  summarize(
    delay = mean(dep_delay, na.rm = TRUE), 
    n = n(),
    .by = month
  )

#Or if you want to group by multiple variables
flights |> 
  summarize(
    delay = mean(dep_delay, na.rm = TRUE), 
    n = n(),
    .by = c(origin, dest)
  )

