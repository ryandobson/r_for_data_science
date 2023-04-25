### R for Data Science 
#Second Edition: Chapter 25, Web Scraping        

#Restart the console to start fresh! 
#ctrl + shift + F10 

library(tidyverse) 
library(rvest)


#> There are some legality/ethical issues to consider before web scraping data.
#> Review from the textbook/other online resources 
#> 
#> 
#> HTML Basics ----
#> 
#> hypertext markup language 
#> 
#> Has a hierarchical structure formed by elements which consist of a start tag,
#> optional attributes, an end tag, and contents. 
#> 
#> < and > are used for start and end tags. But since they mean other things here
#> we have to use escapes: &gt and &lt 
#> 
#> Elements 
#> 
#> There are over 100 HTML elements. 
#> html, head, body, heading 1, section, paragraph, ol, etc. 
#> 
#> Attributes 
#> 
#> tags can have attributes which look like name1 = "value1" etc. 
#> Two of the most important attributes are id and class. 
#> These are used in conjuction with CSS (Cascading Style Sheets) to control the
#> visual appearance of the page. 
#> These are often useful when scarping data off a page. 
#> 
#> Extracting Data -------
#> 
#> To get started with scraping you'll need the URL of the page you want to 
#> scrape, which you can usually copy from your web browser. 
#> You'll then need to read the HTML for that page into R with read_html() 
#> This returns an xml_document object which you'll then manipulate using 
#> rvest functions
#> 
#> rvest also includes functions that lets you write HTML inline. 
html <- read_html("http://rvest.tidyverse.org/")
html
#> {html_document}
#> <html lang="en">
#> [1] <head>\n<meta http-equiv="Content-Type" content="text/html; charset=UT ...
#> [2] <body>\n    <a href="#container" class="visually-hidden-focusable">Ski ...

