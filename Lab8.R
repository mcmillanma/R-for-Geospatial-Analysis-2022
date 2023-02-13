library(raster)
library(rgdal)

watersheds <- readOGR(".", layer = "watersheds") #if in folder put "./inputdata" first
watersheds$HUC8
watershed_p <- spTransform(watersheds, crs(nlcd))
nlcd <- raster("nlcd2001.tif")
dem <- raster("dem.tif")

for(i in 1:length(watersheds)){
  newdir <- paste0("/Users/melaniemcmillan/Desktop/VT Classes/R for Geospatial/Lab8/w", watersheds$HUC8[i])
  dir.create(newdir)
  watershed_sub <-watershed_p[i,]
  #crop nlcd
  nlcdsub <- crop(nlcd, watershed_sub)
  nlcdsub <-mask(nlcdsub, watershed_sub)
  demsub <-crop(dem, watershed_sub)
  demsub <-crop(demsub, watershed_sub)

  outputfilenames <- paste0(newdir, '/nlcdsub.tif')
  writeRaster(nlcdsub, outputfilenames)
  
  outputfilenames <- paste0(newdir, '/demsub.tif')
  writeRaster(demsub, outputfilenames)
}

#PPT
library(prism)
get_prism_dailys( type = "ppt", minDate = "2021-01-01", maxDate = "2021-01-31", keepZip = FALSE )

setwd('/Users/melaniemcmillan/Desktop/VT Classes/R for Geospatial/Lab8/ppt')
files <- prism_archive_ls()
ppt <- pd_stack(files)

library(rgeos)
centroids = gCentroid(watersheds, byid = TRUE)
ppt_value <- extract(ppt, centroids)
output_name <- paste('/Users/melaniemcmillan/Desktop/VT Classes/R for Geospatial/Lab8')

#tmin
get_prism_dailys( type = "tmin", minDate = "2021-01-01", maxDate = "2021-01-31", 
                  keepZip = FALSE )

setwd('/Users/melaniemcmillan/Desktop/VT Classes/R for Geospatial/Lab8/tmin')
files <- prism_archive_ls()
tmin <- pd_stack(files)

centroids = gCentroid(watersheds, byid = TRUE)
tmin_value <- extract(tmin, centroids)
output_name <- paste('/Users/melaniemcmillan/Desktop/VT Classes/R for Geospatial/Lab8')

#tmax
get_prism_dailys( type = "tmax", minDate = "2021-01-01", maxDate = "2021-01-31", 
                  keepZip = FALSE )

setwd('/Users/melaniemcmillan/Desktop/VT Classes/R for Geospatial/Lab8/tmax')
files <- prism_archive_ls()
tmax <- pd_stack(files)

centroids = gCentroid(watersheds, byid = TRUE)
tmax_value <- extract(tmax, centroids)
output_name <- paste('/Users/melaniemcmillan/Desktop/VT Classes/R for Geospatial/Lab8')


#Read watershed shapefile
#watershed <- readOGR('.', layer = 'watersheds')
centroids = gCentroid(watersheds, byid= TRUE)

tmax_value <- extract(tmax, centroids)
tmin_value <- extract(tmin, centroids)
ppt_value <- extract(ppt, centroids)

for (i in 1:length(watershed)){
  tmin1 <-tmin[i,]
  output_name <- paste('/Users/melaniemcmillan/Desktop/VT Classes/R for Geospatial/Lab8/w', 
                       watershed$HUC8,'/tmin.csv', sep = '')
  write.csv(tmin1, output_name, row.names = F)
  
  tmax1 <-tmax[i,]
  output_name <- paste('/Users/melaniemcmillan/Desktop/VT Classes/R for Geospatial/Lab8/w', 
                       watershed$HUC8,'/tmax.csv', sep = '')
  write.csv(tmax1, output_name, row.names = F)
  
  tmintmax <- cbind(tmin1, tmax1)
}

