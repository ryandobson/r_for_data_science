### R for Data Science 
#Second Edition: Chapter 10, Visualize - Layers 

#Restart the console to start fresh! 
#ctrl + shift + F10 

library(tidyverse)


#Looking at the first data set we will use 
mpg

#We have a few key components: 

#displ: A car's engine size, in liters. A numerical value 
#hwy: A car's fuel efficiency on the highway, in miles per gallon. Numerical value
#class: Type of car. A categorical variable. 


#starting with two scatter plots of the two numerical components listed above

ggplot(mpg, aes(x = displ, y = hwy, color = class)) +
  geom_point()

ggplot(mpg, aes(x = displ, y = hwy, shape = class)) +
  geom_point()

#> Warning: The shape palette can deal with a maximum of 6 discrete values
#> because more than 6 becomes difficult to discriminate; you have 7.
#> Consider specifying shapes manually if you must have them.

#> The above warning is telling us that because more than 6 shapes makes things
#> hard to interpret, R did not display the the 7th shape. 
#> The below warning is related, the 7th shape would be SUV's and they are not
#> plotted 

#> Warning: Removed 62 rows containing missing values (`geom_point()`).


#Another bad way to do things: 
# Left
ggplot(mpg, aes(x = displ, y = hwy, size = class)) +
  geom_point()
#> Warning: Using size for a discrete variable is not advised.

# Right
ggplot(mpg, aes(x = displ, y = hwy, alpha = class)) +
  geom_point()
#> Warning: Using alpha for a discrete variable is not advised.
#> These above warnings are telling us that we should not use size or alpha 
#> for discrete variables. This is because it is implying rank that does not exist


#Doing stuff outside of your aes() function will act differently than if you 
#use it within the function. 
ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_point(color = "blue")
#This simply makes all of the the points blue. 
#You can also specify: 
#> color as a character string "blue" or "red", and more 
#> size of a point in mm, size = 1 
#> shape of a point as a number shape = 1 
#> There are 5 different shapes you can use

#This below code does not result in blue points because its under the aes() function
#If we specify color here we want to specify color by a categorical variable. 
ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy, color = "blue"))


#> Geometric objects ------- 
#> You can represent the same data in slight different ways. 
#> For example, if you use geom_point or geom_smooth (or both) the data is the 
#> same but the graph is different 

ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_point()

ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_smooth()
#> `geom_smooth()` using method = 'loess' and formula = 'y ~ x'


#> Every geom function in ggplot2 takes a mapping argument, either defined
#> locally in the geom layer, or globally in the ggplot() layer 
#> NOT every aesthetic works works with every geom! 
#> You can set the shape of a point, but not the shape of a line. 
#> If you try to do so, ggplot2 silently ignores that aesthetic mapping. 
#> You can still set the linetype of a line with geom_smooth() 

ggplot(mpg, aes(x = displ, y = hwy, linetype = drv)) + 
  geom_smooth()

#Overalaying the points and specifing the linetype in smooth makes things more clear 
ggplot(mpg, aes(x = displ, y = hwy, color = drv)) + 
  geom_point() +
  geom_smooth(aes(linetype = drv))


#> some examples of how different graphs work with the aes mapping 

# Left
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_smooth()

# This one does not automatically create a legend 
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_smooth(aes(group = drv))

# This does automatically create a legend but we set it to false 
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_smooth(aes(color = drv), show.legend = FALSE)

#> If you place mappings in a geom function, ggplot2 will treat them as local
#> mappings for the layer. It will use these mappings to extend or overwrite
#> global mappings FOR THAT LAYER ONLY. This makes it possible to display 
#> different aesthetics in different layers. 

ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_point(aes(color = class)) + 
  geom_smooth()


#You can get much more advanced with graphs too! 
#> Below we are specifying different data for each laer. 
#> Here we used red points, as well as open circles to highlight two-set cars
ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_point() + 
  geom_point(
    data = mpg |> filter(class == "2seater"), 
    color = "red"
  ) +
  geom_point(
    data = mpg |> filter(class == "2seater"), 
    shape = "circle open", size = 3, color = "red"
  )

#> Geoms are the fundamental building blocks of ggplot2. 
#> You can completely transform the look of your plot by changing its geom, and 
#> different geoms can reveal different things about your data! 
#> The histogram and density plot (below) reveal that the distribution of 
#> highway mileage is bimodal and right skewed, while the boxplot reveals two
#> potential outliers 

# Histogram 
ggplot(mpg, aes(x = hwy)) +
  geom_histogram(binwidth = 2)

# Density plot 
ggplot(mpg, aes(x = hwy)) +
  geom_density()

# Boxplot 
ggplot(mpg, aes(x = hwy)) +
  geom_boxplot()


#> ggpplot2 provides more than 40 geoms. But, these still don't cover all of the
#> possible geoms you might need. 
#> If you need different ones, look for extension packages to see if someone 
#> else has already implemented it. 
#> For example, the ggridges package is useful for making ridgeline plots, 
#> which can be useful for visualizing the density of a numerical variable for 
#> different levels of a categorical variable. 

