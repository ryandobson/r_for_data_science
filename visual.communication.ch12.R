### R for Data Science 
#Second Edition: Chapter 12, Visualize - Communication 

#Restart the console to start fresh! 
#ctrl + shift + F10 

library(tidyverse)


#> In the previous chapter we just created exploratory plots. 
#> In the course of a project you will create a ton of those exploratory plots
#> and most of them will just be thrown out after you get an idea of what is
#> happening with your data. 
#> 
#> Now we will be creating plots to actually communicate what is happening with 
#> our data to other people. 
#> 

#install.packages("scales")
#install.packages("ggrepel")
#install.packages("patchwork")

library(scales)
library(ggrepel)
library(patchwork)


#> Labels ---- 
#> 
#> Easiest place to start by improving your graph is the labels. 
#> 
#> To add labels you can use the lab() function 


ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  labs(
    x = "Engine displacement (L)",
    y = "Highway fuel economy (mpg)",
    color = "Car type",
    title = "Fuel efficiency generally decreases with engine size",
    subtitle = "Two seaters (sports cars) are an exception because of their light weight",
    caption = "Data from fueleconomy.gov"
  )

#> Use the plot title to summarize the main finding! 
#> Use the subtitle if you need to add additional detail or contextualize it 
#> 
#> Caption is often used to describe the source of the data 
#> 
#> If you need a mathematical equation on the axis you can do this: 
#> 
df <- tibble(
  x = 1:10,
  y = cumsum(x^2)
)

ggplot(df, aes(x, y)) +
  geom_point() +
  labs(
    x = quote(x[i]),
    y = quote(sum(x[i] ^ 2, i == 1, n))
  )
#> Read more about the options with this using: 
#> ?plotmath 
#> 

#> Annotations -------
#> 
#> Its often useful to label individual observations or groups of observations 
#> 
#> geom_text is useful for labeling graphs 
#> 
#> First, we create a smaller data frame with the information we need for our
#> annotations 
#> 
label_info <- mpg |>
  group_by(drv) |>
  arrange(desc(displ)) |>
  slice_head(n = 1) |>
  mutate(
    drive_type = case_when(
      drv == "f" ~ "front-wheel drive",
      drv == "r" ~ "rear-wheel drive",
      drv == "4" ~ "4-wheel drive"
    )
  ) |>
  select(displ, hwy, drv, drive_type)

#> Now we use this new data frame to directly label the three groups

ggplot(mpg, aes(x = displ, y = hwy, color = drv)) +
  geom_point(alpha = 0.3) +
  geom_smooth(se = FALSE) +
  geom_text(
    data = label_info, 
    aes(x = displ, y = hwy, label = drive_type),
    fontface = "bold", size = 5, hjust = "right", vjust = "bottom"
  ) +
  theme(legend.position = "none")
#> Notice how we use the whole mpg data frame to create the graph 
#> But, in our annotation labels, we just took one data point to attach the 
#> annotation to. 
#> The only problem is the annotations are not in very great positions so we 
#> can adjust them. 
#> 
ggplot(mpg, aes(x = displ, y = hwy, color = drv)) +
  geom_point(alpha = 0.3) +
  geom_smooth(se = FALSE) +
  geom_label_repel(
    data = label_info, 
    aes(x = displ, y = hwy, label = drive_type),
    fontface = "bold", size = 5, nudge_y = 2,
  ) +
  theme(legend.position = "none")
#> To easily make sure the annotations don't overlap we just use the package
#> ggrepel and the function geom_label_repel() - instead of geom_text() 
#> 
#> You can also use the same idea to highlight certain points on a plot with
#> geom_text_repel() 
#> For example, here we select all the points that are potential outliers. Then we 
#> can change how these points look and label what type of ar they are. 

potential_outliers <- mpg |>
  filter(hwy > 40 | (hwy > 20 & displ > 5))

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point() +
  geom_text_repel(data = potential_outliers, aes(label = model)) +
  geom_point(data = potential_outliers, color = "red") +
  geom_point(data = potential_outliers, color = "red", size = 3, shape = "circle open")



