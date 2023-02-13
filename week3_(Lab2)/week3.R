install.packages("spdplyr")
library(raster)
library(rgdal)
library(rgeos)
library(sf)
#mapview and RcolorBrewer for mapping 
library(mapview)
library(RColorBrewer) 

#spdplyr works well with attribute table
library(dplyr)
library(spdplyr)

a<-readOGR('.',layer='watershed')
plot(a)
summary(a)
mapview(a, zcol = "Elev", col.regions=brewer.pal(9,"YlGn")) 


#select and filter functions
a %>% select(ElevMin,ElevMax)
sub <- a %>% filter(ElevMax>300) 
mapview(sub, zcol = "Elev", col.regions=brewer.pal(9,"YlGn")) 

#use pip to combine functions 
a %>% 
  select(ElevMin,ElevMax) %>% 
  filter(ElevMax>500) %>%
  mapview(zcol = "ElevMin", col.regions=brewer.pal(9,"YlGn")) 


#mutate function:changes the values of columns and creates new columns.
b <- sub %>% mutate(mElev= (ElevMin+ElevMax)/2)
mapview(b,zcol = "mElev", col.regions=brewer.pal(9,"YlGn")) 



### GIS: Add Data -> (ex. agstats) link to shp file(watershed) to visualize -> 
#add join by ObjectID
#more spatial analysis with shapefiles 
#join table to shapefile
a<-readOGR('.',layer='watershed')
b<-read.csv('agstats.csv')

output<- merge(a,b,by='Subbasin')
mapview(output,zcol = "MEAN", col.regions=brewer.pal(9,"YlGn")) 
writeOGR(output,dsn='.',layer='test',driver='ESRI Shapefile',overwrite=T)

#example for buffer
dem<-raster('dem.tif')
plot(dem)
stream<- readOGR('.',layer='stream')
plot(stream,add=T)
stream_b<-gBuffer(stream,byid=F,width =300)
plot(stream_b,add=T)

#different buffer size based on a column (stream width)
buffersize<-rep(0,length(stream)) # create empty vector
buffersize[stream$Wid2>16]<-300
buffersize[stream$Wid2<=16]<-100
plot(dem)
stream_b<-gBuffer(stream,byid=T,width =buffersize)
plot(stream_b,add=T)



#spatial union of all polygons
#first add a column (id), and code all features with 1
a<-readOGR('.',layer='watershed')
a$id<-1 #to create one group for all polygons in file
studyarea<-gUnaryUnion(a, id =a$id)
plot(studyarea)
# use unionSpatialPlygons from maptools to merge polygons; 
# id - A vector defining the output Polygons objects
# studyarea <- unionSpatialPolygons(a, a$id)


#spatial union by groups; seperating study area into groups
a<-readOGR('.',layer='watershed')
a$id<-1
#modify id value - first 10 only
a$id[1:10]<-2
a$id[11:20]<-3
studyarea <- gUnaryUnion(a, a$id)
plot(studyarea)


##The following script is for demos of zonal statistics
### GIS: add dem and watershed ontop -> for mean elevation each polygon;
# zonal stats as table function -> zone field = subbasin, value raster = dem, 
# statistic type = all
##Instructional video week3.2
cbg<-readOGR('.',layer='cbg')
crs(cbg)

dem<-raster('dem_county.tif')
demp<-projectRaster(dem,res=30,crs=crs(cbg))

#rasterize cgb 
cbg$newid<-1:length(cbg)
cbg_raster<-rasterize(cbg,demp,field=cbg$newid) #rasterize() add dem template gives each polygon id
dem_mean <- zonal(demp, cbg_raster, fun='mean')
dem_max <- zonal(demp, cbg_raster, fun='max')
dem_min <- zonal(demp, cbg_raster, fun='min')

colnames(dem_mean) [1] <- "newid" #changes zone column name
output <- merge(cbg, dem_mean, by = "newid") #match up using merge
mapview(output, zcol = "mean", col.regions = brewer.pal(9,"YlGn"))
