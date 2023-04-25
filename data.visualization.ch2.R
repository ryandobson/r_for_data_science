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

#Starting by creating a scatter plot 

penguins %>% ggplot(
  mapping = aes(x = flipper_length_mm, 
                y = body_mass_g,
                color = species)
) +
  geom_point() +
  geom_smooth(method = "lm")
### Note, when I have the color specified in the original plot it splits up the 
#line of best fit into each species. 
#I want a single line so I need to change the color into the geom_point: 

penguins %>% ggplot(
  mapping = aes(x = flipper_length_mm, 
                y = body_mass_g)
) +
  geom_point(mapping = aes(color = species,
                           shape = species)) +
  geom_smooth(method = "lm")
##also added shape = species so data points are recognizable by color blind people 


##Adding some label edits! 

penguins %>% ggplot(
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(aes(color = species, shape = species)) +
  geom_smooth(method = "lm") +
  labs(
    title = "Body mass and flipper length",
    subtitle = "Dimensions for Adelie, Chinstrap, and Gentoo Penguins",
    x = "Flipper length (mm)", y = "Body mass (g)",
    color = "Species", shape = "Species"
  ) +
  scale_color_colorblind()


##You should try to memorize the first one or two arguments of important functions 
#ggplot has data and mapping as the first two (and I specify data before with %>% ) 


#How you visualize a distribution depends on the type of variable. 
#Categorical or numerical? 

#For categorical variables you can use a bar chart to depecit the levels of the 
#variable on the x and the count (n) on the y-axis. 
#Not super helpful for male and female because the raw n's do just fine. 
#Good for other types of variables when you do really want to see response 
#frequencies. 

#With bar charts its usually preferable to order the variables based upon
#frequencies. 
#For instance, this bar chart: 
ggplot(penguins, aes(x = species)) +
  geom_bar()
#displays the species by alphabetical order. 

#But, if we transform the variable to a factor we can display them in order of 
#most frequent to least frequent. 

ggplot(penguins, aes(x = fct_infreq(species))) +
  geom_bar()


### Visualizing A numerical variable: 

#When we are considering numerical variables, a histogram is one option that can
#be useful. 

penguins %>% ggplot(aes(x = body_mass_g)) +
  geom_histogram(binwidth = 200)
#The histogram divides the x-axis into equally spaced bins and then uses the 
#height of a bar to display the number of observations that fall in each bin. 

#using the "bindwidth = " argument you can specify the width of intervals. 
#The width of intervals is measured in the units of the x variable. 

#You should play around with different binwidths because different binwidths 
#can display different patterns. 

#For example, with this histogram, 2000 is too high, resulting in all of the data
#being shown in 3 bars. Meanwhile, 20 is too low creating too many bars. 

ggplot(penguins, aes(x = body_mass_g)) +
  geom_histogram(binwidth = 20)

ggplot(penguins, aes(x = body_mass_g)) +
  geom_histogram(binwidth = 2000)



#An alternative visualization for distributions that are numerical is a density 
#plot. 
#A density plot is a smoothed out version of a histogram 
#It is a good alternative for continuous data that comes from an underlying 
#smooth distribution. 

ggplot(penguins, aes(x = body_mass_g)) +
  geom_density()


#How are these two different? 
ggplot(penguins, aes(x = species)) +
  geom_bar(color = "red") #color = specifies the border of the bars 

ggplot(penguins, aes(x = species)) +
  geom_bar(fill = "red") #fill = specifies the color of the whole bar 



### VISUALIZING RELATIONSHIPS 


# A box plot is a good way to visualize the relationship between two variables 

ggplot(penguins, aes(x = species, y = body_mass_g)) +
  geom_boxplot()

#But, you can alternatively make density plots to display something similar 
ggplot(penguins, aes(x = body_mass_g, color = species)) +
  geom_density(linewidth = 0.75)
#Using color here just makes it so you can compare the different levels of species 


#Here we add the fill element and then set the opaqueness to alpha .5 
ggplot(penguins, aes(x = body_mass_g, color = species, fill = species)) +
  geom_density(alpha = 0.5)

#Notice terminology here: 
#We map variables to aesthetics if we want the visual attribute represented by 
#that aesthetic to vary based on the values of that variable. 
#Otherwise, we set the value of an aesthetic. 


#Two Categorical Variables: 

#This is how you create a stacked bar chart! 
#This displays the relationship between island and species 

ggplot(penguins, aes(x = island, fill = species)) +
  geom_bar()
#NOTE: the y-axis is now not "count" and is incorrectly labeled. 


#This here is a relative frequency plot created by adding "position = "fill"" 
ggplot(penguins, aes(x = island, fill = species)) +
  geom_bar(position = "fill")
#In creating these bar charts, we map the variable that will be separated into
#the bars to the x aesthetic, and the variable that will change the colors 
#inside the bars to the fill aesthetic. 


# VISUALIZING TWO NUMERICAL VARIABLES 


#A scatter plot is the most common graph to visualize this relationship 

ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point()



#Three or more variables 

#If they are all numerical a scatter plot can handle three variables by specifying
#color of the third variable. #And then the shape of the object can specify the 
#fourth variable.

ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(color = species, shape = island))
#Although, adding the fourth variable makes the plot a bit cluttered and hard to 
#interpret. 

#Instead of specifying the fourth variable (island in this case) by shape, you 
#can use facet_wrap to split things up. 

ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(color = species, shape = species)) +
  facet_wrap(~island)
#The variable you pass to facet_wrap should be categorical 



#Saving Your Plots 

#Can use ggsave(filename = "penguin-plot.png") 
#If you don't save the plot as an element and specify you want to save that one
#it automatically saves your most recently created plot. 

ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point()
ggsave(filename = "penguin-plot.png")
#Also, if you don't specify the width and height, they will be taken from your
#current dimensions. For reproducible code, you will want to specify them. 



