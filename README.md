# NBADynamicPlot
This is a repo of my first attempt using the gganimate library. This entire project is based on [Curly Labs](http://curleylab.psych.columbia.edu/nba.html) own NBA dynamic plot. The libraries used for this project are <b>ggplot2, gganimate, RCurl, jsonlite, grid</b> and <b>png</b>.

## Phase 1: Transforming the Json File into a Dataframe

Thanks to the jsonlite library, we have access to the <b>fromJSON()</b> function, which allows us to structure our data into a usable dataframe in R. From this point forward, the workload consist of using a combination of loops by <b>lapply()</b> and data manipulation syntaxis to correctly asses which columns will be usefull for the dataframe. There were little to any modifications done to the original script of the [Curly Labs](http://curleylab.psych.columbia.edu/nba.html) team. If there were any modifications I would like to implement, I would be mainly taking advantage of the <b>dyplr</b> library to simplify the data manipulation.  

## Phase 2: Constructing the Static Plot 

In this part of the script, the main purpose was to create a static plot which included all the positions played in a basketball court. The main workload of this section was creating the plot by the usage of the <b>geom_point()</b> function in the ggplot2 library. The main modifications I made were the introduction of the certain loops in order to facilitate the data manipulation section, while also updating certain functions which were disable thanks to new versions of R and the libraries. 

<p align="center"><img src = "https://github.com/HTiscar/NBADynamicPlot/blob/master/Static_Plot.png" height = "480" width = "720"></p>


This is the result of the static plot generation. I must admit it was really clever how the [Curly Labs](http://curleylab.psych.columbia.edu/nba.html) team decided to assign the ball play to each player according if it was on air or in the hands of a player. 

## Phase 3: Constructing the Dynamic Plot 

<p align ="center"><img src = "https://github.com/HTiscar/NBADynamicPlot/blob/master/Dynamic_Animation.gif"></p>

<p align="center"><img src="https://github.com/HTiscar/NBADynamicPlot/blob/master/Dynamic_Plot_Court.gif"></p>
