### R for Data Science 
#Second Edition: Chapter 23, Arrow      

#Restart the console to start fresh! 
#ctrl + shift + F10 

library(tidyverse) 

#> CSV files are good for some things but they are not very efficient for 
#> working with them when you have to bring them in and out of R. 
#> 
#> The parquet format is an open standards-based format widely used by big data
#> systems. 
#> 
#>We'll pair parquet files with Apache Arrow, a multi-language toolbox designed 
#>for efficient analysis and transport of large data sets. 
#>We will use the arrow package which provides a dplyr backend.  
#>
#>If you are working with your own data, you will have to decide whether it is 
#>easier to convert the data to a database or put it in parquet files. 
#>In general, its hard to know what works best so you have to figure that out. 
#>
library(arrow)
library(dbplyr, warn.conflicts = FALSE)
library(duckdb)


#> Getting the Data ------
#> 
#> We will start by getting a data set worthy of these tools. 
#> The Seattle Public library has a data set with 41+ million rows that tells 
#> you how many times each book was checked out each month. 
#> 
#> The following code gets you a cached copy of the data. The data is a 9GB CSV 
#> file, curl::multidownload() is useful for getting these really large files. 
#> 
dir.create("data", showWarnings = FALSE)

curl::multi_download(
  "https://r4ds.s3.us-west-2.amazonaws.com/seattle-library-checkouts.csv",
  "data/seattle-library-checkouts.csv",
  resume = TRUE
)

#> Opening a Data set -----
#> 
#> At 9GB this file is large enough that we probably don't want to load the whole 
#> thing into memory. 
#> A good rule of thumb is that you usually want at least twice as much memory 
#> as the size of the data, and many laptops top out at 16GB. 
#> This means we want to avoid read_csv() and use arrow::open_dataset() 
seattle_csv <- open_dataset(
  sources = "data/seattle-library-checkouts.csv", 
  format = "csv"
)

#> open_dataset() will scan a few thousand rows to figure out the structure of 
#> the data. 
#> After this it records what it found and stops. It will then only read further
#> rows as you specifically request them. 
#> The metadata is what we see if we print seattle_csv
#> 
seattle_csv
#> FileSystemDataset with 1 csv file
#> UsageClass: string
#> CheckoutType: string
#> MaterialType: string
#> CheckoutYear: int64
#> CheckoutMonth: int64
#> Checkouts: int64
#> Title: string
#> ISBN: null
#> Creator: string
#> Subjects: string
#> Publisher: string
#> PublicationYear: string 

#> The first line tells you that the data is stored locally in one CSV file. 
#> The remainder tells you column types that arrow as imputed for each column 
#> 
#> We can see what's actually in with glimpse() 
seattle_csv |> glimpse()
#> FileSystemDataset with 1 csv file
#> 41,389,465 rows x 12 columns
#> $ UsageClass      <string> "Physical", "Physical", "Digital", "Physical", "Ph…
#> $ CheckoutType    <string> "Horizon", "Horizon", "OverDrive", "Horizon", "Hor…
#> $ MaterialType    <string> "BOOK", "BOOK", "EBOOK", "BOOK", "SOUNDDISC", "BOO…
#> $ CheckoutYear     <int64> 2016, 2016, 2016, 2016, 2016, 2016, 2016, 2016, 20…
#> $ CheckoutMonth    <int64> 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,…
#> $ Checkouts        <int64> 1, 1, 1, 1, 1, 1, 1, 1, 4, 1, 1, 2, 3, 2, 1, 3, 2,…
#> $ Title           <string> "Super rich : a guide to having it all / Russell S…
#> $ ISBN            <string> "", "", "", "", "", "", "", "", "", "", "", "", ""…
#> $ Creator         <string> "Simmons, Russell", "Barclay, James, 1965-", "Tim …
#> $ Subjects        <string> "Self realization, Conduct of life, Attitude Psych…
#> $ Publisher       <string> "Gotham Books,", "Pyr,", "Random House, Inc.", "Di…
#> $ PublicationYear <string> "c2011.", "2010.", "2015", "2005.", "c2004.", "c20…
#> 
#> This reveals that there are indeed 41+ million rows and 12 columns. 
#> 
#> We can start to use this dataset by using collect() to force arrow to perform
#> some computations. 
#> This code tells use the total number of checkouts per year: 
seattle_csv |> 
  count(CheckoutYear, wt = Checkouts) |> 
  arrange(CheckoutYear) |> 
  collect()