#install.packages("ggridges")
library(ggridges)

#Here the y variable is a categorical variable! Which is strange. 
#I'm not sure if I like these plots honestly.
ggplot(mpg, aes(x = hwy, y = drv, fill = drv, color = drv)) +
  geom_density_ridges(alpha = 0.5, show.legend = FALSE)


#> Facets -------- 
#> facet_wrap() and facet_grid() are the important functions here 
#> facet_wrap() splits up the data based upon one categorical variable 
#> facet_grid() allows you to split up data based upon two variables 

ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_point() + 
  facet_wrap(~cyl)

ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_point() + 
  facet_grid(drv ~ cyl)
#The formula in facet_grid(row ~ cols)


#When you split data up like this, the scales stay the same but sometimes that
#makes things look a bit awkward. Can fix this by setting scales = "free_"
ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_point() + 
  facet_grid(drv ~ cyl, scales = "free_y")
#In this one, we just set the y scale to be free 



#Consider the following plots putting a "." in place of a grid variable 
ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy)) +
  facet_grid(drv ~ .)
#Here we get the x-variable, displ, as a single x-axis 

ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy)) +
  facet_grid(. ~ cyl)
#Here we get the y-variable, hwy as a single y-axis 

#If you don't specify the number of rows it automatically splits it for you 
ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy)) + 
  facet_wrap(~ class, nrow = 2)

#This makes it much easier to compare different engine sizes with different 
#drive trains! We can clearly see that 4-wheel drives are split over the engine
#size, while front wheel drive is mostly smaller engines. 
#then rear while drive is less common and mostly larger engines. 
ggplot(mpg, aes(x = displ)) + 
  geom_histogram() + 
  facet_grid(drv ~ .)

#This plot makes it pretty difficult to make the above inferences 
ggplot(mpg, aes(x = displ)) + 
  geom_histogram() +
  facet_grid(. ~ drv)


#> Statistical Transformations -----------
#> 
#> Many graphs, like scatter plots, plot only the raw values present in your 
#> data set. 
#> But, other graphs, like bar charts, calculate new values to plot: 
#> Bar charts, histograms, and frequency polygons bin your data and then plot 
#> bin counts, the number of points that fall in each bin. 
#> Smoothers fit a model to your data and then plot predictions fromt he model 
#> Boxplots compute the five-number summary of the distribution and then displays 
#> that summary as a specifically formatted box 
#For instance, the y-variable is adding up the total number of each cut 
ggplot(diamonds, aes(x = cut)) + 
  geom_bar()

#> The algorithm that these graphs use to transform data is "stat" 
#> geom_bar() begins with the diamonds data set 
#> geom_bar() then transforms that data with the "count" stat, which returns 
#> a data set of cut values and counts 
#> geom_bar() uses the transformed data to build the plot. Cut is mapped to
#> the x-axis, count is mapped to the y-axis 

#> You can learn which stat a geom uses by inspecting the default value for the 
#> stat argument. 
#> For example, 
?geom_bar
#> stat = "count" here which means geom_bar uses stat_count() 
#> If you scroll down to the Computed Variables section, we can see how it 
#> computes two new variables, count and prop. 
#> Every geom has a default stat; and every stat has a default geom. 
#> This means you can typically use geoms without worrying about the underlying
#> statistical transformation. 
#> 
#> Three Reasons Why You Might Want To Specify The Stat Yourself: 
#> 1: You want to override the default stat. In the below code, the stat is 
#> changed to identity. This lets us map the height of the bars to the raw 
#> values of a y variable. This is useful if you already have a frequency table 
#> and don't have all of the data. You just use the exact value. 
diamonds |>
  count(cut) |>
  ggplot(aes(x = cut, y = n)) +
  geom_bar(stat = "identity")

#> 2: You might want to override the default mapping from transformed variables
#> to aesthetics. For example, you might want to display a bar chart of proportions
#> rather than counts. 
ggplot(diamonds, aes(x = cut, y = after_stat(prop), group = 1)) + 
  geom_bar()
#To find the possible variables that can be computed by the stat, look for the 
#> section title "computed variables" in the help for geom_bar() 
#> Here it says that we can use after_stat(prop)
#> 
#> 
#> 3: You might want to draw greater attention to the statistical transformation 
#> in your code. For example, stat_summary(), which summarizes the y values for
#> each unique x value, to draw attention to the summary that you're computing 

ggplot(diamonds) + 
  stat_summary(
    aes(x = cut, y = depth),
    fun.min = min,
    fun.max = max,
    fun = median
  )
#> ggplot2 provides more than 20 stats for you to use. Each stat is a function,
#> so you can get help in the usual way: e.g. ?stat_bin

