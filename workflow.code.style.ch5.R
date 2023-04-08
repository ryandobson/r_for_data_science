### R for Data Science 
#Second Edition: Chapter 5, Workflow: code style 


#Having a consistent coding style will help you code better and be able to 
#read your code easier in the future. 

#You can also restyle existing code quckly using a styler package 
#installed.packages("styler")

#To use it via Rstduio's command palette 
#Open the palette by pressing ctrl + shift + p 


#Naming 

#Use lowercase letters and numbers and _ to separate words within a name 
#short_flights <- ...

#Prefer to use long and specific names that are helpful rather than short abreviations
#short abreviations can be a pain to understand when coming back to things
#Plus R will autocomplete variable names so you don't waste much time typing! 

#If you have a set of variables that are in a theme, its better to give them a 
#common prefix instead of a common suffix. This is because R autocompletes easier
#if you do it this way. 


#Spaces 
#Put spaces on either side of mathematical operators and around the assignment operator 

#Don't put spaces inside or outside parentheses for regular funtion calls 
#always put a space after a comma 

#Its ok to add spaces in some areas if it makes it easier to read: 
flights |> 
  mutate(
    speed      = air_time / distance,
    dep_hour   = dep_time %/% 100,
    dep_minute = dep_time %%  100
  )
#notice how extra space is added after the variable names so the "=" sign lines up 

#Pipes 

#Should always have a space before and after the pipe. 
#It should typically be the last thing on the line 

#Always put new functions on a new line 
#If the code for a function fits on the line, leave it. 

# Strive for
flights |>  
  group_by(tailnum) |> 
  summarize(
    delay = mean(arr_delay, na.rm = TRUE),
    n = n()
  )

# Avoid
flights |>
  group_by(
    tailnum
  ) |> 
  summarize(delay = mean(arr_delay, na.rm = TRUE), n = n())


#Put new functions from a new pipe two spaces in. 
# Strive for 
flights |>  
  group_by(tailnum) |> 
  summarize(
    delay = mean(arr_delay, na.rm = TRUE),
    n = n()
  )

# Avoid
flights|>
  group_by(tailnum) |> 
  summarize(
            delay = mean(arr_delay, na.rm = TRUE), 
            n = n()
  )
# Avoid
flights|>
  group_by(tailnum) |> 
  summarize(
  delay = mean(arr_delay, na.rm = TRUE), 
  n = n()
  )


#The same basic rules that apply to the pipe operator apply to + in ggplot 



#As your scripts get longer, you can use sectioning comments to break up your
#file into manageable pieces: 

# Load data --------------------------------- 

# Plot data ----------------------------------

#All you have to do to add the section is spam type the dashes out until it sections