#> # A tibble: 18 × 2
#>   CheckoutYear       n
#>          <int>   <int>
#> 1         2005 3798685
#> 2         2006 6599318
#> 3         2007 7126627
#> 4         2008 8438486
#> 5         2009 9135167
#> 6         2010 8608966
#> # … with 12 more rows
#> 
#> Thanks to arrow, this code will work regardless of how large the underlying
#> data set is. 
#> But its currently rather slow: on Hadley's computer it took about 10 seconds. 
#> We can make this much better. 
#> 
#> The Parquet Format ------
#> 
#> Like CSV, parquet is used for rectangular data, but instead of text format 
#> that you can read, it's a custom binary format designed for big data. 
#> This means that: 
#> Parquet files are usually smaller than the equivalent CSV file. Makes the 
#> process faster. 
#> Parquet files have a rich type system. A CSV file does not provide any info
#> about column types. A CSV reader has to guess whether "08-10-2022" should be
#> parsed as a date or a string. In contrast, parquet files store data in a way
#> that records the type along with the data. 
#> Parquet files are "column-oriented." This means that they are organized 
#> column-by-column, much like R's data frame. This typically leads to better
#> performance for data analysis tasks compared to CSV files, which are organized
#> row-by-row. 
#> Parquet files are "chunked", which makes it possible to work on different parts
#> of the file at the same time, and if you're lucky, skip some chunks all 
#> together. 
#> 
#> Partitioning -------
#> 
#> As data sets get larger, its often useful to split up the data across multiple
#> files. 
#> When this structuring is done intelligently, it can lead to significant 
#> performance improvements. 
#> 
#> No hard and fast rules for partitioning but here are a few guidelines: 
#> Avoid files smaller than 20MB and larger than 2GB. 
#> Avoid partitions that produce more than 10,000 files. 
#> Try to partition by variables that you filter by. 
#> 
#> Rewriting the Seattle Library Data 
#> 
#> We can partition this data by checkout year to get the files in a better size. 
pq_path <- "data/seattle-library-checkouts"

seattle_csv |>
  group_by(CheckoutYear) |>
  write_dataset(path = pq_path, format = "parquet")

#> This takes a little bit to run but it pays off in the long run. 
#> 
#> Taking a look at what we just produced: 
tibble(
  files = list.files(pq_path, recursive = TRUE),
  size_MB = file.size(file.path(pq_path, files)) / 1024^2
)
#> # A tibble: 18 × 2
#>   files                            size_MB
#>   <chr>                              <dbl>
#> 1 CheckoutYear=2005/part-0.parquet    109.
#> 2 CheckoutYear=2006/part-0.parquet    164.
#> 3 CheckoutYear=2007/part-0.parquet    178.
#> 4 CheckoutYear=2008/part-0.parquet    195.
#> 5 CheckoutYear=2009/part-0.parquet    214.
#> 6 CheckoutYear=2010/part-0.parquet    222.
#> # … with 12 more rows
#> 
#> OUr 9GB CSV was rewritten into 18 parquet files. The file names use a 
#> self-describing convention used by Apache Hive. Names folders with a "key = value" 
#> format. So checkoutyear = 2005 is pretty straightforward. 
#> 
#> Each file is between 100 and 300 mb now and the total size is around 4GB. 
#> 
#> Using dplyr with arrow 
#> 
#> To read the files in again: 
seattle_pq <- open_dataset(pq_path)

#> Now we can write our dplyr pipeline. For example, we could count the total 
#> number of books check out in each month for the last five years: 
query <- seattle_pq |> 
  filter(CheckoutYear >= 2018, MaterialType == "BOOK") |>
  group_by(CheckoutYear, CheckoutMonth) |>
  summarize(TotalCheckouts = sum(Checkouts)) |>
  arrange(CheckoutYear, CheckoutMonth)

#> We can print this query object to look at the information arrow is giving us. 
#> 
#> Then we can ge the results by calling collect()
query |> collect()

#> Like dbplyr, arrow only understands some R expressions. So you won't be able
#> to use all of dplyrs verbs. 
#> You can see the full list with: 
?acero 

#> Performance 
#> 
#> As a CSV: 
seattle_csv |> 
  filter(CheckoutYear == 2021, MaterialType == "BOOK") |>
  group_by(CheckoutMonth) |>
  summarize(TotalCheckouts = sum(Checkouts)) |>
  arrange(desc(CheckoutMonth)) |>
  collect() |> 
  system.time()
#>    user  system elapsed 
#>  11.997   1.189  11.343
#>  
#>  As partition Parquet files: 
seattle_pq |> 
  filter(CheckoutYear == 2021, MaterialType == "BOOK") |>
  group_by(CheckoutMonth) |>
  summarize(TotalCheckouts = sum(Checkouts)) |>
  arrange(desc(CheckoutMonth)) |>
  collect() |> 
  system.time()
#>    user  system elapsed 
#>   0.272   0.063   0.063
#>   
#>   We had about a 100x speed up! 
#>   
#>   Using dbplyr with arrow 
#>   
#>   Its also very easy to turn an arrow data set into a DuckDB database by
#>   calling arrow::to_duckdb() 

seattle_pq |> 
  to_duckdb() |>
  filter(CheckoutYear >= 2018, MaterialType == "BOOK") |>
  group_by(CheckoutYear) |>
  summarize(TotalCheckouts = sum(Checkouts)) |>
  arrange(desc(CheckoutYear)) |>
  collect()
#> Warning: Missing values are always removed in SQL aggregation functions.
#> Use `na.rm = TRUE` to silence this warning
#> This warning is displayed once every 8 hours.
#> # A tibble: 5 × 2
#>   CheckoutYear TotalCheckouts
#>          <int>          <dbl>
#> 1         2022        2431502
#> 2         2021        2266438
#> 3         2020        1241999
#> 4         2019        3931688
#> 5         2018        3987569
