### R for Data Science 
#Second Edition: Chapter 24, Hierarchical Data       

#Restart the console to start fresh! 
#ctrl + shift + F10 

library(tidyverse) 


#> In this chapter, you will learn the art of data rectangling: 
#> taking data that is fundamentally hierarchical, or tree-like, and converting
#> it into a rectangular data frame made up of rows and columns. 
#> 
#> Hierarchical data is surprisingly common, especially when working with data
#> that comes from the web. 
#> 
#> Two crucial tidyr functions here: 
#> unnest_longer() 
#> unnest_wider() 
#> 
#> JSON - most frequent source of hierarchical data sets and a common format
#> for data exchange on the web. 
#> 
#install.packages("repurrrsive")
library(repurrrsive) 
library(jsonlite)


#> Lists -----
#> 
#> So far we have worked with data frames that contain simple vectors like 
#> integers, numbers, characters, date-times, and factors. 
#> These vectors are simple because they are homogeneous: every element is of 
#> the same data type. 
#> 
#> If you want to store elements of different data types in the same vector, 
#> you'll need a list.
x1 <- list(1:4, "a", TRUE)
x1
#> [[1]]
#> [1] 1 2 3 4
#> 
#> [[2]]
#> [1] "a"
#> 
#> [[3]]
#> [1] TRUE

#> It's often convenient to name the components, or children, of a list. 
#> You can do this in the same way as naming the columns of a tibble: 
x2 <- list(a = 1:2, b = 1:3, c = 1:4)
x2
#> $a
#> [1] 1 2
#> 
#> $b
#> [1] 1 2 3
#> 
#> $c
#> [1] 1 2 3 4

#> Even for very simple lists, printing takes up a lot of space. 
#> A useful alternative is str() which displays the structure of the element.
str(x1)
str(x2)


#> Hierarchy: 
#> 
#> Lists can contain any type of object, including other lists! 
#> This makes them suitable for representing hierarchical structures: 

x3 <- list(list(1, 2), list(3, 4))
str(x3)
#> List of 2
#>  $ :List of 2
#>   ..$ : num 1
#>   ..$ : num 2
#>  $ :List of 2
#>   ..$ : num 3
#>   ..$ : num 4

#> Notably different than c() which generates a flat vector: 
c(c(1, 2), c(3, 4))
#> [1] 1 2 3 4

x4 <- c(list(1, 2), list(3, 4))
str(x4)
#> List of 4
#>  $ : num 1
#>  $ : num 2
#>  $ : num 3
#>  $ : num 4


#> As lists get more complex, str() gets more helpful: 
x5 <- list(1, list(2, list(3, list(4, list(5)))))
str(x5)
#> List of 2
#>  $ : num 1
#>  $ :List of 2
#>   ..$ : num 2
#>   ..$ :List of 2
#>   .. ..$ : num 3
#>   .. ..$ :List of 2
#>   .. .. ..$ : num 4
#>   .. .. ..$ :List of 1
#>   .. .. .. ..$ : num 5
#>   
#>   As lists gets really complex, str() starts to fail and you will need to use
#>   View() 
#>   With view you can interactively expand any of the components. 
View(x3)
#> When using View() its useful to notice that the first column "name" will give
#> you the subsetting code that you can use to access that level. Each further 
#> level requires all of the above subsetting level codes! 

#> List-columns 
#> 
#> Lists can also live inside a tibble, where we call them list-columns. 
#> List columns are useful because they allow you to place objects in a tibble
#> that wouldn't usually belong there. 
#> List columns are used a lot in the tidymodels ecosystem, because they allow 
#> you to store things like model outputs or resamples in a data frame. 
#> 
#> Example of a list-column: 
df <- tibble(
  x = 1:2, 
  y = c("a", "b"),
  z = list(list(1, 2), list(3, 4, 5))
)
df
#> # A tibble: 2 × 3
#>       x y     z         
#>   <int> <chr> <list>    
#> 1     1 a     <list [2]>
#> 2     2 b     <list [3]>
#> 
#> Lists in tibbles behave pretty much like any other column: 
df |> 
  filter(x == 1)
