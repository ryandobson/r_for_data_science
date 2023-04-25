### R for Data Science 
#Second Edition: Chapter 22, Databases     

#Restart the console to start fresh! 
#ctrl + shift + F10 

library(tidyverse) 

#> A huge amount of data lives in databases
#> 
#> SQL = structured query language 
#> It is the lingua franca of databases and important for all data scientists
#> to learn. 
#> 
#> We will use the dbplyr package instead of SQL. This will translate your dplyr 
#> code into SQL. 
#> 
library(DBI)
library(dbplyr)

#> Database basics: 
#> 
#> Databases are like a collection of data frames. In database terminology data
#> frames are called "tables" 
#> A database table is a collection of named columns, where every value in the 
#> column is the same type. 
#> 
#> Three High Level Differences between data frames and databases: 
#> 
#> Database tables are stored on disk and can be arbitrarily large. Data frames 
#> are stored in memory, and are fundamentally limited (although that limit
#> is still pretty large) 
#> 
#> Database tables almost always have indexes, much like a book. A database 
#> index makes it possible to quickly find rows of interest without having 
#> to look at every single row. Data frames and tibbles don't have indexes. 
#> 
#> Most classical databases are optimized for rapidly collecting data, not 
#> analyzing existing data. These databases are called "row-oriented" because
#> the data is stored row-by-row, rather than column-by-column like R. Recently
#> there has been development of column-oriented databases that make analyzing
#> existing data much faster. 
#> 
#> Databases are run by database management systems (DBMS's) 
#> 
#> Come in three basic forms: 
#> Client-server
#> Cloud 
#> In-process (entirely on your computer)

#> Connecting to a Database 
#> 
#> To do this in R you will use a  pair of packages
#> DBI (database interface) 
#> A package tailored for the DBMS you're connecting to. This package translates 
#> the generic DBI commands into the specifics needed for a given DBMS 
#> 
#> You create a database connection using DBI::dbConnect() 
#> The first argument selects the DBMS, and the second and subsequent arguments 
#> describe how to connect to it. 
#> Examples: 
con <- DBI::dbConnect(
  RMariaDB::MariaDB(), 
  username = "foo"
)
con <- DBI::dbConnect(
  RPostgres::Postgres(), 
  hostname = "databases.mycompany.com", 
  port = 1234
)

#> The precise details of the connection vary a lot from DBMS to DBMS. This means
#> you will need to do a bit of research on your own for your specific situation. 
#> Typically you can talk to other people on your team. Or you can talk to your
#> DBA (database administrator) 
#> 
#> We will setup an in-process DBMS that lives entirely in an R package duckdb 
#> 
con <- DBI::dbConnect(duckdb::duckdb())

#install.packages("duckdb")
library(duckdb)

#> duckdb is a high-performance database designed for data analysis. 
#> It is capable of handling gigabytes of data with great speed. 
#> 
#> If you want to use duckdb for a real data analysis project, you'll also need
#> to supply the dbdir argument to make a persistent database and tell duckdb 
#> where to save it. 
con <- DBI::dbConnect(duckdb::duckdb(), dbdir = "duckdb")

#> Since this is a new database, we need to start by adding some data. 
#> Here we will add mpg and diamonds datasets from ggplot2 using DBI::WriteTable() 
#
dbWriteTable(con, "mpg", ggplot2::mpg)
dbWriteTable(con, "diamonds", ggplot2::diamonds)

#>If using duckdb in a real project, it is highly recommended to learn about 
#>duckdb_read_csv() and duckdb_register_arrow() 
#>These will give you a powerful way to quickly load data directly into duckdb 
#>without first having to load it into R. 
#>
#>DBI Basics ------
#>
#> Retrieving the list of tables in the database. 
dbListTables(con)
#> [1] "diamonds" "mpg"

con |> 
  dbReadTable("diamonds") |> 
  as_tibble()
#> retrieving the contents of the diamonds data table 
#> 
#> If you already know SQL, you can use dbGetQuery() to get the results of 
#> running a query on the database: 

sql <- "
  SELECT carat, cut, clarity, color, price 
  FROM diamonds 
  WHERE price > 15000
"
as_tibble(dbGetQuery(con, sql))


#> dbplyr basics ------
#> 
#> dbplyr is a dplyr back-end. Which means that you keep writing dplyr code but 
#> the back-end executes it differently. 
#> This back-end translates the code into SQL. 
#> 
#> To use dbplyr you must first use tbl() to create an object that represents
#> a database table: 
diamonds_db <- tbl(con, "diamonds")
diamonds_db

