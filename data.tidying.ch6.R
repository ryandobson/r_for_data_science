### R for Data Science 
#Second Edition: Chapter 6, Data tidying 

library(tidyverse)


### RULES THAT MAKE A DATASET TIDY 

#Each variable is a column; each column is a variable 
#Each observation is a row; each row is an observation 
#Each value is a cell; each cell is a single value 


# pivot_longer() 

#checking out the data set 
billboard
#each observation is a song and the first three variables give information about 
#that song. Then each column is a week and the number that song was on the billboard 


#Tidying the data 
billboard |> 
  pivot_longer(
    cols = starts_with("wk"), 
    names_to = "week", 
    values_to = "rank"
  )
#cols specifies which columns need to be pivoted (which columns aren't variables)
# we could also use cols = !c(artist, track, data.entered) 
#   The above reads as select not artist, track, and data.entered. So select all
#of the wks columns. 

#names_to specifies the name of the new variable after the pivot. 

#values_to specifies the variable stored in the cell values 

#in names_to and values_to "week" and "rank" are in quotation marks because they
#are new variables we are creating and they don't exist in our dataset. 


#If we look at the new dataset it appears that 2 pac's baby don't cry was only 
#on the billboard top 100 songs for 7 weeks. Since the NA's don't really represent
#anything here we can drop them. 

billboard |> 
  pivot_longer(
    cols = starts_with("wk"), 
    names_to = "week", 
    values_to = "rank",
    values_drop_na = TRUE
  )


#Now we have the weeks column where each data point is "wk1" "wk2" etc. 
#These are character strings that are not useful for computation. 
#we can use mutate and parse_number to fix this. 
#parse_number extracts the first number froma string, ignoring all other text 

billboard_longer <- billboard |> 
  pivot_longer(
    cols = starts_with("wk"), 
    names_to = "week", 
    values_to = "rank",
    values_drop_na = TRUE
  ) |> 
  mutate(
    week = parse_number(week)
  )


#Now that our data is tidy we are in a good spot to visualize it! 

#We will start by looking at song rank over time 

billboard_longer |> 
  ggplot(aes(x = week, y = rank, group = track)) + 
  geom_line(alpha = 0.25) + 
  scale_y_reverse()



#Handling when you have many variables in column names 

#looking at the dataset
who2

#The dataset has six pieces of information recorded in it. 
#country and year which are already their own columns. 
#Then we have 56 columns where the column header has 3 pieces of information
#method of diagnosis 
#the gender category 
#the age range 
#Finally, the count of patients in the relavent category are in the cell values 
#under those 56 columns 

#We want to get these 6 pieces of information in 6 separate columns 

who2 |> 
  pivot_longer(
    cols = !(country:year),
    names_to = c("diagnosis", "gender", "age"), 
    names_sep = "_",
    values_to = "count"
  )
#Here the names_sep is separating the column headers by the "_" which is how the
#column headers are written
#An alternative to this is names_pattern - which you can use to extract variables
#from more complicated naming scenarios. After learning regular expressions in 
#Chapter 16 this will be doable 



#Data and variable names in the column headers

#This situation is more complex because the column names include a mix of 
#variable values and variable names 

#looking at the data set
household

#Here we have five families and information about them. 
#The complex thing here is that the column names contain the names of two variables:
#dob and name 
#But they also contain values of another (child, with values 1 or 2)

#To solve this problem we use ".value" in pivot_longer

household |> 
  pivot_longer(
    cols = !family,  #select columns not named "family" 
    names_to = c(".value", "child"), 
    names_sep = "_", 
    values_drop_na = TRUE #since there is a family with only one child, we can drop the pointless row for that 
  )


#When ou use .value in names_to, the column names in the input contribute to 
#both values and variable names in the output 

#pivoting with names_to = c(".value", "id") splits the column names into two 
#components: the first part determines the output column name (x or y) and the
#second part determines the value of the id column 

#In the family case, .value is selecting dob and name and is grabbing values of 
#child1 and child2 and putting them into an id column 



### WIDENING DATA------------


#pivot_wider() makes data sets wider by increasing columns and reducing rows 

#This is helpful when one observation is spread across multiple rows 

#looking at the data set
cms_patient_experience

#The core unit being measured is an organization, but each organization is 
#spread across six rows. 
#One row for each measurement taken in the survey organization 

#We first start by looking at the complete set of values for 
#measure_cd and measure_title 
#We can do this by using distinct() to remove any duplicates (thus showing us 
#the unique measurements)

cms_patient_experience |> 
  distinct(measure_cd, measure_title)

#Neither of these columns make particularly great variable names. 
#measure_cd doesn't hint at the meaning of the variable 
#measure_title is a long sentence containing spaces 

#We will use measure_cd here for our column names but in reality it would be best
#to make up new meaningful column names 


cms_patient_experience |> 
  pivot_wider(
    names_from = measure_cd,
    values_from = prf_rate
  )

#The outlook doesn't look quite right because we still have multiple rows
#for each organization. 
#This code shows that we have 95 distinct organizations. That is the row number
#we want to shoot for. 
cms_patient_experience |> distinct(org_nm)

#To fix that we also need to tell pivot_wider() which column or columns have 
#values that uniquely identify each row; in this case those are the variables 
#starting with "org" 

cms_patient_experience |> 
  pivot_wider(
    id_cols = starts_with("org"),
    names_from = measure_cd,
    values_from = prf_rate
  )


#By default, the rows in the output are determined by all the variables that 
#aren't going into the new names or values. 
#These are called the id_cols. 


#There are also problems with pivot_wider() when there are multiple rows in the 
#input that correspond to one cell in the output. 
#For example, we can have a 3xN data matrix with columns: id, measurement and value 
#If we have two rows with column id "A" and measurement "bp1" but each has a different
#value. Then we run into problems. 
##> Warning: Values from `value` are not uniquely identified; output will contain
#> list-cols.

#These are list-columns, which you'll learn more about in Chapter 24 







