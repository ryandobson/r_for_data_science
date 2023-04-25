### R for Data Science 
#Second Edition: Chapter 20, Joins     

#Restart the console to start fresh! 
#ctrl + shift + F10 

library(tidyverse) 


#> Its rare in data analysis that you just have one data frame. Typically you 
#> have several data frames and you must join them together! 
#> 
#> Two Important Types of Joins: 
#> 
#> Mutating Joins: add new variables to one data frame, matching observations 
#> in another. 
#> Filtering Joins: filter observations from one data fram based on whether or
#> not they match an observation in another. 
#> 
#> Keys ------
#> 
#> Primary and Foreign Keys 
#> Every join involves this pair of keys. 
#> A primary key is a variable or set of variables that uniquely identifies each
#> observation. When more than one variable is needed, the key is called a 
#> compound key. 

library(nycflights13)
#> In this data set airlines records two pieces of data about each airline: its 
#> carrier code and its full name. You can identify an airline with its two 
#> letter carrier code, making carrier the primary key. 
airlines
#> airports records data about each airpot. You can identify each airport by its
#> three letter airport code, making faa the primary key 
airports
#> planes records data about each plane. You can identify a plane by its tail 
#> number, making tailnum the primary key 
planes
#> weather records data about the weather at the origin airports. You can identify
#> each observation by the combination of location and time, making origina and
#> time_hour the compound primary key. 
weather


#> A Foreign Key is a variable (or set of variables) that corresponds to a primary
#> key in another table. 
#> For example: 
#> flights&tailnum is a foreign key that corresponds to the primary key planes$tailnum 
#> flights$carrier is a foreign key that corresponds to the primary key airlines$carrier.
#> flights$origin is a foreign key that corresponds to the primary key airports$faa.
#> flights$dest is a foreign key that corresponds to the primary key airports$faa.
#> flights$origin-flights$time_hour is a compound foreign key that corresponds to 
#> the compound primary key weather$origin-weather$time_hour.

#> There is a visual summary of these keys in the textbook online. 
#> 
#> The primary and foreign keys almost always have the same names. Which makes
#> joining much easier. 
#> Its also worth noting the opposite relationship: almost every variable name 
#> used in multiple tables has the same meaning in each place. 
#> 
#> 
#> 
#> Checking Primary Keys 
#> 
#> Good practice to verify that they do indeed uniquely identify each observation
#> One way to do this is to count() the primary kes and look for entries where
#> n is greater than 1. 
planes |> 
  count(tailnum) |> 
  filter(n > 1)
#> # A tibble: 0 × 2
#> # ℹ 2 variables: tailnum <chr>, n <int>

weather |> 
  count(time_hour, origin) |> 
  filter(n > 1)
#> # A tibble: 0 × 3
#> # ℹ 3 variables: time_hour <dttm>, origin <chr>, n <int>
#> These keys both look good. 
#> 
#> You should also check for missing values in your primary keys - if a value is
#> missing then it can't identify an observation. 
planes |> 
  filter(is.na(tailnum))
#> # A tibble: 0 × 9
#> # ℹ 9 variables: tailnum <chr>, year <int>, type <chr>, manufacturer <chr>,
#> #   model <chr>, engines <int>, seats <int>, speed <int>, engine <chr>

weather |> 
  filter(is.na(time_hour) | is.na(origin))
#> # A tibble: 0 × 15
#> # ℹ 15 variables: origin <chr>, year <int>, month <int>, day <int>,
#> #   hour <int>, temp <dbl>, dewp <dbl>, humid <dbl>, wind_dir <dbl>, …
#> 
#> 
#> Surrogate Keys 
#> 
#> So far we haven't mentioned the primary key for flights. 
#> Its not super important here because there are no data frames that use it as 
#> a foreign key, but it's still useful to consider because its easier to work 
#> with observations if we have some way to describe them to others. 
#> 
#> After a little thinking we realize we can uniquly identify each flight with
#> three variables: 
flights |> 
  count(time_hour, carrier, flight) |> 
  filter(n > 1)