#> Many corporate databases are very large so they have some hierarchy to them 
#> and you will have to specify a few other things (see textbook) 
#> 
#> This object is "lazy" 
#> Meaning that when you use dplyr verbs on it, dplyr doesn't do any work: it 
#> just records the sequence of operations that you want to perform and only 
#> performs them when needed. 
#> For example: 
big_diamonds_db <- diamonds_db |> 
  filter(price > 15000) |> 
  select(carat:clarity, price)

big_diamonds_db
#> You can tell this object represents a database query because it prints the 
#> DBMS at the top and while it tells you the number of columns, it doesn't really 
#> know the number of rows. 
#> This is because finding the total number of rows usually requires executing 
#> the complete query, something we're trying to avoid. 

#> You can see the SQL code by the dplyr function show_query() 
big_diamonds_db |>
  show_query()

#> To get all the data back in R, you call collect(). Behind the scenes, this
#> generates the SQL, calls dbGetQuery() to get the data, then turns the result
#> into a tibble. 
big_diamonds <- big_diamonds_db |> 
  collect()
big_diamonds


#> Typically you'll use dbplyr to select the data you want from the database, 
#> performing basic filtering and aggregating using the translations described 
#> below. Then, once you are ready to analyze the data with functions that are 
#> unique to R, you'll collect() the data to get an in-memory tibble, and continue
#> your work with pure R code. 
#> 
#> SQL -----
#> 
dbplyr::copy_nycflights13(con)  #>just a built-in function for teaching 
#> Creating table: airlines
#> Creating table: airports
#> Creating table: flights
#> Creating table: planes
#> Creating table: weather
flights <- tbl(con, "flights")
planes <- tbl(con, "planes")


#> SQL BAsics 
#> 
#> Top-level components of SQL are called statements. 
#> Common statements include CREATE for defining new tables, INSERT for adding
#> data, and SELECT for retrieving data. 
#> We will focus on SELECT, also called queries, because they are almost 
#> exclusively what you'll use as a data scientist. 
#> 
#> A query is made up of clauses. 
#> There are five important clauses: SELECT, FROM, WHERE, ORDER BY, GROUP BY 
#> Every query must have SELECT and FROM clauses. The simplest query is 
#> SELECT * FROM table, which selects all columns from the specified table. 
flights |> show_query()
planes |> show_query()

#> WHERE and ORDER BY control which rows are included and how they are ordered 
flights |> 
  filter(dest == "IAH") |> 
  arrange(dep_delay) |>
  show_query()

#> GROUP BY converts the query to a summary, causing aggregation to happen 
flights |> 
  group_by(dest) |> 
  summarize(dep_delay = mean(dep_delay, na.rm = TRUE)) |> 
  show_query()

#> Two important differences between dplyr verbs and SELECT clauses: 
#> In SQL, case doesn't matter: you can write select, SELECT, or even SeLeCt. 
#>  They stick with writing SQL keywords in uppercase to distinguish them from 
#>  table or variable names. 
#> In SQL, order matters: you must always write the clauses in order SELECT,
#> FROM, WHERE, GROUP BY, ORDER BY. 
#> 
#> 
#> SELECT -----
#> 
#> The SELECT clause is the workhorse of queries and performs the same job as 
#> select(), mutate(), rename(), relocate(), and even summarize() 
#> 
planes |> 
  select(tailnum, type, manufacturer, model, year) |> 
  show_query()
#> <SQL>
#> SELECT tailnum, "type", manufacturer, model, "year"
#> FROM planes

planes |> 
  select(tailnum, type, manufacturer, model, year) |> 
  rename(year_built = year) |> 
  show_query()
#> <SQL>
#> SELECT tailnum, "type", manufacturer, model, "year" AS year_built
#> FROM planes

planes |> 
  select(tailnum, type, manufacturer, model, year) |> 
  relocate(manufacturer, model, .before = type) |> 
  show_query()
#> <SQL>
#> SELECT tailnum, manufacturer, model, "type", "year"
#> FROM planes

#> The translations for mutate() are similarly straightforward: each variables
#> becomes a new expression in SELECT: 
flights |> 
  mutate(
    speed = distance / (air_time / 60)
  ) |> 
  show_query()
#> <SQL>
#> SELECT *, distance / (air_time / 60.0) AS speed
#> FROM flights


#> FROM -----
#> 
#> The FROM clause defines the data source. This is uninteresting right now 
#> because we are just using single tables. We will see more complex examples
#> when we hit the join functions. 
#> 
#> GROUP BY -----
#> 
diamonds_db |> 
  group_by(cut) |> 
  summarize(
    n = n(),
    avg_price = mean(price, na.rm = TRUE)
  ) |> 
  show_query()
