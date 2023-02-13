library(raster)
library(rgdal)
#install.packages("caret")
#library(caret)
#install.packages("randomForest")
library("randomForest")
start_time <- Sys.time()


filelist <- list.files(".", pattern = "*.tif$")
landsat <- stack(filelist)

plot(landsat)

#Import trainingsamples polygon and landsat image using readOGR() and raster() 
#function, respectively. Note landsat.tif includes 6 spectral bands or layers. 
training_poly<-readOGR(dsn='.',layer = 'trainingsamples')
summary(training_poly)

#read Band1 as template
B_template<-raster("b5.tif")
#plot(B_template)
#training_poly<-spTransform(training_p, crs(B_template))

library(mapview)
mapview(training_poly)


#Through this step, all polygons will be converted to raster pixels and land 
#cover classes are represented as different pixel values. 

t_raster <- rasterize(training_poly, B_template, field = training_poly$classid)
plot(t_raster)


#Step3: Read the 6band landsat image (landsat.tif) using brick() function. 
#Note this function will read all six bands and assign them to a single rasterbrick object. 

landsat<-brick('landsat.tif')
#Attach the rasterlayer containing training data; addLayer() function here. 
#Now we have a 7-band rasterbrick object, alldata
alldata<-addLayer(landsat,t_raster)
plot(alldata)

#Step4. Convert the alldata rasterbrick object to a big dataframe and add column names. 

alldata_df<-as.data.frame(alldata)
cols = c("band1","band2","band3","band4","band5","band6","y")
colnames(alldata_df)<-cols

dim(alldata_df)
summary(alldata_df) 

#Note that the y variable including all pixels from the t_raster. 
#In the t_raster layer, training polygons were rasterized as 1,2,3,4,5,and 6 
#depending on their classid. All other pixels have NA values. So we can use 
#this layer (or column) to separate training pixels vs. non-training pixels.

alltraining <- na.omit(alldata_df)
dim(alltraining) #small subset compared to dim(alldata_df) (3105 vs 594022 pixels)
plot(alltraining [,3], alltraining [,4])

rftree = randomForest(as.factor(y) ~. , data = alltraining)
#rftree
rftree.pred = predict(rftree, alldata_df)
#rftree.pred
#length(rftree.pred) #594022
output = setValues(B_template, rftree.pred)

# Lab questions:
plot(output)

writeRaster(output, filename = "landcover2.tif", format = "GTiff", overwrite = TRUE)

freq(output)
#pixels are 30mx30m so (900 x count)/ 1,000,000 gives you square kilometer

nir <- raster("b5.tif")
red <- raster("b4.tif")
ndvi <- (nir - red)/(nir+red)
plot(ndvi)