#> # A tibble: 1 × 3
#>       x y     z         
#>   <int> <chr> <list>    
#> 1     1 a     <list [2]>

df |> pull(z) |> str()


#> Unnesting ------
#> 
#> How you can turn them back into regular rows and columns 
#> 
#> List-columns come in two basic forms: 
#> named 
#> unnamed 
#> When the children are named, they tend to have the same number of elements 
#> in every row. 
#> 
#> For example with df1, every element of list-column y has two elements, a and 
#> b. These very easily unnest into two separate columns
df1 <- tribble(
  ~x, ~y,
  1, list(a = 11, b = 12),
  2, list(a = 21, b = 22),
  3, list(a = 31, b = 32),
)

#> When the children are unnamed, the number of elements tends to vary from row
#> to row: 

df2 <- tribble(
  ~x, ~y,
  1, list(11, 12, 13),
  2, list(21),
  3, list(31, 32),
)
#> Unnamed list-columns naturally unnest into rows: you'll get one row for each
#> child 


#> unnest_wider() -----
#> 
#> When each row has the same number of elements with the same names, like df1, 
#> its natural to put each componenet into its own column with unnest_wider()
df1 |> 
  unnest_wider(y)
#> # A tibble: 3 × 3
#>       x     a     b
#>   <dbl> <dbl> <dbl>
#> 1     1    11    12
#> 2     2    21    22
#> 3     3    31    32

#> You can use the names separate argument to request that they combine the 
#> column name and the element name: 
df1 |> 
  unnest_wider(y, names_sep = "_")
#> # A tibble: 3 × 3
#>       x   y_a   y_b
#>   <dbl> <dbl> <dbl>
#> 1     1    11    12
#> 2     2    21    22
#> 3     3    31    32


#> unnest_longer() ------
#> 
df2 |> 
  unnest_longer(y)
#> # A tibble: 6 × 2
#>       x     y
#>   <dbl> <dbl>
#> 1     1    11
#> 2     1    12
#> 3     1    13
#> 4     2    21
#> 5     3    31
#> 6     3    32


#> Note how x is duplicated for each element inside of y: we get one row of output
#> for each element inside the list-column. 
#> 
#> What happens if there is an empty element? 

df6 <- tribble(
  ~x, ~y,
  "a", list(1, 2),
  "b", list(3),
  "c", list()
)
df6 |> unnest_longer(y)
#> # A tibble: 3 × 2
#>   x         y
#>   <chr> <dbl>
#> 1 a         1
#> 2 a         2
#> 3 b         3

#> the row disappears. If you want to retain the row with NA's, you can use
#> keep_empty = TRUE 
#> 
#> 
#> Inconsistent types ------
#> 
df4 <- tribble(
  ~x, ~y,
  "a", list(1),
  "b", list("a", TRUE, 5)
)

df4 |> 
  unnest_longer(y)
#> # A tibble: 4 × 2
#>   x     y        
#>   <chr> <list>   
#> 1 a     <dbl [1]>
#> 2 b     <chr [1]>
#> 3 b     <lgl [1]>
#> 4 b     <dbl [1]>

#> unnest_longer() always keeps the set of columns unchanged, while changing the
#> number of rows. 
#> As you can see, the output contains a list-column, but every element of the list
#> contains a single element. Because unnest_longer() can't find a common type
#> of vector, it keeps the original types in a list-column. 
#> 
#> Dealing with inconsistent types is challenging. 
#> Chapter 27 will help with this. 
#> 
#> Other functions ------
#> 
#> unnest_auto() automatically picks between _longer() and _wider() based on the 
#> structure of the list-column. 
#> Its easier to use but doesn't make you understand your data structure and makes 
#> your code harder to understand. 
#> unnest() expands both rows and columns. It's useful when you have a list-column
#> that contains a 2D structure like a data frame. Might encounter these in tidymodels 
#> 
#> Case Studies ------
#> 
#> Most data requires several calls to unnest_wider() and unnest_longer() because
#> data will typically have multiple nesting layers 
#> 
#> Very Wide Data 
View(gh_repos)