#> # A tibble: 0 × 4
#> # ℹ 4 variables: time_hour <dttm>, carrier <chr>, flight <int>, n <int>
#> 
#> You should really consider what variables can make up a good primary key. 
#> For instance, we might think that airport altitude and longitude might make
#> a good primary key but if we check it, there is a duplicate. 
airports |>
  count(alt, lat) |> 
  filter(n > 1)
#> # A tibble: 1 × 3
#>     alt   lat     n
#>   <dbl> <dbl> <int>
#> 1    13  40.6     2
#> 
#> Although our initial three variable solution seems good, it might just be 
#> easiest to introduce a simple numeric surrogate key using the row number: 
flights2 <- flights |> 
  mutate(id = row_number(), .before = 1)
flights2
#> # A tibble: 336,776 × 20
#>      id  year month   day dep_time sched_dep_time dep_delay arr_time
#>   <int> <int> <int> <int>    <int>          <int>     <dbl>    <int>
#> 1     1  2013     1     1      517            515         2      830
#> 2     2  2013     1     1      533            529         4      850
#> 3     3  2013     1     1      542            540         2      923
#> 4     4  2013     1     1      544            545        -1     1004
#> 5     5  2013     1     1      554            600        -6      812
#> 6     6  2013     1     1      554            558        -4      740
#> # ℹ 336,770 more rows
#> # ℹ 12 more variables: sched_arr_time <int>, arr_delay <dbl>, …
#> 
#> Surrogate keys like this are easier to communicate with too. Much easier to 
#> look for flight 1932 than to find UA430 which departed at 9am 2013-01-03.
#> 
#> Basic Joins -------
#> 
#> dplyr provides six join functions: 
#> left_join() 
#> inner_join()
#> right_join()
#> full_join() 
#> semi_join()
#> anti_join() 
#> 
#> They all have the same interface: they take a pair of data frames (x, y) and 
#> return a data frame. 
#> The order of the rows and columns in the output is primarily determined by x. 
#> 
#> Mutating Join 
#> allows you to combine variables from two data frames: it first matches 
#> observations by their keys, then copies across variables from one data frame
#> to the other. 
#> Like mutate(), the join functions add variables to the right. So if your 
#> data set has many variables, you won't see the new ones. 
#> 
#> Creating a simpler data set for the example: 
flights2 <- flights |> 
  select(year, time_hour, origin, dest, tailnum, carrier)
flights2

#> There are four types of mutating joins, but there is one you will use almost
#> all of the time: 
#>left_join() 
#>Its special because the output will always have the same rows as x. (You'll get
#>a warning whenever it isn't)
#>The primary use of left_join() is to add in additional metadata. 
#>For example, we can use left_join() to add the full airline name to the flights2
#>data. 
flights2 |>
  left_join(airlines)
#> Or we could find out the temp and wind speed when each plane departed: 
flights2 |> 
  left_join(weather |> select(origin, time_hour, temp, wind_speed))
#> Joining with `by = join_by(time_hour, origin)`
#> # A tibble: 336,776 × 8
#>    year time_hour           origin dest  tailnum carrier  temp wind_speed
#>   <int> <dttm>              <chr>  <chr> <chr>   <chr>   <dbl>      <dbl>
#> 1  2013 2013-01-01 05:00:00 EWR    IAH   N14228  UA       39.0       12.7
#> 2  2013 2013-01-01 05:00:00 LGA    IAH   N24211  UA       39.9       15.0
#> 3  2013 2013-01-01 05:00:00 JFK    MIA   N619AA  AA       39.0       15.0
#> 4  2013 2013-01-01 05:00:00 JFK    BQN   N804JB  B6       39.0       15.0
#> 5  2013 2013-01-01 06:00:00 LGA    ATL   N668DN  DL       39.9       16.1
#> 6  2013 2013-01-01 05:00:00 EWR    ORD   N39463  UA       39.0       12.7
#> # ℹ 336,770 more rows
#> 
#> Or what size of plane was flying: 

flights2 |> 
  left_join(planes |> select(tailnum, type, engines, seats))
