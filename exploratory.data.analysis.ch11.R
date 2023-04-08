### R for Data Science 
#Second Edition: Chapter 11, Exploratory Data Analysis 

library(tidyverse)

#> Exploratory Data Analysis cycle 
#> Generate questions about your data
#> Search for answers by visualizing, transforming, and modelling your data 
#> Use what you learn to refine  your questions and/or generate new questions 
#> 
#> Not a formal process. Just investigating whatever you see necessary. 
#> It is fundamentally a creative process. 
#> 
#> Two types of questions will always be useful: 
#> 
#> 1. What type of variation occurs within my variables? 
#> 
#> 2. What type of covariation occurs between my variables? 
#> 
#> 
#> Variation ------
#>The tendency of the values of a variable to change from measurement to 
#>measurement 
#> Or variables can vary across different subjects. 
#> 
#> Best way to see variation is to visualize it in a graph. 
#> 
#> Here we stat by visualizing the weight of diamonds - using a histogram 
#> because it is a numerical variable. 
#> 

ggplot(diamonds, aes(x = carat)) +
  geom_histogram(binwidth = 0.5)

#> Asking good follow-up questions about your data: 
#> What do you want to learn more about? 
#> How could this be misleading? 
#> 
#> Typical Values: 
#> Which values are the most common? Why?
#> Which values are rare? Why? Does this match expectations? 
#> Can you see any unusual patterns What might explain them? 
#> 
#> 

smaller <- diamonds |> 
  filter(carat < 3)

ggplot(smaller, aes(x = carat)) +
  geom_histogram(binwidth = 0.01)
#> Zooming in on this histogram raises a few questions: 
#> Why are three more diamonds at whole carats and common fractions of carats? 
#> Why are there more diamonds slighty to the right of each peak thant here are 
#> slightly to the left of each peak? 
#> 
#> Considering Clutsters: 
#> How are the observations within each subgroup similar to each other? 
#> How are the observations in separate clusters different from each other? 
#> How can you explain or describe the clusters? 
#> Why might the appearance of clusters be misleading? 
#> 
#> 
#> Unusual Values -------
#> 
#> When you have a lot of data, outliers can be hard to notice on the histogram
#> 
ggplot(diamonds, aes(x = y)) + 
  geom_histogram(binwidth = 0.5)
#> The only evidence of outliers from this is the unusually wide limit on the
#> x-axis 
#> We can zoom into the x-axis to see these unusual values 
ggplot(diamonds, aes(x = y)) + 
  geom_histogram(binwidth = 0.5) +
  coord_cartesian(ylim = c(0, 50))

#> If you specify xlim() and ylim() inside of the global ggplot2, it throws away
#> the values outside of the limits. 
#> On the other hand, when you use coord_cartesian to specify them, it just zooms
#> in on the axis's 
#> 
#> Now that we know where these values are, we can pluck them out with dplyr 

unusual <- diamonds |> 
  filter(y < 3 | y > 20) |> 
  select(price, x, y, z) |>
  arrange(y)
unusual

#> Now that we have found these outliers, we can remove the ones that are clearly 
#> not meant to be there. 
#> If a diamond is at 0 for size, we know its not actually a diamond and was a 
#> data entry mistake. We can remove those entries. 
#> 
#> You shouldn't just remove outliers without justification though! Sometimes 
#> outliers are valid data points and if they influence the results in ways you 
#> don't want, thats too bad. 
#> 
#> 
#> Two options for when you encounter unusual values: 
#> 
#> 1. Drop the entire row with strange values 

diamonds2 <- diamonds |> 
  filter(between(y, 3, 20))
#> This isn't recommended because someone might just be missing one variable and
#> can still be included in the overall analysis. This is especially relevant if 
#> you have pretty spotty data. 
#> 
#> 2. Replace the unusual values with missing values. 
#> Using mutate() and if_else() function this is pretty easy. 

diamonds2 <- diamonds |> 
  mutate(y = if_else(y < 3 | y > 20, NA, y))

#> ggplot2 also does not plot missing values and tells you that rows were 
#> removed 

ggplot(diamonds2, aes(x = x, y = y)) + 
  geom_point()


#> Other times you might want to understand what makes observations with missing
#> observations different than observations with recorded values. 
#> 
#> With this flight data, a missing data point means that the flight was 
#> cancelled. 
#> We can then compare departure time for cancelled flights versus flights. 

nycflights13::flights |> 
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + (sched_min / 60)
  ) |> 
  ggplot(aes(x = sched_dep_time)) + 
  geom_freqpoly(aes(color = cancelled), binwidth = 1/4)

#> However, this plot isn't great because there are many more non-cancelled 
#> flights than cancelled flights. 
#> 
#> 

#> Covariation ------ 
#> 

#> A categorical and numerical variable -----
#> Explore how the price of diamond varies with its quality (measured by cut) 
ggplot(diamonds, aes(x = price)) + 
  geom_freqpoly(aes(color = cut), binwidth = 500, linewidth = 0.75)
#> Here the graph isn't that great because the count differs so much across 
#> different cuts that its hard to tell what is happening. 
#> To make this comparison easier we can change the y-axis to the density which
#> is the count standardized. 