repos <- tibble(json = gh_repos)
repos
#> This tibble contains 6 rows, one for each child of repos. 
#> 
#> We will start with unnest_longer() to put each child in its own row. 
#> 
repos |> 
  unnest_longer(json)
#> Now we have 176 rows. But they are named rows so we can use unnest_wider() 
repos |> 
  unnest_longer(json) |> 
  unnest_wider(json) 
#> # A tibble: 176 × 68
#>         id name        full_name         owner        private html_url       
#>      <int> <chr>       <chr>             <list>       <lgl>   <chr>          
#> 1 61160198 after       gaborcsardi/after <named list> FALSE   https://github…
#> 2 40500181 argufy      gaborcsardi/argu… <named list> FALSE   https://github…
#> 3 36442442 ask         gaborcsardi/ask   <named list> FALSE   https://github…
#> 4 34924886 baseimports gaborcsardi/base… <named list> FALSE   https://github…
#> 5 61620661 citest      gaborcsardi/cite… <named list> FALSE   https://github…
#> 6 33907457 clisymbols  gaborcsardi/clis… <named list> FALSE   https://github…
#> # ℹ 170 more rows
#> # ℹ 62 more variables: description <chr>, fork <lgl>, url <chr>, …

#> This has worked but now we have 68 columns and can't see them all! 
#> can look at the first ten here: 
repos |> 
  unnest_longer(json) |> 
  unnest_wider(json) |> 
  names() |> 
  head(10)
#>  [1] "id"          "name"        "full_name"   "owner"       "private"    
#>  [6] "html_url"    "description" "fork"        "url"         "forks_url"
#>  
#>  Pulling out a few that look interesting: 
repos |> 
  unnest_longer(json) |> 
  unnest_wider(json) |> 
  select(id, full_name, owner, description)
#> # A tibble: 176 × 4
#>         id full_name               owner             description             
#>      <int> <chr>                   <list>            <chr>                   
#> 1 61160198 gaborcsardi/after       <named list [17]> Run Code in the Backgro…
#> 2 40500181 gaborcsardi/argufy      <named list [17]> Declarative function ar…
#> 3 36442442 gaborcsardi/ask         <named list [17]> Friendly CLI interactio…
#> 4 34924886 gaborcsardi/baseimports <named list [17]> Do we get warnings for …
#> 5 61620661 gaborcsardi/citest      <named list [17]> Test R package and repo…
#> 6 33907457 gaborcsardi/clisymbols  <named list [17]> Unicode symbols for CLI…
#> # ℹ 170 more rows

#> We can use this to get an idea of how the data was structured: 
#> Each child was a GitHub user containing a list of up to 30 GitHub repositories
#> that they created. 
#> 
#> Owner is another list-column, and since it contains a named list, we can use
#> unnest_wider() to get at the values: 
repos |> 
  unnest_longer(json) |> 
  unnest_wider(json) |> 
  select(id, full_name, owner, description) |> 
  unnest_wider(owner)
#> Error in `unnest_wider()`:
#> ! Can't duplicate names between the affected columns and the original
#>   data.
#> ✖ These names are duplicated:
#>   ℹ `id`, from `owner`.
#> ℹ Use `names_sep` to disambiguate using the column name.
#> ℹ Or use `names_repair` to specify a repair strategy.
#> 
#> UH OH - the list-column we tried to access also contains an ID column and we 
#> can't have two of them in the same data frame. 
#> We use names_sep to resolve the problem:
repos |> 
  unnest_longer(json) |> 
  unnest_wider(json) |> 
  select(id, full_name, owner, description) |> 
  unnest_wider(owner, names_sep = "_")