#> Joining with `by = join_by(tailnum)`
#> # A tibble: 336,776 × 9
#>    year time_hour           origin dest  tailnum carrier type                
#>   <int> <dttm>              <chr>  <chr> <chr>   <chr>   <chr>               
#> 1  2013 2013-01-01 05:00:00 EWR    IAH   N14228  UA      Fixed wing multi en…
#> 2  2013 2013-01-01 05:00:00 LGA    IAH   N24211  UA      Fixed wing multi en…
#> 3  2013 2013-01-01 05:00:00 JFK    MIA   N619AA  AA      Fixed wing multi en…
#> 4  2013 2013-01-01 05:00:00 JFK    BQN   N804JB  B6      Fixed wing multi en…
#> 5  2013 2013-01-01 06:00:00 LGA    ATL   N668DN  DL      Fixed wing multi en…
#> 6  2013 2013-01-01 05:00:00 EWR    ORD   N39463  UA      Fixed wing multi en…
#> # ℹ 336,770 more rows
#> # ℹ 2 more variables: engines <int>, seats <int>
#> 
#> When left_join() fails to find a match for a row in x, it fills in the new 
#> variables with missing values. 
#> For example, there's no information about the plane with tail number N3ALAA 
#> so the type, engines, and seats will be missing. 
flights2 |> 
  filter(tailnum == "N3ALAA") |> 
  left_join(planes |> select(tailnum, type, engines, seats))
#> Joining with `by = join_by(tailnum)`
#> # A tibble: 63 × 9
#>    year time_hour           origin dest  tailnum carrier type  engines seats
#>   <int> <dttm>              <chr>  <chr> <chr>   <chr>   <chr>   <int> <int>
#> 1  2013 2013-01-01 06:00:00 LGA    ORD   N3ALAA  AA      <NA>       NA    NA
#> 2  2013 2013-01-02 18:00:00 LGA    ORD   N3ALAA  AA      <NA>       NA    NA
#> 3  2013 2013-01-03 06:00:00 LGA    ORD   N3ALAA  AA      <NA>       NA    NA
#> 4  2013 2013-01-07 19:00:00 LGA    ORD   N3ALAA  AA      <NA>       NA    NA
#> 5  2013 2013-01-08 17:00:00 JFK    ORD   N3ALAA  AA      <NA>       NA    NA
#> 6  2013 2013-01-16 06:00:00 LGA    ORD   N3ALAA  AA      <NA>       NA    NA
#> # ℹ 57 more rows

#> Specifying Join Keys 
#> 
#> By default, left_join() will use all variables that appear in both data frames
#> as the join key, the so called natural join. 
#> This is a useful heuristic but it fails at times. 
#> For example, what happens when we try to join flights2 with the complete planes
#> data set. 
flights2 |> 
  left_join(planes)
#> Joining with `by = join_by(year, tailnum)`
#> # A tibble: 336,776 × 13
#>    year time_hour           origin dest  tailnum carrier type  manufacturer
#>   <int> <dttm>              <chr>  <chr> <chr>   <chr>   <chr> <chr>       
#> 1  2013 2013-01-01 05:00:00 EWR    IAH   N14228  UA      <NA>  <NA>        
#> 2  2013 2013-01-01 05:00:00 LGA    IAH   N24211  UA      <NA>  <NA>        
#> 3  2013 2013-01-01 05:00:00 JFK    MIA   N619AA  AA      <NA>  <NA>        
#> 4  2013 2013-01-01 05:00:00 JFK    BQN   N804JB  B6      <NA>  <NA>        
#> 5  2013 2013-01-01 06:00:00 LGA    ATL   N668DN  DL      <NA>  <NA>        
#> 6  2013 2013-01-01 05:00:00 EWR    ORD   N39463  UA      <NA>  <NA>        
#> # ℹ 336,770 more rows
#> # ℹ 5 more variables: model <chr>, engines <int>, seats <int>, …
#> 
#> We get a lot of missing matches because our join is trying to use tailnum and
#> year as a compound key. Both flights and planes have a year column, but they mean 
#> different things. flights$year is the year the flight occured. planes$year 
#> is the year the plane was built. 
#> We only want to join on tailnum so we need to provide an explicit with join_by()
flights2 |> 
  left_join(planes, join_by(tailnum))
