### R for Data Science 
#Second Edition: Chapter 8, Data Import 

library(tidyverse)


#You can use read_csv() to read in files 

#students <- read_csv("data/students.csv")
#since I dont have this file in my folder I can't read it. 

#But I can read the file from online directly! 

students <- read_csv("https://pos.it/r4ds-students-csv")

#lets look at the data 
students

#notice that in the favourite.food column we have a N/A as a character string 
#but we want it as a true NA represented by R 
#R only recognizes empty strings as NA's 
#But we can change that by adding a piece in when we read the file in: 

students <- read_csv("https://pos.it/r4ds-students-csv", na = c("N/A", ""))

#You will also notice that "Student ID" and "Full Name" have back ticks ' around
#them. 
#This happens because there is spaces in the name, which R does not like. 

#So we should change these names to a better name plan 

students |> 
  rename(
    student_id = `Student ID`,
    full_name = `Full Name`
  )

#An alternative is to use janitor::clean_names() to change everything into 
#snake case at once 

students |> janitor::clean_names() 

#install.packages("janitor")
library(janitor)

#Looking at our data again we notice that meal_plan should be represented as a 
#factor 

students |>
  janitor::clean_names() |>
  mutate(meal_plan = factor(meal_plan))


#Next if we look at the age column we see it is a character vector because one
#row has "five" instead of the number 5. 
students <- students |>
  janitor::clean_names() |>
  mutate(
    meal_plan = factor(meal_plan),
    age = parse_number(if_else(age == "five", "5", age))
  )
#We will learn more about how to fix this issue in Chapter 21 

#A new function used here is the if_else() function which has three arguments
#The first argument test should be a logical vector. 
#The result will contain the value of the second argument, yes, whe test is TRUE, 
#and the value of the third argument, no, when it is FALSE. 
#Here we say if age is the character vector "five", make it "5", and if not, leave
#it as age. 
#We will learn more about logical vectors in Chapter 13


#If you are reading a file that does not have column names you can tell R 
#this it it will give the column names from X1 to X... 

read_csv("data", 
         col_names = FALSE
)
#Alternatively you can pass col_names a character vector which will be used
#as the column names 


read_csv("data", 
         col_names = c("var1", "var2", "etc")
)


#Besides read_csv there are several other readr functions that you can use if 
#the data is split up by different things, such as tabs or semi-colons. 



#Controlling column types ----

#readr uses a heuristic to figure out the column types and tries to be helpful 
#when bringing in data. But it does not always give the column type desired. 
#Its heuristics work well if the data is cleaned but that is rare in the real
#world. Unless you have already cleaned the data 


#Lets use this as an example: 

simple_csv <- "
  x
  10
  .
  20
  30"


read_csv(simple_csv)
#x becomes a character column here. 

#Here we can see the missing value, reprsented by "." 
#But seeing the missing value in larger data sets is hard and you will have to 
#know how to find it. 

df <- read_csv(
  simple_csv, 
  col_types = list(x = col_double())
)
#If we try to run this, which is trying to make column x a dbl column, it fails
#because we have the . which can't be a dbl.

#But read_csv() gives us a warning and tells us we can find out more with
#problems(dat) 

problems(df)
#This tells us that in row 3, column 1, it expected a dbl but it got "." 

#Now we know that the problem value is the period "." 
#So we can simply tell the csv to replace it with na when reading it in 

read_csv(simple_csv, na = ".")


#readr provides a total of 9 column types you can use: 

#col_logical() and col_double() read logicals and real numbers. 
#They’re relatively rarely needed (except as above), since readr will usually 
#guess them for you.

#col_integer() reads integers. We distinguish integers and doubles in this book 
#because they’re functionally equivalent, but reading integers explicitly 
#can occasionally be useful because they occupy half the memory of doubles.

#col_character() reads strings. This is sometimes useful to specify explicitly 
#when you have a column that is a numeric identifier, i.e. long series of digits
#that identifies some object, but it doesn’t make sense to (e.g.) divide it 
#in half, for example a phone number, social security number, 
#credit card number, etc.

#col_factor(), col_date(), and col_datetime() create factors, dates, 
#and date-times respectively; you’ll learn more about those when we get to 
#those data types in Chapter 17 and Chapter 18.

#col_number() is a permissive numeric parser that will ignore non-numeric 
#components, and is particularly useful for currencies. You’ll learn more 
#about it in Chapter 14.

#col_skip() skips a column so it’s not included in the result, which can be 
#useful for speeding up reading the data if you have a large CSV file and you 
#only want to use some of the columns.



## Reading data from multiple files ------

#Sometimes your data is split across multiple files instead of being containted
#in a single file. 
#For example, you might have sales data for each month that is in a different
#excel file for each month. 

#You can read all of this data in at once and put it in a single data frame 

sales_files <- c(
  "https://pos.it/r4ds-01-sales",
  "https://pos.it/r4ds-02-sales",
  "https://pos.it/r4ds-03-sales"
)
read_csv(sales_files, id = "file")
#the id argument adds a new column called file which specifies where the data
#came from. 

#It can get cumbersome to list all of the file names out if you have a lot of 
#them. You can simplify this if the file names have a theme: 

sales_files <- list.files("data", pattern = "sales\\.csv$", full.names = TRUE)
sales_files
#Will learn more about this in Chapter 16



## Writing to a file ------ 

#write_csv() and write_tsv() are the most important functions here. 

write_csv(students, "students.csv")


#A problem that occurs when you write something to a csv is that when you load 
#it back in, you are starting from a plain text file again. 
#This means that your factors that you saved will not be retained. 

#There are two alternatives: 

#write_rds() and read_rds() are uniform wrappers around the base R functions 
#readRDS() and saveRDS(). 
#These store data in R's custom binary format called RDS. Thus, when you reload
#the object you are loading the same exact thing! 


#The arrow package allows you to read and write parquet files, a fast binary 
#file format that can be shared across programming languages. 
#We will return to this more in depth in Chapter 23. 

#install.packages("arrow")
library(arrow)
write_parquet(students, "students.parquet")
read_parquet("students.parquet")


## Data Entry ------

#Occasionally you will need to assemble a data frame by hand. 

#tibble() is useful to create a data frame that works by column. 
tibble(
  x = c(1, 2, 5), 
  y = c("h", "m", "g"),
  z = c(0.08, 0.83, 0.60)
)

#Laying out a data frame by column can make it hard to see how the rows are 
#related. An alternative is tribble(), short for transposed tibble. 
tribble(
  ~x, ~y, ~z,
  "h", 1, 0.08,
  "m", 2, 0.83,
  "g", 5, 0.60,
)
#column names are specified by ~column name 
#data is the entered as if it were a row. 





