library(rgdal)
library(raster)
library(sf)
library(dplyr)
library(mapview)

#Question 1 and 2
df <- data.frame(long= -80.429361, lat = 37.229596)
points <- df %>% st_as_sf(coords = c("long", "lat"), crs = 4326)
mapview(points)

# -or-

testpoint <- data.frame(x= -80.429361,y = 37.229596)
coordinates <- ~ x + y
proj4string(testpoint) <- "+proj + longlat +ellps =WGS84"
plot(testpoint)

# Question 3 list all files stack and extract. Set GTiff folder as wd
for (year in 2001:2017){
  wc = paste0("*A", year, "*EVI.tif")
  filelist = Sys.glob(wc)
  
  m = stack(filelist)
  mv = calc(m, fun = mean)
  
  output = paste0("modis", year, ".tif")
  print(output)
  
  writeRaster(mv, output)
}

modfil <- Sys.glob("modis*.tif")
m <- stack(modfil)
dim(m)
df <- getValues(m)
summary(df)
df_valid <- na.omit(df)

t <- 1:17
y <- df_valid[1,]
mymodel = lm(y ~ t)

#creating matrix for the output
cm <- matrix(NA, nrow = dim(df_valid)[1], 2)

#for loop to do regression on values of every pixel
for(i in 1:nrow(df_valid)){
  y = df_valid[i,]
  mymodel = lm(y ~ t)
  cm[i,1] <-  mymodel$coefficients[1]
  cm[i,2] <-  mymodel$coefficients[2]
  
  print(i)
}

plot(cm[,2])

#read in template for converting this to an image
template <- raster("modis2001.tif")
#replacing everywhere that isn't na with the slope
template[!is.na(template)] <- cm[,2]
plot(template)


# Question 4