#> # A tibble: 336,776 × 14
#>   year.x time_hour           origin dest  tailnum carrier year.y
#>    <int> <dttm>              <chr>  <chr> <chr>   <chr>    <int>
#> 1   2013 2013-01-01 05:00:00 EWR    IAH   N14228  UA        1999
#> 2   2013 2013-01-01 05:00:00 LGA    IAH   N24211  UA        1998
#> 3   2013 2013-01-01 05:00:00 JFK    MIA   N619AA  AA        1990
#> 4   2013 2013-01-01 05:00:00 JFK    BQN   N804JB  B6        2012
#> 5   2013 2013-01-01 06:00:00 LGA    ATL   N668DN  DL        1991
#> 6   2013 2013-01-01 05:00:00 EWR    ORD   N39463  UA        2012
#> # ℹ 336,770 more rows
#> # ℹ 7 more variables: type <chr>, manufacturer <chr>, model <chr>, …

#> NOTE: join_by(tailnum) is short for join_by(tailnum == tailnum) 
#> It's important to know about this fuller form because it is describing the 
#> full relationship between the two tables: the keys must be equal. Thats why
#> this type of join is often called an equi-join. There are also non-equi joins
#> that are coming up in this chapter. 
#> 
#> Plus, its how you specify different join keys in each table. 
#> For example, there are two ways to join the flights2 and airports table: either
#> by dest or orign: 
flights2 |> 
  left_join(airports, join_by(dest == faa))

flights2 |> 
  left_join(airports, join_by(origin == faa))
 
#> inner_join(), right_join(), full_join() have the same interface as left_join()
#> The difference is in which rows they keep. 
#> left join keeps all the rows in x 
#> right join keeps all the rows in y
#> the full join keeps all rows in either x or y
#> the inner join only keeps rows that occur in both x and y. 
#> 
#> Filtering Joins ------
#> 
#> The primary action of these joins is to filter the rows. 
#> Two types: 
#> semi_joins -keep all rows in x that have a match in y
#> anti_joins -return all rows in x that don't have a match in y 
#> 
#> Using a semi-join to filter the airports data set to show just the origin
#> airports: 
airports |> 
  semi_join(flights2, join_by(faa == origin))
#> or just the destinations: 
airports |> 
  semi_join(flights2, join_by(faa == dest))

#> Anti joins are useful for finding implicitly missing values in the data. 
#> These are the values that only "exist" as an absence. explicit missing values
#> are represented by a NA. 
#> 
#> We can find rows that are missing from airports by looking for flights that
#> don't have a matching destination airport: 
flights2 |> 
  anti_join(airports, join_by(dest == faa)) |> 
  distinct(dest)
#> # A tibble: 4 × 1
#>   dest 
#>   <chr>
#> 1 BQN  
#> 2 SJU  
#> 3 STT  
#> 4 PSE
#> 
#> Or we can find which tailnum's are missing from planes: 
flights2 |>
  anti_join(planes, join_by(tailnum)) |> 
  distinct(tailnum)


#> How do joins work? ------
#> 
x <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  3, "x3"
)
y <- tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2",
  4, "y3"
)


#> If we consider the tibbles x and y we can think about an inner join. 
#> An inner join matches each row in the x to the row in y that has the same
#> value of key. Each match becomes a row in the output. 
#> In this case, the only key numbers that match are 1 and 2. 
#>  x has the key number 3 and y has the key number 4 but they both don't have 
#>  these key numbers. 
#> If you do an inner join, the created table will only retain the values of key
#> number one and two. 
#> Thus the inner_join() table will look like this: 
z <- tribble(
  ~key, ~val_x, ~val_y,
  1, "x1", "y1",
  2, "x2", "y2"
  
)

#> We can apply the same principle to outer joins, which keep observations as 
#> they appear in at least one of the data frames. 
#> These joins work by adding an additional "virtual" observation to each data
#> frame. 
#> This observation has a key that matches if no other ke matches, and values 
#> filled with NA. 
#> Three types of outer joins: left_join(), right_join() and full_join()
#> 
#> left_join() keeps all observations in x. 
#> Every row of x is preserved in the output because it can fall back to matching
#> a row of NA's in y. 
#> The result of a left_join() with our tibbles: 

left <- tribble(
  ~key, ~val_x, ~val_y,
  1, "x1", "y1",
  2, "x2", "y2",
  3, "x3", "NA"
  
)
#> Look here at how the x variable retained all of its key levels and then 
#> when there was not a y key to match it up with the y value just goes to NA. 

