#install.packages for different individuals dipers in the space
#function has always the ()
install.packages("spatstat")#we use the " only for something outside of R
library(spatstat) 
bei#is a dataset may represent single individual of the same species
plot(bei, pch=15, col="green")
#cex=.5 to see single points
bei.exytra is an additional dataset
#i want to have map for represnt the density (how many ants i have in this map?)
plot(bei.extra[[1]])#subset the dataset with doble square because its a map, thats mean if i want to see elv or grad without using naming it
#passing form point which are vectors to a map (raster)
beidens<- density(bei)
plot(beidens)
#higher is the elevation lower is the density  as we can see in the map