#install.packages("ggforce")
library(ggforce)

#> You also have plenty of other options to annotate things in ggplot2 
#> 
#> geom_hline() and geom_vline() add reference lines. 
#>  They often make them thick (linewidth = 2) and white (color = white) and 
#>  draw them underneath the primary data layers. 
#>  
#> geom_rect() to draw a rectangle around points of interest. Boundaries are 
#> defined by aesthetics xmin, xmax, ymin, ymax. 
#> Alternatively, the ggforce package and geom_mark_hull() allows you to annotate
#> subsets of points with hulls 
#> 
#> geom_segment() with the arrow argument to draw attention to a point with an 
#> arrow. Use aesthetics x and y to define the starting location, and xend and
#> yend to define the end location. 
#> 
#> You can also use annotate(). 
#> geoms are generally useful for highlighting a subset of data, while annotate() 
#> is useful for adding one or a few annotation elements to a plot. 
#> 
#> Example of annotate and str_wrap() to automatically add line breaks. 
#> Creating the character string of the annotation we want to add. 
trend_text <- "Larger engine sizes tend to\nhave lower fuel economy." |>
  str_wrap(width = 30) #specifies the number of characters to have on a line 
trend_text

#> Adding two annotations, the trend text and an arrow

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point() +
  annotate(
    geom = "label", x = 3.5, y = 38,
    label = trend_text,
    hjust = "left", color = "red"
  ) +
  annotate(
    geom = "segment",
    x = 3, y = 35, xend = 5, yend = 25, color = "red",
    arrow = arrow(type = "closed")
  )


#> Annotations are very powerful for communicating main takeaways of your data! 
#> Use them, you just have to be patient with adjusting their position 
#> 
#> 
#> Scales ----- 
#> 
#> Normally, ggplot2 automatically adds scales for you: 
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = class))

#> ggplot automatically adds these things in behind the scenes here: 
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = class)) +
  scale_x_continuous() +
  scale_y_continuous() +
  scale_color_discrete()

#> Look at the name of the scales_ 
#> 
#> The default scales are named according to the type of variable they align with:
#> continuous, discrete, datetime, or date. 
#> scale_x_continuous() puts the numeric values from displ on a continuous 
#> number line on the x-axis. 
#> scale_color_discrete() chooses colors for each of the class of car, etc. 
#> 
#> There are a lot of non-default scales to consider! 
#> Although, the default scales do a good job the majority of the time.  
#> 
#> Sometimes though, you will want to change the parameters of the scale, 
#> changing the default breaks on the axes or the key labels on the legend 
#> Or you might want to replace the scale altogether, and use a different 
#> algorithm. 
#> 
#> Axis ticks and legend keys 
#> Collectively, these are called guides 
#> Axes are used for x and y aesthetics 
#> legends are used for everything else 
#> 
#> Two primary arguments that affect the appearance of the ticks on the axes and
#> the keys on the legend: breaks and labels 
#> breaks controls the position of the ticks, or the values associated with the keys 
#> labels controls the text label associated with each key/tick. 

ggplot(mpg, aes(x = displ, y = hwy, color = drv)) +
  geom_point() +
  scale_y_continuous(breaks = seq(15, 40, by = 5)) 
#Here we changed the y-axis to have breaks of 5, starting at 15 and going to 40 

#> You can use labels in the same way (a character vector of the same length as
#> breaks), but you can also set it to null to supress the labels altogehter. 
#> 
ggplot(mpg, aes(x = displ, y = hwy, color = drv)) +
  geom_point() +
  scale_x_continuous(labels = NULL) +
  scale_y_continuous(labels = NULL) +
  scale_color_discrete(labels = c("4" = "4-wheel", "f" = "front", "r" = "rear"))