#> right_joins() do the opposite: 

right <- tribble(
  ~key, ~val_x, ~val_y,
  1, "x1", "y1",
  2, "x2", "y2",
  4, "NA", "y3"
  
)

#> Finally, full_join() keeps all observations that appear in x or y, every row
#> of x and y is included in the output. 

full <- tribble(
  ~key, ~val_x, ~val_y,
  1, "x1", "y1",
  2, "x2", "y2",
  3, "x3", "NA",
  4, "NA", "y3"
  
)

#> You can also represent all of this with venn diagrams. 
#> Go see the textbook for helpful visualizations. 
#> 
#> 
#> Row Matching 
#> 
#> Just above we looked at what happens in joins if a row in x matches zero or 
#> one rows in y. What happens if it matches more than one row? 
#> 
#> Lets focus on the inner join and think about this. 
#> Imagine we now have the following tibbles: 
w <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  3, "x3"
)
q <- tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2",
  2, "y3"
)
#> You can see that the q table now has two different y values for the key of 2. 
#> This means that when joining the table, for the second key we will want to 
#> retain two different y values in the same key spot. 
#> This means that there is no guaranteed correspondence between the rows in the
#> output and the rows in x. In practice this rarely causes problems. 
#> 
#> One particularly dangerous case of this is when you have a many-to-many join.
df1 <- tibble(key = c(1, 2, 2), val_x = c("x1", "x2", "x3"))
df2 <- tibble(key = c(1, 2, 2), val_y = c("y1", "y2", "y3"))

df1 |> 
  inner_join(df2, join_by(key))
#> Warning in inner_join(df1, df2, join_by(key)): Detected an unexpected many-to-many relationship between `x` and `y`.
#> ℹ Row 2 of `x` matches multiple rows in `y`.
#> ℹ Row 2 of `y` matches multiple rows in `x`.
#> ℹ If a many-to-many relationship is expected, set `relationship =
#>   "many-to-many"` to silence this warning.
#> # A tibble: 5 × 3
#>     key val_x val_y
#>   <dbl> <chr> <chr>
#> 1     1 x1    y1   
#> 2     2 x2    y2   
#> 3     2 x2    y3   
#> 4     2 x3    y2   
#> 5     2 x3    y3

#> Filtering Joins --how they work 
#> 
#> The semi-join keeps rows in x that have one or more matches in y. 
#> The anti-join keeps rows in x that match zero rows in y. 
#> Only the existence of a match is important with these joins, which means that
#> they never duplicate rows like mutating joins do. 

#> We have our example tribbles again 
e <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  3, "x3"
)
r <- tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2",
  4, "y3"
)
#> In a semi_join(e, r) we get the result of: 
semi_join(e, r)
semi <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2"
)
#> You can see here that we only kept the values of e if there was a matching key 
#> for e in tribble r. 
#> 
#> Anti-joins work just the opposite 
anti_join(e, r)
anti <- tribble(
  ~key, ~val_x,
  3, "x3"
)
#> Here we kept the only value of table e that does not have a matching key in 
#> table r. 
#> 

#> Non-Equi Joins -------
#> 
#> In equi-joins the x keys and y keys are always equal, so we only need to show
#> one in the output. 
#> We can request that dplyr keep both keys with keep = TRUE, leading to the code
#> below: 
x |> left_join(y, by = "key", keep = TRUE)

#> When we move away from equi-joins we will always use keep = TRUE because the
#> key values will often be different. 
#> For example, instead of matching only when x$key and y$key are equal, we could
#> match whenever the x$key is greater than or equal to the y$key.
#> 
#> Four Types of Non-Equi Joins: 
#> Cross Joins - match every pair of rows
#> Inequality Joins - use <, <=, >, and >= instead of ==
#> Rolling joins - similar to inequality oins but only find the closest match
#> Overlap Joins - special type of inequality join designed to work with ranges 
#> 
#> Cross Joins 
#> Useful when generating permutations. 
#> A cross join matches every row in x with every row in y. 
df <- tibble(name = c("John", "Simon", "Tracy", "Max"))
df |> cross_join(df)
#> # A tibble: 16 × 2
#>   name.x name.y
#>   <chr>  <chr> 
#> 1 John   John  
#> 2 John   Simon 
#> 3 John   Tracy 
#> 4 John   Max   
#> 5 Simon  John  
#> 6 Simon  Simon 
#> # ℹ 10 more rows

