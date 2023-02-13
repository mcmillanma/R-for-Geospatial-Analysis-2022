library(rnoaa)
library(sf)
library(dplyr)
library(mapview)

stations <- ghcnd_stations()

# filter by state
PA_station<-stations %>% filter(state == "PA")


# filter by element
station_PRCP<- PA_station %>% filter(element == "PRCP")

ll<-data.frame(id=station_PRCP$id,long=station_PRCP$longitude,lat=station_PRCP$latitude)
points <- ll %>% st_as_sf(coords = c("long", "lat"), crs=4326)
mapview(points)

#get prcp data (first station only for now)
alldata <-ghcnd_search(points$id[1], var = "PRCP", date_min = "2010-01-01", refresh = T)

#get annual prcp?