#> You can also use breaks and labels to control the appearance of legends for
#> discrete scales for categorical variables. 
#> labels can be a named list (shown above) of the existing levels names and 
#> desired labels for them. 
#> 
#> labels is also useful for changing the axis to a currency or percent format 

#> Two different dollar examples 
ggplot(diamonds, aes(x = price, y = cut)) +
  geom_boxplot(alpha = 0.05) +
  scale_x_continuous(labels = label_dollar())

ggplot(diamonds, aes(x = price, y = cut)) +
  geom_boxplot(alpha = 0.05) +
  scale_x_continuous(
    labels = label_dollar(scale = 1/1000, suffix = "K"), 
    breaks = seq(1000, 19000, by = 6000)
  )

#> percent example s
#> 
ggplot(diamonds, aes(x = cut, fill = clarity)) +
  geom_bar(position = "fill") +
  scale_y_continuous(name = "Percentage", labels = label_percent())

#Another use for breaks is when you have relatively few data points and you 
#> want to highlight exactly where the observations occur. 
#> The below graph shows the year that presidents started and ended their terms

presidential |>
  mutate(id = 33 + row_number()) |>
  ggplot(aes(x = start, y = id)) +
  geom_point() +
  geom_segment(aes(xend = end, yend = id)) +
  scale_x_date(name = NULL, breaks = presidential$start, date_labels = "'%y")
#> Note that for the breaks argument we pulled out the start variable as a 
#> vector with presidential$start because we can't do an aesthetic mapping for 
#> this argument. 
#> Also note that the specification of breaks and labels for data and datetime 
#> scales is a little different:
#> date_labels takes a format specification, the same form as parse_datetime() 
#> date_breaks (not shown here), takes a string like "2 days" or "1 month" 
#> 
#> Legend layout 
#> 
#> To control the overall position of the legend, you need to use a theme() 
#> setting. The theme() elements control the non-data parts of the plot. 
#> The theme setting legend.position controls where the legend is drawn: 
base <- ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = class))

#>different variations of the legend position for the base graph
base + theme(legend.position = "right") # the default
base + theme(legend.position = "left")
base + 
  theme(legend.position = "top") +
  guides(col = guide_legend(nrow = 3))
base + 
  theme(legend.position = "bottom") +
  guides(col = guide_legend(nrow = 3))

#> If your graph is short and wide, place the legend at the top or bottom. 
#> Vice versa for tall and narrow graphs. 
#> 
#> To control the display of individual legends, use guides() along with 
#> guide_legend() or guide_colorbar() 
#> 
#> Below shows how to control the number of rows the legend uses with nrow 
#> and overriding one of the aesthetics to make the points bigger. 

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  theme(legend.position = "bottom") +
  guides(color = guide_legend(nrow = 2, override.aes = list(size = 4)))
#> Note that the name of the argument in guides() matches the name of the 
#> aesthetic, just like in labs() 
#> 
#> Replacing a scale 
#> 
#> Two types of scales you're most likely to want to switch out: continuous 
#> position scales and color scales. 
#> 
#> Its very useful to plot transformations of your variable. It's easier to see
#> the precise relationship between carat and price if we log transform them 
#> 
#> Regular graph and then the log transformed graph. 
ggplot(diamonds, aes(x = carat, y = price)) +
  geom_bin2d()

ggplot(diamonds, aes(x = log10(carat), y = log10(price))) +
  geom_bin2d()
#The disadvantage of this scale is that the axes are now labelled with the 
#> transformed values, making it hard to interpret the plot. 
#> 
#> Insteaad of doing the log transform in the aesthetic, we can instead do it 
#> it with scale_x_log10() and scale_y_log10()!
ggplot(diamonds, aes(x = carat, y = price)) +
  geom_bin2d() + 
  scale_x_log10() + 
  scale_y_log10()
#Easier to do this than to change the ticks and labels after the fact. 

#> Another thing to consider is the color of your graph for colorblind people 
#> scale_color_brewer is a function that you can use in addition to setting the 
#> color in geom_point. 
#> Normal graph and then the graph with color blind interpretative colors. 
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = drv))

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = drv)) +
  scale_color_brewer(palette = "Set1")

