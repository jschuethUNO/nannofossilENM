#####
##Ecological Niche Modeling for Calcareous Nannofossils
#Jon Schueth, University of Nebraska Omaha
#Last Updated: Jan, 2026
#Caution: this still is a work in progress! It may not work perfectly in all cases!
#If you have questions, email:jschueth@unomaha.edu
#Code will work with small datasets, but needs big data for accuracy!

#Also note that you need to revise the code to add in calls to your own data!
#all calls to datasets are replaced with generic placeholders
#this code WILL NOT WORK until you replace these with your own data!!!


#####
#You need these packages for the model to work! 
#load required packages
library(maptools)
library(dismo)
library(randomForest)
library(gstat)
library(ggplot2)

#####
##This load the data
#See readme on Github for how data should be formatted
#Data includes taxon of interest and all paleoenvironmental variables
#variables can be numerical or categorical (or mixed)

databig=read.table("DATASET.txt", header=TRUE, row.names=1)


#make data into a data frame for use in other lines
databig.df=data.frame(databig)

#Also need to extract the paleoproxy data sans taxon abundance:
#Remember that this assumes taxon abundance is in column 3!!!
databig.proxy.df=databig.df[,-3]

#####
#The Random Forest Regression steps
#First the RFR is tuned using the tuneRF command
#Again, you must replace the all caps taxon code for this to work!!!
#You must also have the taxon abundance as the third column in the big dataset
#If not, then change the "3" below in the first line to match what that column is

trf=tuneRF(databig.df[,-3], databig.df[,'TAXONCOLUMNNAME'])
mt=trf[which.min(trf[,2]),1]

#The next step runs the tuned RFR - this is the test model for the ENM:
#AGAIN MAKE SURE TO CHANGE THE ALL CAPS PART OR THIS WONT WORK

rrf=randomForest(databig.df[,-3], databig.df[,'TAXONCOLUMNNAME'], mtry=mt)



#####
#Now the code makes a geospatial grid for ENM prediction
#The first step uses the location x/y or lat/lon in columns 1 and 2 to make the grid
ew=extent(SpatialPoints(databig.df[,1:2]))
p=as(ew, 'SpatialPolygons')
grid=makegrid(p, n=5000)

#data is in databig.proxy.df
coordinates(databig.proxy.df)=~Lat+Lon
coordinates(grd)=~x1+x2

#Now the code will develop an extrapolated kriging contour of proxy data
#v is the variogram function for the kriging step:
v=function(x, y=x){exp(-spDists(coordinates(x),coordinates(y))/500)}

#y here binds together all of the proxy data into a new matrix
#For some reason this is the only way I could get it to work
#You'll have to edit this to match your proxy data
#Each part represents each proxy variable
y=cbind(databig.proxy.df$Mg, databig.proxy.df$Al, databig.proxy.df$Si, 
        databig.proxy.df$K, databig.proxy.df$P, databig.proxy.df$S, 
        databig.proxy.df$Ca, databig.proxy.df$Ti, databig.proxy.df$V, 
        databig.proxy.df$Mn, databig.proxy.df$Fe, databig.proxy.df$Ni, 
        databig.proxy.df$Cu, databig.proxy.df$Zn, databig.proxy.df$Rb, 
        databig.proxy.df$Sr, databig.proxy.df$Y, databig.proxy.df$Zr, 
        databig.proxy.df$Ba, databig.proxy.df$Th, databig.proxy.df$U)
#x now runs the kriging model on the proxy data and fills the grid
#note that hte first function "Mg~1" must be "fixed" to whatever the first variable in your proxy dataset
x=krige0(Mg~1, databig.proxy.df, grd, v, y=y)

#The step here takes the kriged model and places a point at each grid center
grid$Lat=grid$x1
grid$Lon=grid$x2
grid=grid[,3:4]

#Then this makes an individual grid layer for each variable, again need to update this if you have different variables
grid$Mg=x[,1]
grid$Al=x[,2]
grid$Si=x[,3]
grid$K=x[,4]
grid$P=x[,5]
grid$S=x[,6]
grid$Ca=x[,7]
grid$Ti=x[,8]
grid$V=x[,9]
grid$Mn=x[,10]
grid$Fe=x[,11]
grid$Ni=x[,12]
grid$Cu=x[,13]
grid$Zn=x[,14]
grid$Rb=x[,15]
grid$Sr=x[,16]
grid$Y=x[,17]
grid$Zr=x[,18]
grid$Ba=x[,19]
grid$Th=x[,20]
grid$U=x[,21]

#Then collapse all the variable grids into a single dataframe - essentially a four-dimensional matrix
grid=data.frame(grid)

#now we predict taxon abundance using the RFR from before across the grid:

rp=predict(rrf, grid, ext=ew)

#pull lat lon from grid
grid.predict=grid[,1:2]
#This pulls the predicted taxon abundance
#Note: you need to replace "TAXONNAME" with whatever you named the column in the matrix
grid.predict$TAXONNAME=rp

#Now recombine the above into a single data frame for making plots
grid.predict.df=data.frame(grid.predict)

#Then use ggplot to make the ENM model plots - you can change this as you want
ggplot(data=grid.predict.df, mapping=aes(x=Lon, y=Lat))+
  theme_classic()+
  geom_point(aes(color=eflor))+
  scale_color_viridis(option="E")

#You can also make a variable importance plot for the taxon using the RFR as follows:

varImpPlot(rrf)