ggplot(diamonds, aes(x = price, y = after_stat(density))) + 
  geom_freqpoly(aes(color = cut), binwidth = 500, linewidth = 0.75)
#> Because density was not a variable in the diamonds dataset, we need to first
#> calculate it. We use the after_stat() function to do so. 
#> With this graph it appears that fair diamonds -the lowest cut- have the highest
#> average height. 
#> 
#> You can also visualize this using side-by-side boxplots: 

ggplot(diamonds, aes(x = cut, y = price)) +
  geom_boxplot()

#> Here cut is an ordered factor so it makes sense to display it as it. 
#> In some cases though you want to display the boxplots in a more succinct way 
#> to better visualize what is happening. 
#> You can use fct_reorder() to do this. 
#> 
#> Look at this boxplot unorderd 

ggplot(mpg, aes(x = class, y = hwy)) +
  geom_boxplot()

#compared to reordering it: 

ggplot(mpg, aes(x = fct_reorder(class, hwy, median), y = hwy)) +
  geom_boxplot()
#> We reordered class based on the median value of hwy! 
#> 
#> With long variable names the boxplots tend to look better flipped on their 
#> side. 
#> You can do this by exchanging the x and y aesthetic mappings: 

ggplot(mpg, aes(x = hwy, y = fct_reorder(class, hwy, median))) +
  geom_boxplot()


#> Two Categorical Variables ----- 
#> 
#> To explore the covariation between two categorical variables you will need 
#> to count the number of observations for each combination of levels of these
#> categorical variables. 
#> One way to manage this is to use geom_count() 
#> 
ggplot(diamonds, aes(x = cut, y = color)) +
  geom_count()
#> It might be easier to just look at the count for each variable though 
diamonds |> 
  count(color, cut)
#Then you can visualize this when geom_tile() 
diamonds |> 
  count(color, cut) |>  
  ggplot(aes(x = color, y = cut)) +
  geom_tile(aes(fill = n))

#> If the categorical variables are unordered, you might want to try the 
#> seriation package 
#> For larger plots you might want to try the 
#> heatmaply package 

#> Two Numerical Variables ------ 
#> 
#> The scatter plot is classic for this

ggplot(smaller, aes(x = carat, y = price)) +
  geom_point()

#> Overplotting can occur pretty fast though. Lowering the transparency can help 
#> 
ggplot(smaller, aes(x = carat, y = price)) + 
  geom_point(alpha = 1 / 100)

#> But even that method can be not that great. 
#> Another solution is to use bin. 
#> Previously we used geom_histogram() and geomfreqpoly() to bin in one dimension 
#> We can also use geom_bin2d() and geom_hex() to bin in two dimensions! 
#> These can both divide the coordinate plane into 2bins and then use a fill 
#> color to display how many points fall into each bin. 
#> geom_bin2d() creates rectangualer bins 
#> geom_hex() creates hexagonal bins (You need the hexbin package to use this)

#install.packages("hexbin")
library(hexbin)

ggplot(smaller, aes(x = carat, y = price)) +
  geom_bin2d()

ggplot(smaller, aes(x = carat, y = price)) +
  geom_hex()

#Another option is to bin one continuous variable so it acts like a categorical 
#>variable. 
#>Then you can use one of the techniques for visualizing the combination of a 
#>categorical and continuous variable that you learned about. 

ggplot(smaller, aes(x = carat, y = price)) + 
  geom_boxplot(aes(group = cut_width(carat, 0.1)))
#cut_width(x, width) divides x into binds of width. 
#> One thing that is hard to see here is that boxplots look roughly the same 
#> no matter how many observations make up the boxplot. 
#> You can use varwidth = TRUE to make boxplots have some way of representing
#> the total number of observations. 
#> 

ggplot(smaller, aes(x = carat, y = price)) + 
  geom_boxplot(aes(group = cut_width(carat, 0.1)),
               varwidth = TRUE)


#> Patterns and Models ---- 
#> 
#> 
#> If you spot a pattern, ask yourself: 
#> Could this pattern be due to coincidence (random chance)? 
#> How can you describe the relationship implied by the pattern? 
#> How strong is the relationship implied by the pattern? 
#> What other variables might affect the relationship? 
#> Does the relationship change if you look at individual subgroups of the data? 
#> 
#> An example with diamonds data 
#install.packages("tidymodels")
library(tidymodels)

diamonds <- diamonds |>
  mutate(
    log_price = log(price),
    log_carat = log(carat)
  )

diamonds_fit <- linear_reg() |>
  fit(log_price ~ log_carat, data = diamonds)

diamonds_aug <- augment(diamonds_fit, new_data = diamonds) |>
  mutate(.resid = exp(.resid))

ggplot(diamonds_aug, aes(x = carat, y = .resid)) + 
  geom_point()

ggplot(diamonds_aug, aes(x = cut, y = .resid)) + 
  geom_boxplot()
#> Some interesting plots of this regression! 
#> 
#> This book does not cover data modelling because we need to have an
#> understanding of data wrangling and programming before we can really get
#> into modelling 
#> 
#> 