#> Optionally, you can also change the shape of the points by the same variable
#> as you did with color to make the information even more accessible. 
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = drv, shape = drv)) +
  scale_color_brewer(palette = "Set1")


#> When you have a predefined mapping between values and colors, use
#> scale_color_manual() 
#> For example, if we want to map political parties we would want to use red
#> and blue. You can use hex color codes to do this. 
#> 
presidential |>
  mutate(id = 33 + row_number()) |>
  ggplot(aes(x = start, y = id, color = party)) +
  geom_point() +
  geom_segment(aes(xend = end, yend = id)) +
  scale_color_manual(values = c(Republican = "#E81B23", Democratic = "#00AEF3"))


#> For continuous color, you can use the built in scale_color_gradient() or
#> scale_fill_gradient(). If you have a diverging scale, you can use 
#> scale_color_gradient2(). That allows you to give, for example, positive and
#> negative values different colors. Sometime useful to distinguish between 
#> points above or below the mean. 
#> Another option is to use viridis color scales. These are carefully tailored
#> continuous color scales for people with color blindness. 
#>Some examples of that: 
df <- tibble(
  x = rnorm(10000),
  y = rnorm(10000)
)

ggplot(df, aes(x, y)) +
  geom_hex() +
  coord_fixed() +
  labs(title = "Default, continuous", x = NULL, y = NULL)

ggplot(df, aes(x, y)) +
  geom_hex() +
  coord_fixed() +
  scale_fill_viridis_c() +  #for continuous variables 
  labs(title = "Viridis, continuous", x = NULL, y = NULL)

ggplot(df, aes(x, y)) +
  geom_hex() +
  coord_fixed() +
  scale_fill_viridis_b() + #for binned variables 
  labs(title = "Viridis, binned", x = NULL, y = NULL)
    

#Zooming 
#> Three ways to control the plot limits: 
#> Adjusting what data are plotted 
#> Setting the limits in each scale 
#> Setting xlim and ylim in coord_cartesian() 
#> 
#> The  normal plot with all of the data
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = drv)) +
  geom_smooth()

#> Using filter to subset the data and limit the axis's 
mpg |>
  filter(displ >= 5 & displ <= 6 & hwy >= 10 & hwy <= 25) |>
  ggplot(aes(x = displ, y = hwy)) +
  geom_point(aes(color = drv)) +
  geom_smooth()

# Here we used scale_ to set the limits
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = drv)) +
  geom_smooth() +
  scale_x_continuous(limits = c(5, 6)) +
  scale_y_continuous(limits = c(10, 25))
#> This is equivalent to sub-setting the data 
#> When you subset the data, it changes how the scale looks because it is 
#> now not including all of your data! 
#> Its best to not subset data or use scale_ to zoom (unless you have very valid
#> reasons to do so)


# Here we just used coord_cartesian to zoom in 
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = drv)) +
  geom_smooth() +
  coord_cartesian(xlim = c(5, 6), ylim = c(10, 25))
#> Its best to use coord_cartesian to zoom in because it still includes all of 
#> the data you can't see and then provides an accurate picture of things, just
#> actually zoomed in. 
#> 
#> On the other hand, setting the limits is fine if you are expanding the range
#> of the graph to make sure different things match. 
#> 
suv <- mpg |> filter(class == "suv")
compact <- mpg |> filter(class == "compact")

# 
ggplot(suv, aes(x = displ, y = hwy, color = drv)) +
  geom_point()

# This plot has different axis's based upon the subset of compact cars. 
ggplot(compact, aes(x = displ, y = hwy, color = drv)) +
  geom_point()
#> One way to overcome the problem of different axis's for groups is to share
#> scales across multiple plots. 
#> We can do this by specifying some variables with the full range of values for
#> all of the data

x_scale <- scale_x_continuous(limits = range(mpg$displ))
y_scale <- scale_y_continuous(limits = range(mpg$hwy))
col_scale <- scale_color_discrete(limits = unique(mpg$drv))

