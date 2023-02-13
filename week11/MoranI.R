#slightly revised code
#from http://www.geo.hunter.cuny.edu/~ssun/R-Spatial/spregression.html#spatial-autocorrelation
library(rgdal)
library(sf)
library(mapview)
library(ggplot2)

#spdep: Spatial Dependence
library("spdep")

nycDat<-st_read('NYC_Tract_ACS2008_12.shp')
st_crs(nycDat) <- 4326;

mapview(nycDat,z='popunemplo')

#generate neighboring relationships and then spdep::nb2listw turns them into weights
nycNbList <- nycDat %>% spdep::poly2nb(c('cartodb_id')) %>%
  spdep::nb2listw(zero.policy = TRUE) 
#run moran test 
nycNbList %>%
  spdep::moran.test(nycDat$UNEMP_RATE, ., zero.policy = TRUE)
#evaluate moran plot
spdep::moran.plot(nycDat$UNEMP_RATE, 
                  nycNbList, 
                  zero.policy = TRUE, 
                  xlab = 'Unemployment Rate at Census',
                  ylab = 'Lagged Unemployment Rate (of Neighbors)',
                  pch=20)

#LISA
lisaRslt <- spdep::localmoran(nycDat$UNEMP_RATE, nycNbList, 
                              zero.policy = TRUE, na.action = na.omit)

# Now we can derive the clusterfor each spatial feature in the data
significanceLevel <- 0.05; # 95% confidence
meanVal <- mean(nycDat$UNEMP_RATE);

lisaRslt %<>% tibble::as_tibble() %>%
  magrittr::set_colnames(c("Ii","E.Ii","Var.Ii","Z.Ii","Pr(z > 0)")) %>%
  dplyr::mutate(coType = dplyr::case_when(
    `Pr(z > 0)` > 0.05 ~ "Insignificant",
    `Pr(z > 0)` <= 0.05 & Ii >= 0 & nycDat$UNEMP_RATE >= meanVal ~ "HH",
    `Pr(z > 0)` <= 0.05 & Ii >= 0 & nycDat$UNEMP_RATE < meanVal ~ "LL",
    `Pr(z > 0)` <= 0.05 & Ii < 0 & nycDat$UNEMP_RATE >= meanVal ~ "HL",
    `Pr(z > 0)` <= 0.05 & Ii < 0 & nycDat$UNEMP_RATE < meanVal ~ "LH"
  ))

# Now add this coType to original sf data
nycDat$coType <- lisaRslt$coType %>% tidyr::replace_na("Insignificant")

ggplot(nycDat) +
  geom_sf(aes(fill=coType),color = 'lightgrey') +
  scale_fill_manual(values = c('red','brown','NA','blue','cyan'), name='Clusters & \nOutliers') +
  labs(title = "Unemployment Rate at Census Tract Level")

#mapview(nycDat,z='coType')


#spatial regression
# Prepare data: covert some factors to numeric values
nycDat %<>% dplyr::mutate(medianage = medianage %>% as.character() %>% as.numeric(),
                          househol_1 = househol_1 %>% as.character() %>% as.numeric())

# Create a simple linear regression on unemployed population
olsRslt <- lm(log(popunemplo +1) ~ log(1+popinlabou) +
                log(1+onlylessth) + log(1+master) + 
                log(1+africaninl) + log(1+asianinlab) + 
                log(1+hispanicin),
              data = nycDat)
summary(olsRslt)

# Derive the residuals from the regression. Need to handle those missed values
lmResiduals <- rep(0, length(nycDat$popunemplo))
resIndex <- olsRslt$residuals %>% names() %>% as.integer();
lmResiduals[resIndex] <- olsRslt$residuals

# Test if there is spatial autocorrelation in the regression residuals (errors).
nycNbList %>%
  spdep::moran.test(lmResiduals, ., zero.policy = TRUE)


# use spdep package to run the spatial error model 
# Use spatialreg::errorsarlm to run the same model
install.packages('spatialreg')
library(spatialreg)
serrRslt <- spatialreg::errorsarlm(log(popunemplo +1) ~ log(1+popinlabou) +
                                     log(1+onlylessth) + log(1+master) + 
                                     log(1+africaninl) + log(1+asianinlab) + 
                                     log(1+hispanicin),
                                   data = nycDat,
                                   listw = nycNbList,
                                   zero.policy = TRUE, 
                                   na.action = na.omit);

summary(serrRslt)