#> <SQL>
#> SELECT cut, COUNT(*) AS n, AVG(price) AS avg_price
#> FROM diamonds
#> GROUP BY cut

#> WHERE ------
#> 
#> filter() is translated to the WHERE clause. 
flights |> 
  filter(dest == "IAH" | dest == "HOU") |> 
  show_query()
#> <SQL>
#> SELECT *
#> FROM flights
#> WHERE (dest = 'IAH' OR dest = 'HOU')

flights |> 
  filter(arr_delay > 0 & arr_delay < 20) |> 
  show_query()
#> <SQL>
#> SELECT *
#> FROM flights
#> WHERE (arr_delay > 0.0 AND arr_delay < 20.0)
#> 
#> Another useful SQL operator is IN, which is very close to R's %in% 
flights |> 
  filter(dest %in% c("IAH", "HOU")) |> 
  show_query()
#> <SQL>
#> SELECT *
#> FROM flights
#> WHERE (dest IN ('IAH', 'HOU'))

#> SQL uses NULL instead of NA. NULL's behave similarly to NA's. The main 
#> difference is that while they are "infectious" in comparisons and arithmetic, 
#> they are silently dropped when summarizing. 
flights |> 
  group_by(dest) |> 
  summarize(delay = mean(arr_delay))
#> Warning: Missing values are always removed in SQL aggregation functions.
#> Use `na.rm = TRUE` to silence this warning
#> This warning is displayed once every 8 hours.
#> # Source:   SQL [?? x 2]
#> # Database: DuckDB 0.7.1 [unknown@Linux 5.15.0-1035-azure:R 4.2.3/:memory:]
#>   dest  delay
#>   <chr> <dbl>
#> 1 ORD   5.88 
#> 2 FLL   8.08 
#> 3 IAH   4.24 
#> 4 MIA   0.299
#> 5 DCA   9.07 
#> 6 SLC   0.176
#> # ℹ more rows

#> In general, you can work with NULLs using the functions you'd use for NA's in R 
flights |> 
  filter(!is.na(dep_delay)) |> 
  show_query()
#> <SQL>
#> SELECT *
#> FROM flights
#> WHERE (NOT((dep_delay IS NULL)))
#> 
#> Here you start to see how the SQL code is not quite as intuitive to write as 
#> code in the tidyverse is. 


diamonds_db |> 
  group_by(cut) |> 
  summarize(n = n()) |> 
  filter(n > 100) |> 
  show_query()
#> <SQL>
#> SELECT cut, COUNT(*) AS n
#> FROM diamonds
#> GROUP BY cut
#> HAVING (COUNT(*) > 100.0)
#> 
#> The HAVING clause pops up because of the order by which SQL does operations 
#> and the filter() created after summarize is out of order for SQL
#> 
#> ORDER BY -----
#> 
#> Involves a straightforward translation from arrange() to the ORDER BY clause: 
flights |> 
  arrange(year, month, day, desc(dep_delay)) |> 
  show_query()
#> <SQL>
#> SELECT *
#> FROM flights
#> ORDER BY "year", "month", "day", dep_delay DESC
#> 
#> Subqueries ----- 
#> 
#> Sometimes its not possible to translate a dplyr pipeline into a single SELECT
#> statement and you need to use a subquery. 
#> A subquery is just a query used as a data source in the FROM clause, instead
#> of the usual table. 
#> dbplyr typically uses subqueries to work around the limitations of SQL. 
#> 
flights |> 
  mutate(
    year1 = year + 1,
    year2 = year1 + 1
  ) |> 
  show_query()
#> <SQL>
#> SELECT *, year1 + 1.0 AS year2
#> FROM (
#>   SELECT *, "year" + 1.0 AS year1
#>   FROM flights
#> ) q01
#> 
#> You can see the FROM clause generating a second SELECT function to deal with 
#> the newly created variable in the mutate element. 
#> You'll see similar things happen with filter: 
flights |> 
  mutate(year1 = year + 1) |> 
  filter(year1 == 2014) |> 
  show_query()
#> <SQL>
#> SELECT *
#> FROM (
#>   SELECT *, "year" + 1.0 AS year1
#>   FROM flights
#> ) q01
#> WHERE (year1 = 2014.0)


#> Joins -----
#> 
#> SQL joins are very similar to dplyr's 
flights |> 
  left_join(planes |> rename(year_built = year), by = "tailnum") |> 
  show_query()