#> # A tibble: 176 × 20
#>         id full_name               owner_login owner_id owner_avatar_url     
#>      <int> <chr>                   <chr>          <int> <chr>                
#> 1 61160198 gaborcsardi/after       gaborcsardi   660288 https://avatars.gith…
#> 2 40500181 gaborcsardi/argufy      gaborcsardi   660288 https://avatars.gith…
#> 3 36442442 gaborcsardi/ask         gaborcsardi   660288 https://avatars.gith…
#> 4 34924886 gaborcsardi/baseimports gaborcsardi   660288 https://avatars.gith…
#> 5 61620661 gaborcsardi/citest      gaborcsardi   660288 https://avatars.gith…
#> 6 33907457 gaborcsardi/clisymbols  gaborcsardi   660288 https://avatars.gith…
#> # ℹ 170 more rows
#> # ℹ 15 more variables: owner_gravatar_id <chr>, owner_url <chr>, …

#> Now we have 20 columns, so the owner list must have contained a lot of data too. 
#> 
#> Relational Data 
#> 
chars <- tibble(json = got_chars)
chars
#> # A tibble: 30 × 1
#>   json             
#>   <list>           
#> 1 <named list [18]>
#> 2 <named list [18]>
#> 3 <named list [18]>
#> 4 <named list [18]>
#> 5 <named list [18]>
#> 6 <named list [18]>
#> # ℹ 24 more rows
#> 
#> Since we have named lists we can widen it: 
chars |> 
  unnest_wider(json)
#> # A tibble: 30 × 18
#>   url                    id name            gender culture    born           
#>   <chr>               <int> <chr>           <chr>  <chr>      <chr>          
#> 1 https://www.anapio…  1022 Theon Greyjoy   Male   "Ironborn" "In 278 AC or …
#> 2 https://www.anapio…  1052 Tyrion Lannist… Male   ""         "In 273 AC, at…
#> 3 https://www.anapio…  1074 Victarion Grey… Male   "Ironborn" "In 268 AC or …
#> 4 https://www.anapio…  1109 Will            Male   ""         ""             
#> 5 https://www.anapio…  1166 Areo Hotah      Male   "Norvoshi" "In 257 AC or …
#> 6 https://www.anapio…  1267 Chett           Male   ""         "At Hag's Mire"
#> # ℹ 24 more rows
#> # ℹ 12 more variables: died <chr>, alive <lgl>, titles <list>, …
#> 
#> Selecting a few columns to make it easier to read: 
characters <- chars |> 
  unnest_wider(json) |> 
  select(id, name, gender, culture, born, died, alive)
characters
#> # A tibble: 30 × 7
#>      id name              gender culture    born              died           
#>   <int> <chr>             <chr>  <chr>      <chr>             <chr>          
#> 1  1022 Theon Greyjoy     Male   "Ironborn" "In 278 AC or 27… ""             
#> 2  1052 Tyrion Lannister  Male   ""         "In 273 AC, at C… ""             
#> 3  1074 Victarion Greyjoy Male   "Ironborn" "In 268 AC or be… ""             
#> 4  1109 Will              Male   ""         ""                "In 297 AC, at…
#> 5  1166 Areo Hotah        Male   "Norvoshi" "In 257 AC or be… ""             
#> 6  1267 Chett             Male   ""         "At Hag's Mire"   "In 299 AC, at…
#> # ℹ 24 more rows
#> # ℹ 1 more variable: alive <lgl>
#> 
#> This data set contains also many list-columns: 
chars |> 
  unnest_wider(json) |> 
  select(id, where(is.list))
#> # A tibble: 30 × 8
#>      id titles    aliases    allegiances books     povBooks tvSeries playedBy
#>   <int> <list>    <list>     <list>      <list>    <list>   <list>   <list>  
#> 1  1022 <chr [2]> <chr [4]>  <chr [1]>   <chr [3]> <chr>    <chr>    <chr>   
#> 2  1052 <chr [2]> <chr [11]> <chr [1]>   <chr [2]> <chr>    <chr>    <chr>   
#> 3  1074 <chr [2]> <chr [1]>  <chr [1]>   <chr [3]> <chr>    <chr>    <chr>   
#> 4  1109 <chr [1]> <chr [1]>  <NULL>      <chr [1]> <chr>    <chr>    <chr>   
#> 5  1166 <chr [1]> <chr [1]>  <chr [1]>   <chr [3]> <chr>    <chr>    <chr>   
#> 6  1267 <chr [1]> <chr [1]>  <NULL>      <chr [2]> <chr>    <chr>    <chr>   
#> # ℹ 24 more rows
#> 
#> Exploring the title column: 
chars |> 
  unnest_wider(json) |> 
  select(id, titles) |> 
  unnest_longer(titles)