#> If you don't set the group = 1 when using a proportion instead of count you 
#> get this. 
#> Its taking the proportion of each variable, which is 100%. If we only have
#>  group for the proportion though, we get the total proportion to be 100% 
#>  across groups 
ggplot(diamonds, aes(x = cut, y = after_stat(prop))) + 
  geom_bar()
ggplot(diamonds, aes(x = cut, fill = color, y = after_stat(prop))) + 
  geom_bar()

 
#> Post ion Adjustment ------- 
#> 
#> # color just does the border
ggplot(mpg, aes(x = drv, color = drv)) + 
  geom_bar()

# fill does the whole bar 
ggplot(mpg, aes(x = drv, fill = drv)) + 
  geom_bar()

#> If we map the fill aesthetic to another variable, we get a stacked bar graph 
ggplot(mpg, aes(x = drv, fill = class)) + 
  geom_bar()
#> A problem here is that the count on the y-axis no longer makes sense 
#> 
#> The stacking is performed automatically using the position adjustment argument 
#> If you don't want a stacked bar chart, you can use one of three options: 
#> identity 
#> dodge
#> fill 
#> Position Identity will place each object exactly where it falls in the context
#> of the graph. This is not very useful for bars, because it overlaps them. 
#> To see the overlapping we either need to make the bars slightly transparent
#> by setting alpha to a small value, or completely transparent by setting 
#> fill = NA 
#> This first one is pretty useless. The second one is slightly better but still 
#> rough 
ggplot(mpg, aes(x = drv, fill = class)) + 
  geom_bar(alpha = 1/5, position = "identity")

# Second 
ggplot(mpg, aes(x = drv, color = class)) + 
  geom_bar(fill = NA, position = "identity")
#The identity position is more useful for 2d geoms, like points, where it is the
#default 

#> Position fill works like stacking, but makes each set of stacked bars the 
#> same height. This makes it easier to compare proportions across groups 
ggplot(mpg, aes(x = drv, fill = class)) + 
  geom_bar(position = "fill")

#> Position dodge places overlapping objects directly besides one another. This 
#> makes it easier to compare individual values. 
ggplot(mpg, aes(x = drv, fill = class)) + 
  geom_bar(position = "dodge")


#> Another position that isn't useful for bar charts is jitter. 
#> But this position is very useful for scatter plots. 
#> When you have a scatter plot you sometimes have a ton of points and this 
#> results in overplotting, making the spread hard to make sense of. 
#> Position jitter actually adds a small amount of random noise to each point. 
#> This spreads the points out because no two points are likely to receive the 
#> same amount of random noise 
ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_point(position = "jitter")
#> Addoing noise to your graph seems like a weird way to improve it. It does 
#> make your graph less accurate at small scales. But it makes your graph more
#> revealing at large scales. 
#> It is so useful, ggplot2 comes with a shorthand for geom_point(position = "jitter) 
#> Just use geom_jitter() for shorthand. 
#> 
#> 
#> Coordinate Systems ------- 
#> 
#> These are probably the most complicated part of ggplot2 
#> 
#> There are two coordinate systems that are occasionally helpful 
#> coord_quickmap() sets the aspect ratio for geographic maps. 
nz <- map_data("nz")

ggplot(nz, aes(x = long, y = lat, group = group)) +
  geom_polygon(fill = "white", color = "black")

ggplot(nz, aes(x = long, y = lat, group = group)) +
  geom_polygon(fill = "white", color = "black") +
  coord_quickmap()
#> coord_polar() uses polar coordinates. 
bar <- ggplot(data = diamonds) + 
  geom_bar(
    mapping = aes(x = clarity, fill = clarity), 
    show.legend = FALSE,
    width = 1
  ) + 
  theme(aspect.ratio = 1)

bar + coord_flip()
bar + coord_polar()
#> polar coordinates reveal an interesting connection between a bar chart and
#> a Coxcomb chart. 
#> You can use this to create pie charts. 
#> 
#> The Layered Grammer of Graphics ----- 
#> 
#> ggplot(data = <DATA>) + 
#> <GEOM_FUNCTION>(
#> mapping = aes(<MAPPINGS>),
#> tat = <STAT>, 
#> position = <POSITION>
#> ) +
#> <COORDINATE_FUNCTION> +
#> <FACET_FUNCTION>

#> You rarely need to use all seven parameters when you are graphing because 
#> many of them are implied. 
#> But, it is useful to realize that the grammar of graphics are these 7 things: 
#> YOu can describe any plot as a combination of: 
#> data set 
#> geom 
#> a set of mappings
#> a stat
#> a position adjustment 
#> a coordinate system 
#> a faceting scheme 
#> and a theme 
#> 
#> Using all of these things you could build anything you want from scratch! 
#> 
#> For instance, you could start with a data set and then transform the data 
#> into the form you want using a stat. Then you can choose a geometric object
#> to represent each observation in the transformed data. Then you could use aes
#> properties of the geoms to represent variables in the data. And so on. 
#> 
#> 
