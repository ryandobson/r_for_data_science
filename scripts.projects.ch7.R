### R for Data Science 
#Second Edition: Chapter 7, Scripts and Projects


### Running code efficiently: 

library(tidyverse)
library(nycflights13)

not_cancelled <- flights |> 
  filter(!is.na(dep_delay)█, !is.na(arr_delay))

not_cancelled |> 
  group_by(year, month, day) |> 
  summarize(mean = mean(dep_delay))
#If your cursor is where the black box is, and you hit ctrl + enter, R will 
#run the code: 
not_cancelled <- flights |> 
  filter(!is.na(dep_delay), !is.na(arr_delay))
#Then it will put you at the beginning of the next line of code so you can continue
#through if you want 


#Executing the complete script: 
# ctrl + shift + s 

#Running the entire script regularly is a good way to ensure things are going well! 


#Recommended to always start your script with loading in the packages needed 
#But, don't include install.packages() - or at least comment it out 
#If someone else runs the entire code you can then install a package on their 
#computer that they didn't care to have. Its just best to not do that to others 


#Saving and naming 

#File names should be machine readable: avoid spaces, symbols, and special characters
##Don't rely on case sensitivity to distinguish files 
#File names should be human readable: use file names to describe whats in the file 
#File names should play well with default ordering: start file names with numbers 
#so that alphabetical sorting puts them in the order they get used.  


#An example of file naming: 
#01-load-data.R
#02-exploratory-analysis.R
#03-model-approach-1.R
#04-model-approach-2.R
#fig-01.png
#fig-02.png
#report-2022-03-20.qmd
#report-2022-04-02.qmd
#report-draft-notes.txt

#Starting the file script names with "01" and so on lets you know the order in 
#which to run the scripts! 
#Figures are named similarly to scripts 
#The reports include the date 


#If you have lots of files in a directory, taking organization one step further
#and including different folders in that directory is recommended. 


#Two important decisions: 

#Question 1: #What is the source of truth? 
#What will you save as your lasting record of what happened? 

#Your source of truth should be the R script. You don't want to save your 
#environment. 
#You should tell R to not preserve your work space between sessions. 
#(I have already done this)

#To ensure you have captured the important parts of your code in the editor:
#Press ctrl + shift + F10  to restart R 
#Press ctrl + shift + s to rerun the current script 



#Question 2: Where does our analysis live? 


#It is best to keep all the files associated with a given project together
#in one directory. 
#R has a built in way to make this easy, create a project! 


#Once you're inside a project, you should only ever use relative paths, not 
#absolute paths. 

#Relative paths are relative to the working directory (the projects home) 
#Relative paths are important because they work wherever your R project ends up. 

#Absolute paths point the same place regardless of your working directory. 
#You should never use absolute paths in your scripts because they hinder sharing 