# suv's 
ggplot(suv, aes(x = displ, y = hwy, color = drv)) +
  geom_point() +
  x_scale +
  y_scale +
  col_scale

# compact cars 
ggplot(compact, aes(x = displ, y = hwy, color = drv)) +
  geom_point() +
  x_scale +
  y_scale +
  col_scale

#> In this particular case you could have just used faceting. But this can be 
#> useful if you want to spread graphs out over multiple pages of a report. 
#> 
#> Themes ----- 
#> These are used to edit the non-data parts of your plot
#> 
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  theme_bw()

#You can customize just about anything under themes. 
#> Note that customization of the legend box and plot title elements of the 
#> theme are done with element_() functions. 
#> These functions specify the styling of non-data components 
#> For example, the title text is bolded in the face argument of element_text() 
#> and the legend border color is defined in the color argument of element_rect()
#> Some examples: 
#> 
ggplot(mpg, aes(x = displ, y = hwy, color = drv)) +
  geom_point() +
  labs(
    title = "Larger engine sizes tend to have lower fuel economy",
    caption = "Source: https://fueleconomy.gov."
  ) +
  theme(
    legend.position = c(0.6, 0.7),
    legend.direction = "horizontal",
    legend.box.background = element_rect(color = "black"),
    plot.title = element_text(face = "bold"),
    plot.title.position = "plot",
    plot.caption.position = "plot", #"plot" indicates that these elements are aligned to the entire plot area. 
    plot.caption = element_text(hjust = 0)
  )

#> The ggplot2 book is a great resource for full details on theming. 
#> 
#> Layout ----- 
#> 
#> What if you have multiple plots that you want to layout in a certain way? 
#> 
#> To place two plots next to each other you can simply add them to each other. 
#> You first need to create them and save them as objects. 
#> 
p1 <- ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_point() + 
  labs(title = "Plot 1")
p2 <- ggplot(mpg, aes(x = drv, y = hwy)) + 
  geom_boxplot() + 
  labs(title = "Plot 2")
p1 + p2

# A more advanced plot layout. 
#> Put plots 1 and 3 next to each other and plot 2 on the next line
p3 <- ggplot(mpg, aes(x = cty, y = hwy)) + 
  geom_point() + 
  labs(title = "Plot 3")
(p1 | p3) / p2


#> In addition, patchwork allows you to collect legends from multiple plots
#> into one common legend, and then you can customize that legend. 
#> Example of doing this with 5 plots: 

p1 <- ggplot(mpg, aes(x = drv, y = cty, color = drv)) + 
  geom_boxplot(show.legend = FALSE) + 
  labs(title = "Plot 1")

p2 <- ggplot(mpg, aes(x = drv, y = hwy, color = drv)) + 
  geom_boxplot(show.legend = FALSE) + 
  labs(title = "Plot 2")

p3 <- ggplot(mpg, aes(x = cty, color = drv, fill = drv)) + 
  geom_density(alpha = 0.5) + 
  labs(title = "Plot 3")

p4 <- ggplot(mpg, aes(x = hwy, color = drv, fill = drv)) + 
  geom_density(alpha = 0.5) + 
  labs(title = "Plot 4")

p5 <- ggplot(mpg, aes(x = cty, y = hwy, color = drv)) + 
  geom_point(show.legend = FALSE) + 
  facet_wrap(~drv) +
  labs(title = "Plot 5")

#> Here is where we setup the plot layout and customize it! 
(guide_area() / (p1 + p2) / (p3 + p4) / p5) +
  plot_annotation(
    title = "City and highway mileage for cars with different drive trains",
    caption = "Source: https://fueleconomy.gov."
  ) +
  plot_layout(
    guides = "collect",
    heights = c(1, 3, 2, 4) #> guide has height of 1, box plots 3, density plots 2, and scatter plots 4
  ) &
  theme(legend.position = "top")

