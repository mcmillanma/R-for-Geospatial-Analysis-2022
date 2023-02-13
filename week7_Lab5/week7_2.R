##http://tester01.dfci.harvard.edu/dsbook/smoothing.html
library(tidyverse)
et<-read.csv('et.csv')
plot(et$day,et$et)

#Bin smoothing
fit <- with(et,ksmooth(day, et, kernel = "box", bandwidth = 40)) # larger bandwidth = smoother curve
plot(et$day,et$et)
lines(fit$x,fit$y)

#test different bandwidth?
fit <- with(et,ksmooth(day, et, kernel = "normal", bandwidth = 20))
plot(et$day,et$et)
lines(fit$x,fit$y)


#npreg: Nonparametric Regression via Smoothing Splines -Helwig (2020)
library(npreg)
et<-read.csv('et.csv')
plot(et$day,et$et)



#fit a smoothing splines 
mod.ss <- ss(et$day,et$et)
#predict ET for each day
et_fit<-predict.ss(mod.ss,1:365)
plot(et$day,et$et)
lines(et_fit$x,et_fit$y)

f_to_c <- function(temp_F)
{
  temp_C <- (temp_F - 32) * 5 / 9
  return(temp_C)

}

f_to_c(50)

library(raster)
library(rgdal)
library(dplyr)

p_forest <-function(usgsid)
{
  a<- raster(usgs_id)
  forestpixel <- length(a[a >= 41 & a <= 43])
  allpixel <- length(a[a >= 11])
  return(forestpixel / allpixel)
}

source('./myfunction.R')

p_forest('usgs_02022500.tif')
p_forest('usgs_02053800.tif')