#> <SQL>
#> SELECT
#>   flights.*,
#>   planes."year" AS year_built,
#>   "type",
#>   manufacturer,
#>   model,
#>   engines,
#>   seats,
#>   speed,
#>   engine
#> FROM flights
#> LEFT JOIN planes
#>   ON (flights.tailnum = planes.tailnum)
#>   
#>
#> When working with data from a database, joins are very common and a key part 
#> of the work you will be doing. 
#> Often data is stored in a manner that will force you to connect it from 
#> several places. 
#> The dm package by a few people can be a life saver for helping you determine
#> the connections between tables and which keys you can use to connect people
#> in tables. 
#> 
#> Other Verbs -----
#> 
#> dbplyr also translates other verbs like distinct() slice_*() and intersect() 
#> and a growing number of tidyr verbs like pivot_longer() and pivot_wider() 
#> Can see a full set at: https://dbplyr.tidyverse.org/reference/


#> Function Translations ----- 
#> 
#> We are going to zoom in a bit and look at the translation of the R functions 
#> that work with individual columns - mean(), summarize() 
#> 
summarize_query <- function(df, ...) {
  df |> 
    summarize(...) |> 
    show_query()
}
mutate_query <- function(df, ...) {
  df |> 
    mutate(..., .keep = "none") |> 
    show_query()
}

flights |> 
  group_by(year, month, day) |>  
  summarize_query(
    mean = mean(arr_delay, na.rm = TRUE),
    median = median(arr_delay, na.rm = TRUE)
  )
#> `summarise()` has grouped output by "year" and "month". You can override
#> using the `.groups` argument.
#> <SQL>
#> SELECT
#>   "year",
#>   "month",
#>   "day",
#>   AVG(arr_delay) AS mean,
#>   PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY arr_delay) AS median
#> FROM flights
#> GROUP BY "year", "month", "day"
#> 
#> The translation of summary functions becomes more complicated when you use
#> them inside a mutate() because they have to turn into so-called Window functions. 
#> In SQL, you turn an ordinary aggregation function into a window function by 
#> adding OVER after it: 
flights |> 
  group_by(year, month, day) |>  
  mutate_query(
    mean = mean(arr_delay, na.rm = TRUE),
  )
#> <SQL>
#> SELECT
#>   "year",
#>   "month",
#>   "day",
#>   AVG(arr_delay) OVER (PARTITION BY "year", "month", "day") AS mean
#> FROM flights
#> 
#> Also adds the PARTITION BY argument in certain cases: 
flights |> 
  group_by(dest) |>  
  arrange(time_hour) |> 
  mutate_query(
    lead = lead(arr_delay),
    lag = lag(arr_delay)
  )
#> <SQL>
#> SELECT
#>   dest,
#>   LEAD(arr_delay, 1, NULL) OVER (PARTITION BY dest ORDER BY time_hour) AS lead,
#>   LAG(arr_delay, 1, NULL) OVER (PARTITION BY dest ORDER BY time_hour) AS lag
#> FROM flights
#> ORDER BY time_hour
#> 
#> 
#> CASE WHEN pops up in SQL as a translation of if_else() 

flights |> 
  mutate_query(
    description = if_else(arr_delay > 0, "delayed", "on-time")
  )
#> <SQL>
#> SELECT CASE WHEN (arr_delay > 0.0) THEN 'delayed' WHEN NOT (arr_delay > 0.0) THEN 'on-time' END AS description
#> FROM flights
flights |> 
  mutate_query(
    description = 
      case_when(
        arr_delay < -5 ~ "early", 
        arr_delay < 5 ~ "on-time",
        arr_delay >= 5 ~ "late"
      )
  )
#> <SQL>
#> SELECT CASE
#> WHEN (arr_delay < -5.0) THEN 'early'
#> WHEN (arr_delay < 5.0) THEN 'on-time'
#> WHEN (arr_delay >= 5.0) THEN 'late'
#> END AS description
#> FROM flights
#> 
#> CASE WHEN is also used for some functions that don't have a direct translation
#> into SQL, such as cut() 
flights |> 
  mutate_query(
    description =  cut(
      arr_delay, 
      breaks = c(-Inf, -5, 5, Inf), 
      labels = c("early", "on-time", "late")
    )
  )
#> <SQL>
#> SELECT CASE
#> WHEN (arr_delay <= -5.0) THEN 'early'
#> WHEN (arr_delay <= 5.0) THEN 'on-time'
#> WHEN (arr_delay > 5.0) THEN 'late'
#> END AS description
#> FROM flights
#> 
#> 
#> 