#> # A tibble: 59 × 2
#>      id titles                                              
#>   <int> <chr>                                               
#> 1  1022 Prince of Winterfell                                
#> 2  1022 Lord of the Iron Islands (by law of the green lands)
#> 3  1052 Acting Hand of the King (former)                    
#> 4  1052 Master of Coin (former)                             
#> 5  1074 Lord Captain of the Iron Fleet                      
#> 6  1074 Master of the Iron Victory                          
#> # ℹ 53 more rows
#> 
#> You might expect to see this data in its own table because it would be easy
#> to join to the characters data as needed: 
titles <- chars |> 
  unnest_wider(json) |> 
  select(id, titles) |> 
  unnest_longer(titles) |> 
  filter(titles != "") |> 
  rename(title = titles)
titles
#> # A tibble: 52 × 2
#>      id title                                               
#>   <int> <chr>                                               
#> 1  1022 Prince of Winterfell                                
#> 2  1022 Lord of the Iron Islands (by law of the green lands)
#> 3  1052 Acting Hand of the King (former)                    
#> 4  1052 Master of Coin (former)                             
#> 5  1074 Lord Captain of the Iron Fleet                      
#> 6  1074 Master of the Iron Victory                          
#> # ℹ 46 more rows
#> 
#> You could imagine doing this for each list-column as desired and then later
#> using joins to combine them with the character data as needed. 

#> Deeply Nested 
#> 
gmaps_cities

gmaps_cities |> 
  unnest_wider(json)
#> # A tibble: 5 × 3
#>   city       results    status
#>   <chr>      <list>     <chr> 
#> 1 Houston    <list [1]> OK    
#> 2 Washington <list [2]> OK    
#> 3 New York   <list [1]> OK    
#> 4 Chicago    <list [1]> OK    
#> 5 Arlington  <list [2]> OK

gmaps_cities |> 
  unnest_wider(json) |> 
  select(-status) |> 
  unnest_longer(results)
#> # A tibble: 7 × 2
#>   city       results         
#>   <chr>      <list>          
#> 1 Houston    <named list [5]>
#> 2 Washington <named list [5]>
#> 3 Washington <named list [5]>
#> 4 New York   <named list [5]>
#> 5 Chicago    <named list [5]>
#> 6 Arlington  <named list [5]>
#> # ℹ 1 more row
#> 
#> Now results is a named list, so we'll use unnest_wider() 
locations <- gmaps_cities |> 
  unnest_wider(json) |> 
  select(-status) |> 
  unnest_longer(results) |> 
  unnest_wider(results)
locations
#> # A tibble: 7 × 6
#>   city       address_components formatted_address   geometry        
#>   <chr>      <list>             <chr>               <list>          
#> 1 Houston    <list [4]>         Houston, TX, USA    <named list [4]>
#> 2 Washington <list [2]>         Washington, USA     <named list [4]>
#> 3 Washington <list [4]>         Washington, DC, USA <named list [4]>
#> 4 New York   <list [3]>         New York, NY, USA   <named list [4]>
#> 5 Chicago    <list [4]>         Chicago, IL, USA    <named list [4]>
#> 6 Arlington  <list [4]>         Arlington, TX, USA  <named list [4]>
#> # ℹ 1 more row
#> # ℹ 2 more variables: place_id <chr>, types <list>
#> 
#> 
#> Now we might want to determine the exact location of the match, which is 
#> stored in the geomtry list-column: 
locations |> 
  select(city, formatted_address, geometry) |> 
  unnest_wider(geometry)
