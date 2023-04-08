### R for Data Science 
#Second Edition: Chapter 2, Data Visualization 

library(tidyverse)

##install.packages("palmerpenguins") just includes sample data used here
##install.packages("ggthemes") includes a colorblind safe color palette 

library(palmerpenguins)
library(ggthemes)

#In this context, a variable refers to an attribute of all the penguins, 
#and an observation refers to all the attributes of a single penguin.

penguins 
glimpse(penguins)


