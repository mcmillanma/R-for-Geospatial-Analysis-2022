library(mapview)
library(rgdal)
library(htmlwidgets)


wui1 <- readOGR(dsn = ".", layer = "wui1")
wui2 <- readOGR(dsn = ".", layer = "wui2")
wui3 <- readOGR(dsn = ".", layer = "wui3")
wui4 <- readOGR(dsn = ".", layer = "wui4")
wui5 <- readOGR(dsn = ".", layer = "wui5")
wui6 <- readOGR(dsn = ".", layer = "wui6")
wui7 <- readOGR(dsn = ".", layer = "wui7")
wui8 <- readOGR(dsn = ".", layer = "wui8")
wui9 <- readOGR(dsn = ".", layer = "wui9")
wui10 <- readOGR(dsn = ".", layer = "wui10")

map <- mapview(wui1) +mapview(wui2)+mapview(wui3) +mapview(wui4) +mapview(wui5) + mapview(wui6) +mapview(wui7) +mapview(wui8) +mapview(wui9) +mapview(wui10)

map