#> Inequality Joins
#> Use <, <=, >, and >= to restrict the set of possible matches. 
#> Hard to show a general example of what you can do with these because you 
#> can do a lot. 
#> One example is to limit a cross join to show all combinations instead of all
#> permutations. 
df <- tibble(id = 1:4, name = c("John", "Simon", "Tracy", "Max"))

df |> left_join(df, join_by(id < id))
#> # A tibble: 7 × 4
#>    id.x name.x  id.y name.y
#>   <int> <chr>  <int> <chr> 
#> 1     1 John       2 Simon 
#> 2     1 John       3 Tracy 
#> 3     1 John       4 Max   
#> 4     2 Simon      3 Tracy 
#> 5     2 Simon      4 Max   
#> 6     3 Tracy      4 Max   
#> # ℹ 1 more row

#> Rolling Joins 
#> 
#> Special type of inequality join where instead of getting every row that 
#> satisfies the inequality, you get just the closest row. 
#> You can turn any inequality join into a rolling join by adding closest()
#> 
#> These can be useful for working with dates that don't perfectly match up in 
#> two different tables. 
parties <- tibble(
  q = 1:4,
  party = ymd(c("2022-01-10", "2022-04-04", "2022-07-11", "2022-10-03"))
)
employees <- tibble(
  name = sample(babynames::babynames$name, 100),
  birthday = ymd("2022-01-01") + (sample(365, 100, replace = TRUE) - 1)
)
employees
#> Now for each employee we want to find the first part date that comes after 
#> (or on) their birthday: 
employees |> 
  left_join(parties, join_by(closest(birthday >= party)))
#> # A tibble: 100 × 4
#>   name    birthday       q party     
#>   <chr>   <date>     <int> <date>    
#> 1 Case    2022-09-13     3 2022-07-11
#> 2 Shonnie 2022-03-30     1 2022-01-10
#> 3 Burnard 2022-01-10     1 2022-01-10
#> 4 Omer    2022-11-25     4 2022-10-03
#> 5 Hillel  2022-07-30     3 2022-07-11
#> 6 Curlie  2022-12-11     4 2022-10-03
#> # ℹ 94 more rows
#>
#>One problem with this is that folks with birthdays before Jan 10 don't get a 
#>party. 
#>We can fix this with overlap joins. 
#>
#>Overlap Joins 
#>
parties <- tibble(
q = 1:4,
party = ymd(c("2022-01-10", "2022-04-04", "2022-07-11", "2022-10-03")),
start = ymd(c("2022-01-01", "2022-04-04", "2022-07-11", "2022-10-03")),
end = ymd(c("2022-04-03", "2022-07-11", "2022-10-02", "2022-12-31"))
)
parties
#> # A tibble: 4 × 4
#>       q party      start      end       
#>   <int> <date>     <date>     <date>    
#> 1     1 2022-01-10 2022-01-01 2022-04-03
#> 2     2 2022-04-04 2022-04-04 2022-07-11
#> 3     3 2022-07-11 2022-07-11 2022-10-02
#> 4     4 2022-10-03 2022-10-03 2022-12-31
#> 
#> parties |> 
inner_join(parties, join_by(overlaps(start, end, start, end), q < q)) |> 
  select(start.x, end.x, start.y, end.y)
#> # A tibble: 1 × 4
#>   start.x    end.x      start.y    end.y     
#>   <date>     <date>     <date>     <date>    
#> 1 2022-04-04 2022-07-11 2022-07-11 2022-10-02
#> 
parties <- tibble(
  q = 1:4,
  party = ymd(c("2022-01-10", "2022-04-04", "2022-07-11", "2022-10-03")),
  start = ymd(c("2022-01-01", "2022-04-04", "2022-07-11", "2022-10-03")),
  end = ymd(c("2022-04-03", "2022-07-10", "2022-10-02", "2022-12-31"))
)