#> # A tibble: 7 × 6
#>   city       formatted_address   bounds           location     location_type
#>   <chr>      <chr>               <list>           <list>       <chr>        
#> 1 Houston    Houston, TX, USA    <named list [2]> <named list> APPROXIMATE  
#> 2 Washington Washington, USA     <named list [2]> <named list> APPROXIMATE  
#> 3 Washington Washington, DC, USA <named list [2]> <named list> APPROXIMATE  
#> 4 New York   New York, NY, USA   <named list [2]> <named list> APPROXIMATE  
#> 5 Chicago    Chicago, IL, USA    <named list [2]> <named list> APPROXIMATE  
#> 6 Arlington  Arlington, TX, USA  <named list [2]> <named list> APPROXIMATE  
#> # ℹ 1 more row
#> # ℹ 1 more variable: viewport <list>
#> 
#> Now we can unnest location to see the lat and lng:  
locations |> 
  select(city, formatted_address, geometry) |> 
  unnest_wider(geometry) |> 
  unnest_wider(location)
#> # A tibble: 7 × 7
#>   city       formatted_address   bounds             lat    lng location_type
#>   <chr>      <chr>               <list>           <dbl>  <dbl> <chr>        
#> 1 Houston    Houston, TX, USA    <named list [2]>  29.8  -95.4 APPROXIMATE  
#> 2 Washington Washington, USA     <named list [2]>  47.8 -121.  APPROXIMATE  
#> 3 Washington Washington, DC, USA <named list [2]>  38.9  -77.0 APPROXIMATE  
#> 4 New York   New York, NY, USA   <named list [2]>  40.7  -74.0 APPROXIMATE  
#> 5 Chicago    Chicago, IL, USA    <named list [2]>  41.9  -87.6 APPROXIMATE  
#> 6 Arlington  Arlington, TX, USA  <named list [2]>  32.7  -97.1 APPROXIMATE  
#> # ℹ 1 more row
#> # ℹ 1 more variable: viewport <list>
#> 
#> Unnesting the bounds is a big more complex:
locations |> 
  select(city, formatted_address, geometry) |> 
  unnest_wider(geometry) |> 
  # focus on the variables of interest
  select(!location:viewport) |>
  unnest_wider(bounds)
#> # A tibble: 7 × 4
#>   city       formatted_address   northeast        southwest       
#>   <chr>      <chr>               <list>           <list>          
#> 1 Houston    Houston, TX, USA    <named list [2]> <named list [2]>
#> 2 Washington Washington, USA     <named list [2]> <named list [2]>
#> 3 Washington Washington, DC, USA <named list [2]> <named list [2]>
#> 4 New York   New York, NY, USA   <named list [2]> <named list [2]>
#> 5 Chicago    Chicago, IL, USA    <named list [2]> <named list [2]>
#> 6 Arlington  Arlington, TX, USA  <named list [2]> <named list [2]>
#> # ℹ 1 more row
#> 
#> Now we can rename southwest and northeast (corners of the rectangle) so we 
#> can use names_sep to create short but evocative names: 
locations |> 
  select(city, formatted_address, geometry) |> 
  unnest_wider(geometry) |> 
  select(!location:viewport) |>
  unnest_wider(bounds) |> 
  rename(ne = northeast, sw = southwest) |> 
  unnest_wider(c(ne, sw), names_sep = "_") 
#> # A tibble: 7 × 6
#>   city       formatted_address   ne_lat ne_lng sw_lat sw_lng
#>   <chr>      <chr>                <dbl>  <dbl>  <dbl>  <dbl>
#> 1 Houston    Houston, TX, USA      30.1  -95.0   29.5  -95.8
#> 2 Washington Washington, USA       49.0 -117.    45.5 -125. 
#> 3 Washington Washington, DC, USA   39.0  -76.9   38.8  -77.1
#> 4 New York   New York, NY, USA     40.9  -73.7   40.5  -74.3
#> 5 Chicago    Chicago, IL, USA      42.0  -87.5   41.6  -87.9
#> 6 Arlington  Arlington, TX, USA    32.8  -97.0   32.6  -97.2
#> # ℹ 1 more row
#> 
#> Two unnest two columns simultaneously we supplied a vector of variable names
#> to unnest_wider() using c()
#> 
#> Once you have discovered the path to get to the components you are interested in, 
#> you can extract them directly using another tidyr function, hoist():

