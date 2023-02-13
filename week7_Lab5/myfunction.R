p_forest <- function(usgs_id){
  a<-raster(usgs_id)
  lc_freq<-data.frame(freq(a,useNA='no'))
  u<-lc_freq %>% filter(value>=41&value<=43)
  forest_per<-sum(u$count)/sum(lc_freq$count)
  return(forest_per) 
}
