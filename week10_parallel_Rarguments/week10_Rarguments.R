library(rgdal)
library(raster)

args <- commandArgs(trailingOnly = TRUE)
slope_t<-as.numeric(args[1])

dem<-raster('elev.tif')
slope<-terrain(dem,opt='slope',unit='degrees')
slope[slope<=slope_t]<-0
slope[slope!=0]<-1
writeRaster(slope,'slope.tif',overwrite=T)