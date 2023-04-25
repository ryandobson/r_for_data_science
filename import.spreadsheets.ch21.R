### R for Data Science 
#Second Edition: Chapter 21, Spreadsheets      

#Restart the console to start fresh! 
#ctrl + shift + F10 

library(tidyverse) 
library(readxl)
library(writexl)
#install.packages("writexl")

#> Reading Excel Spreadsheets -------

students <- read_excel("data/students.xlsx")

read_excel(
  "data/students.xlsx",
  col_names = c("student_id", "full_name", "favourite_food", "meal_plan", "age"),
  skip = 1, #ensures that it skips the original column headers and uses ours that we listed above
  na = c("", "N/A"), #ensuring that explicitly typed NAs in the excel document come in as truly NA in R
  col_types = c("numeric", "text", "text", "text", "text")
  )

#> We now have the problem that one of our ages was listed as "five" instead of "5" 
#> Thus, if we try to change the column types on entry to numeric, that "five" is 
#> changed to a NA 
#> So we load in the data as above - specifying our age column as "text" instead
#> of "numeric" 
#> Then we make the change: 

students <- students |> 
  mutate(
    age = if_else(age == "five", "5", age),
    age = parse_number(age)
  )
  
#> It is recommended to open the Excel file and make a copy of it and then you 
#> can peek around in that while doing the data entry to ensure things transfered
#> well. 


#> Reading Worksheets -----
#> 
#> Excel spreadsheets have the ability to have multiple worksheets. 
#> You can read in a specific worksheet with the sheet = argument. 
#> 

read_excel("data/penquins.xlsx", sheet = "Torgersen Island")

penguins_torgersen <- read_excel("data/penguins.xlsx", 
                                 sheet = "Torgersen Island", 
                                 na = "NA")
penguins_torgersen

#> Can use excel_sheets() to get information on what sheets are in the file. 
excel_sheets("data/penguins.xlsx")
#> [1] "Torgersen Island" "Biscoe Island"    "Dream Island"

#> After you know the names of the worksheets you can load them in separately. 
penguins_biscoe <- read_excel("data/penguins.xlsx", sheet = "Biscoe Island", na = "NA")
penguins_dream  <- read_excel("data/penguins.xlsx", sheet = "Dream Island", na = "NA")


#> In this case, the full penguins dataset is spread across three worksheets in 
#> the spreadsheet. 
#> Each worksheet has the same number of columns but different numbers of rows. 
#> 
#> We can put them together with bind_rows() 
penguins <- bind_rows(penguins_torgersen, penguins_biscoe, penguins_dream)
penguins
#> # A tibble: 344 × 8
#>   species island    bill_length_mm bill_depth_mm flipper_length_mm
#>   <chr>   <chr>              <dbl>         <dbl>             <dbl>
#> 1 Adelie  Torgersen           39.1          18.7               181
#> 2 Adelie  Torgersen           39.5          17.4               186
#> 3 Adelie  Torgersen           40.3          18                 195
#> 4 Adelie  Torgersen           NA            NA                  NA
#> 5 Adelie  Torgersen           36.7          19.3               193
#> 6 Adelie  Torgersen           39.3          20.6               190
#> # ℹ 338 more rows
#> # ℹ 3 more variables: body_mass_g <dbl>, sex <chr>, year <dbl>


#> Reading part of a sheet. 
#> You will frequently encounter spreadsheets that have headers and other info 
#> that you don't want to load into your data set. 
#> 
#> An example data set is included with the readxl package and we can find it with
deaths_path <- readxl_example("deaths.exls")
deaths <- read_excel(deaths_path)
#> NOTE: it didn't load in but thats fine. Can still take everything away from the
#> example. 
#> We don't want to load in the first four rows and the bottom four rows. So we
#> can just select a row range. 
read_excel(deaths_path, range = "A5:F15")

#> Data Types 
#> In CSV files, all values are strings. 
#> Underlying data in Excel spreadsheets is more complex: 
#> boolean - like true, false, or NA 
#> number - like "10" or "10.5" 
#> datetime 
#> text string - like "ten" 
#> 
#> It is important to realize that the underlying data that you want might be 
#> very different than what you are seeing in R. 
#> You can let readxl guess the column types and then adjust if you need to if 
#> it does not load them in correctly. 
#> 
#> It gets especially tricky when you have a column type in the Excel spreadsheet
#> with multiple data types 
#> 
#> Writing to Excel ----- 
#> 
#> Small example data frame. 
bake_sale <- tibble(
  item     = factor(c("brownie", "cupcake", "cookie")),
  quantity = c(10, 5, 8)
)

bake_sale

write_xlsx(bake_sale, path = "bake-sale.xlsx")
#> Just like with CSV files, information on data type is lost when we read the 
#> data back in. 
read_excel("bake-sale.xlsx")

#> Formatted Output: 
#> 
#> If you are interested in writing to sheets within a spreadsheet and styling 
#> you will want to use the
#> openxlsx package. 
#> https://ycphs.github.io/openxlsx/articles/Formatting.html
#> 


#> Google Sheets ------
#> 
library(googlesheets4)

#> The main function with this package is read_sheet() 
#> also goes by range_read() 
#> Can create a brand new sheet with gs4_create() 
#> or write to an existing sheet with 
#> sheet_write() 
#> 
students_url <- "https://docs.google.com/spreadsheets/d/1V1nPp1tzOuutXFLb3G9Eyxi3qxeEhnOXUzL5_BcCQ0w"
students <- read_sheet(students_url)
#> ✔ Reading from students.
#> ✔ Range Sheet1.
students

students <- read_sheet(
  students_url,
  col_names = c("student_id", "full_name", "favourite_food", "meal_plan", "age"),
  skip = 1,
  na = c("", "N/A"),
  col_types = "dcccc" #> Means "double" "character" "character"...
)
#> ✔ Reading from students.
#> ✔ Range 2:10000000.

penguins_url <- "https://docs.google.com/spreadsheets/d/1aFu8lnD_g0yjF5O-K6SFgSEWiHPpgvFCF0NY9D6LXnY"
read_sheet(penguins_url, sheet = "Torgersen Island")
sheet_names(penguins_url)
#> [1] "Torgersen Island" "Biscoe Island"    "Dream Island"
#> 
#> 
deaths_url <- gs4_example("deaths")
deaths <- read_sheet(deaths_url, range = "A5:F15")

#> Writing to Google Sheets 
#>
write_sheet(bake_sale, ss = "bake-sale", sheet = "Sales")
#> data frame to write to, name of the google sheet to write, and sheet name 

gs4_auth(email = "rdobson17@gmail.com")