html <- minimal_html("
  <p>This is a paragraph</p>
  <ul>
    <li>This is a bulleted list</li>
  </ul>
")
html
#> {html_document}
#> <html>
#> [1] <head>\n<meta http-equiv="Content-Type" content="text/html; charset=UT ...
#> [2] <body>\n<p>This is a paragraph</p>\n  <ul>\n<li>This is a bulleted lis ...


#> Now that you have the HTML in R, it's time to extract the data of interest. 
#>
#> Find Elements 
#> 
#> CSS includes a miniature language for selecting elements on a page called CSS
#> seletors. CSS selectors define patterns for locating HTML elements, and are 
#> useful for scraping because the provide a concise way of describing which 
#> elements you want to extract. 
#> 
#> You can get a long way with just three selectors: 
#> p 
#> .title 
#> #title 
#> 
#> Examples: 
html <- minimal_html("
  <h1>This is a heading</h1>
  <p id='first'>This is a paragraph</p>
  <p class='important'>This is an important paragraph</p>
")
#> Using html_elements() to find all elements that match the selector: 
html |> html_elements("p")
#> {xml_nodeset (2)}
#> [1] <p id="first">This is a paragraph</p>
#> [2] <p class="important">This is an important paragraph</p>
html |> html_elements(".important")
#> {xml_nodeset (1)}
#> [1] <p class="important">This is an important paragraph</p>
html |> html_elements("#first")
#> {xml_nodeset (1)}
#> [1] <p id="first">This is a paragraph</p>

#> html_element() is an important function which always returns the same number
#> of outputs as inputs. If you apply it to a whole document, it'll give you the 
#> first match:
html |> html_element("p")
#> {html_node}
#> <p id="first">
#> 
#> Important difference between html_element() and html_elements() when you use a
#> selector that doesn't match any elements. html_elements() returns a vector of
#> length 0, where html_element() returns a missing value. 
#> 
html |> html_elements("b")
#> {xml_nodeset (0)}
html |> html_element("b")
#> {xml_missing}
#> <NA>

#> Nesting Selections 
#> 
#> You typically use the html_element(S)() functions together. 
#> You use html_elements() to identify elements that will become observations then 
#> using html_element() to find elements that will become variables. 
#> Example: 
html <- minimal_html("
  <ul>
    <li><b>C-3PO</b> is a <i>droid</i> that weighs <span class='weight'>167 kg</span></li>
    <li><b>R4-P17</b> is a <i>droid</i></li>
    <li><b>R2-D2</b> is a <i>droid</i> that weighs <span class='weight'>96 kg</span></li>
    <li><b>Yoda</b> weighs <span class='weight'>66 kg</span></li>
  </ul>
  ")

#> We can use html_elements() to make a vector where each element corresponds to
#> a different character:
characters <- html |> html_elements("li")
characters
#> {xml_nodeset (4)}
#> [1] <li>\n<b>C-3PO</b> is a <i>droid</i> that weighs <span class="weight"> ...
#> [2] <li>\n<b>R4-P17</b> is a <i>droid</i>\n</li>
#> [3] <li>\n<b>R2-D2</b> is a <i>droid</i> that weighs <span class="weight"> ...
#> [4] <li>\n<b>Yoda</b> weighs <span class="weight">66 kg</span>\n</li>

#> To extract the name of each character, we use html_element(), because when 
#> applied to the output of html_elements() its guaranteed to return one response
#> per element: 
characters |> html_element("b")
#> {xml_nodeset (4)}
#> [1] <b>C-3PO</b>
#> [2] <b>R4-P17</b>
#> [3] <b>R2-D2</b>
#> [4] <b>Yoda</b>

#> html_element() versus html_elements() isn't important for name, but it is 
#> important for weight. We want to get one weight for each character, even if
#> there is no weight <span> 
characters |> html_element(".weight")
#> {xml_nodeset (4)}
#> [1] <span class="weight">167 kg</span>
#> [2] <NA>
#> [3] <span class="weight">96 kg</span>
#> [4] <span class="weight">66 kg</span>

#> If we use html_elments() then we lose the connection between weight and name
#> because it automatically removes the missing row. 
characters |> html_elements(".weight")
#> {xml_nodeset (3)}
#> [1] <span class="weight">167 kg</span>
#> [2] <span class="weight">96 kg</span>
#> [3] <span class="weight">66 kg</span>


#> Text and Attributes
#> 
#> html_text2() extracts the plain text contents of an HTML element: 
characters |> 
  html_element("b") |> 
  html_text2()
#> [1] "C-3PO"  "R4-P17" "R2-D2"  "Yoda"

characters |> 
  html_element(".weight") |> 
  html_text2()
#> [1] "167 kg" NA       "96 kg"  "66 kg"

#> html_attr() extracts data from attributes: 
html <- minimal_html("
  <p><a href='https://en.wikipedia.org/wiki/Cat'>cats</a></p>
  <p><a href='https://en.wikipedia.org/wiki/Dog'>dogs</a></p>
")

html |> 
  html_elements("p") |> 
  html_element("a") |> 
  html_attr("href")
#> [1] "https://en.wikipedia.org/wiki/Cat" "https://en.wikipedia.org/wiki/Dog"

#> Tables 
#> 
#> If you are lucky, your data will already be stored in an HTML table, and it'll
#> just be a matter of reading it from that table. 
#> 
#> Simple HTML table: 
html <- minimal_html("
  <table class='mytable'>
    <tr><th>x</th>   <th>y</th></tr>
    <tr><td>1.5</td> <td>2.7</td></tr>
    <tr><td>4.9</td> <td>1.3</td></tr>
    <tr><td>7.2</td> <td>8.1</td></tr>
  </table>
  ")

#>rvest provides a function that knows how to read this sort of data: html_table() 
#>It returns a list containing one tibble for each table found on the page.
html |> 
  html_element(".mytable") |> 
  html_table()
#> # A tibble: 3 × 2
#>       x     y
#>   <dbl> <dbl>
#> 1   1.5   2.7
#> 2   4.9   1.3
#> 3   7.2   8.1

#> Note that x and y were automatically converted to numbers. Sometimes this 
#> conversion does not work out and you might just want to set it to 
#> convert = FALSE and then change it yourself after the fact. 
#> 
#> 
#> Finding the Right Selectors ------
#> 
#> You often need to do some trial and error to find a selector that is specific
#> enough but not too specific. 
#> 
#> There is a tool for this. See the textbook for more info. 
#> 
#> Putting it All Together ------
#> 
#> They have a few examples to go through. Not worth my time currently. 
#> 
#> Dynamic Sites -----
#> 
#> New problems emerge here. See textbook. 
#> 
#> 

