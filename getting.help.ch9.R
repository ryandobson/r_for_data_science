### R for Data Science 
#Second Edition: Chapter 9, Getting Help 
library(reprex)
reprex()
library(tidyverse)

#Google is your friend. 


#Making a reprex 
#reprex = minimal reproducible example. 

#First you need to make your code reproducible.
#which means you have to capture everything, including any library() calls and
#create all necessary objects. 
#Easiest way to do this is to use the reprex package!(part of tidyverse) 

#Second, you need to make it minimal. Strip away everything that is not related
#to your problem. Usually means creating a much smaller and simpler R object 
#than the one you are actually facing. Or even using built-in data. 

#It sounds like a lot of work but a lot of the time, just creating the reprex
#will help you solve your own problem! 
#Other times, you will make it a lot easier for others to help which is great. 

#An example of using the reprex package with this code: 
y <- 1:4
mean(y)


#install.packages("reprex")


#Three things you need to include to make your example reproducible: 
#required packages, data, and code 

#Packages should be loaded at the top of the script so it's easy to see 
#which ones the example needs. 
#This is a good time to see if you are using the latest version of each package 

#For packages in the tidyverse, you can easily check with tidyverse_update() 
tidyverse_update()


#The easiest way to include data is to use dput() to generate R code needed to 
#recreate it. 
#For example: 
#run dput(mtcars) in R 
#copy the output 
#In reprex, type mtcars <-, then paste. 
#Try to use the smallest subset of your data that still reveals the problem 

#Spend a little time ensuring that your code is easy for others to read: 
#Make sure you've used spaces and your variable names are concise yet informative
#Use comments to indicate where your problem lies 
#Do your best to remove everything that is not related to the problem 

#Finish b checking that you have actually made a reproducible example by starting
#a fresh R session and copying and pasting your script 