locations |> 
  select(city, formatted_address, geometry) |> 
  hoist(
    geometry,
    ne_lat = c("bounds", "northeast", "lat"),
    sw_lat = c("bounds", "southwest", "lat"),
    ne_lng = c("bounds", "northeast", "lng"),
    sw_lng = c("bounds", "southwest", "lng"),
  )


#> JSON -----
#> 
#> 
#> JSON is short for javascript object notation 
#> It is the way that most web APIs return data. 
#> 
#> 
#> Data Types 
#> JSON has 6 key data types; 4 of which are scalars: 
#> NULL - plays a similar roll to NA in R. Represents absence of data
#> string - much like a string in R, but must always use double quotes 
#> number - similar to R's numbers: they can use integer, decimal, or scientific
#> boolean - similar to R's TRUE and FALSE, but uses lowercase: true and false 
#> 
#> JSON's scalars can only represent a single value. To represent multiple values
#> you need to use one of the two remaining types: arrays and objects. 
#> Arrays and objects are similar to lists in R. 
#> The difference is whether or not they are named. 
#> An array is like an unnamed list, and is written with [] 
#> An object is a named list, and is written with {} 
#> 
#> 
#> jsonlite -------
#> 
#> To convert JSON into R data structures, the jsonlite package is recommended. 
#> 
#> Two jsonlite functions: 
#> read_json() -to read a JSON file from disk 
#> parse_json() 
# A path to a json file inside the package:
gh_users_json()
#> [1] "/home/runner/work/_temp/Library/repurrrsive/extdata/gh_users.json"

# Read it with read_json()
gh_users2 <- read_json(gh_users_json())

# Check it's the same as the data we were using previously
identical(gh_users, gh_users2)
#> [1] TRUE

#> parse_json(), takes a string containing JSON, which makes it good for 
#> generating examples: 
str(parse_json('1'))
#>  int 1
str(parse_json('[1, 2, 3]'))
#> List of 3
#>  $ : int 1
#>  $ : int 2
#>  $ : int 3
str(parse_json('{"x": [1, 2, 3]}'))
#> List of 1
#>  $ x:List of 3
#>   ..$ : int 1
#>   ..$ : int 2
#>   ..$ : int 3
#>   
#>   
#>   fromJSON() is another important function. 
#>  Not covered here because it performs automatic simplification 
#>  (simlifyVector = TRUE). 
#>  This often works well, but we think you are better off doing the rectangling 
#>  yourself so you know whats happening and can more easily understand and handle
#>  complex data structures
#>  
#>  Starting the rectangling process 
#>  
#>  In most cases, JSON files contain a single top-level array, because they are
#>  designed to provide data about multiple "things. 
json <- '[
  {"name": "John", "age": 34},
  {"name": "Susan", "age": 27}
]'
df <- tibble(json = parse_json(json))
df
#> # A tibble: 2 × 1
#>   json            
#>   <list>          
#> 1 <named list [2]>
#> 2 <named list [2]>

df |> 
  unnest_wider(json)
#> # A tibble: 2 × 2
#>   name    age
#>   <chr> <int>
#> 1 John     34
#> 2 Susan    27
#> 
#> 
#> In some cases, the JSON file consists of a single-top level JSON object, 
#> representing one "thing." 
json <- '{
  "status": "OK", 
  "results": [
    {"name": "John", "age": 34},
    {"name": "Susan", "age": 27}
 ]
}
'
df <- tibble(json = list(parse_json(json)))
df
#> # A tibble: 1 × 1
#>   json            
#>   <list>          
#> 1 <named list [2]>

df |> 
  unnest_wider(json) |> 
  unnest_longer(results) |> 
  unnest_wider(results)
#> # A tibble: 2 × 3
#>   status name    age
#>   <chr>  <chr> <int>
#> 1 OK     John     34
#> 2 OK     Susan    27









