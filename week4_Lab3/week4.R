
#you'll need to first install tidyverse library
library(tidyverse)

#ggplot for a simple scatter plot
ggplot(data = mpg, mapping = aes(x = displ, y = hwy))+
  geom_point()

ggplot(mpg,aes(displ,hwy))+
  geom_point(size=3,color='red')

ggplot(mpg,aes(displ,hwy))+
  geom_point(size=3,color='blue')+
  labs(x='Engine Size',y='Fuel efficiency',title='MPG Plot')+
  theme_bw(base_size = 20)


#use ggplot2 for mapping 
library(rgdal)
library(raster)
library(ggplot2)

roads<-readOGR('.','road100k_l_va121')
#The fortify function turns a spatial object into a data frame that can more easily be plotted with ggplot2.
roads_df <- fortify(roads)

#spatial object roads - add unique id to each feature 
roads$id<-0:(length(roads)-1)

#join attribute table using the 'id' column. 
roads_df <- merge(roads_df,roads@data,by = "id")

#plot roads using ggplot
ggplot(data = roads_df,aes(long,lat,group=group))+
  geom_path()+
  theme_bw()
#different color for different road types
ggplot(data = roads_df,aes(long,lat,group=group,color=factor(RTTYP)))+
  geom_path()+
  theme_bw()

#user defined color scheme; a color palette of 4 colors - one for each road type
road_palette <- c("U" = "green",
                  "M" = "grey40",
                  "S" = "purple",
                  "I" = "red")

ggplot(data = roads_df,aes(long,lat,group=group,color=factor(RTTYP)))+
  scale_colour_manual(values = road_palette)+
  geom_path()+
  theme_bw()



#ggsn is a library adding North Symbols and Scale Bars for Maps Created with 'ggplot2' 
library(ggsn)
ggplot(data = roads_df,aes(long,lat,group=group,color=factor(RTTYP)))+
  geom_path()+
  labs(title='Roads',x='',y='',color='Road Type')+
  north(roads_df, location = "topright", symbol = 15)+
  scalebar(roads_df, dist = 4, dist_unit = "km",transform = FALSE, model = "WGS84") +
  theme(axis.text = element_blank(), axis.ticks = element_blank())


#Selected commonly used methods for choosing univariate class intervals for mapping or other graphics purposes.
library(classInt)


##plot variable using "jenks" breaks
pophu<-readOGR('.',layer='censusdata')
pophu_df <- fortify(pophu)

pophu$id<-0:(length(pophu)-1)
#generate breaks based on Jenks method
num_class <- classIntervals(pophu$POP10, n = 7, style = "jenks")
#polygons assigned to various groups
pophu$popgroup<-cut(pophu$POP10,unique(num_class$brks),include.lowest=T)

#join attribute table using the 'id' column. 
pophu_df <- merge(pophu_df,pophu@data,by = "id")
ggplot(data = pophu_df,aes(long,lat))+
  geom_polygon(aes(fill = popgroup, group = group))+
  scale_fill_brewer(palette = "Greens") 

#export as a tiff with user-defined resolution 
tiff("Plot1.tif", compression ="lzw",width = 10, height = 6, units = 'in', res =600)
ggplot(data = pophu_df,aes(long,lat))+
  geom_polygon(aes(fill = popgroup, group = group))+
  scale_fill_brewer(palette = "Greens") 
dev.off()


#mapping raster data

library(rasterVis)
dem<-raster('dem.tif')
gplot(dem) + 
  geom_tile(aes(fill = value)) +
  scale_fill_gradientn(colours = rev(terrain.colors(225))) +
  labs(x='',y='')


#overlay two layers
s<-readOGR('.',layer='stream')
s_df <- fortify(s)
gplot(dem) + 
  geom_tile(aes(fill = value)) +
  scale_fill_gradientn(colours = rev(terrain.colors(225))) +
  labs(x='',y='')+
  geom_path(data=s_df,aes(long,lat,group=group))+
    north(s_df, location = "topright", symbol = 15)+
    scalebar(s_df, dist = 4, dist_unit = "km",transform = FALSE, model = "WGS84") +
    theme(axis.text = element_blank(), axis.ticks = element_blank())+
  coord_equal()
  



