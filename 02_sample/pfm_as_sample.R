#-------------------------------------------------
# Pangani FM Wave 2 - Village Samplig
# Dylan Groves, dgroves@poverty-action.org
# 6/26/2019 - last updated: august 19, 2020
#-------------------------------------------------

####################################################################################
#
# Introduction
#
####################################################################################

# Load Packages -----------------------------------------------------------
library(data.table)
library(dismo)
library(dplyr)
library(geojsonio)
library(ggplot2)
library(maptools)
library(rgeos)
library(rgdal)
library(sf)
library(sp)
library(spData)
library(RColorBrewer)

# Clear and Set Seed ------------------------------------------------------
rm(list=ls())
seed = 1970
set.seed(seed)

# Load Data ---------------------------------------------------------------
scoping <- read.csv("/Users/BeatriceMontano/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/01_raw_data/01_sample/pfm_ne_villagescoping.csv")
pfm1 <- read.csv("/Volumes/Secomba/BeatriceMontano/Boxcryptor/Box Sync/08_PanganiFM/PanganiFM/2 - Data and Analysis/2 - Final Data/genmatch sample_2018.02.17_west.csv")
#scoping <- read.csv("wellspring_01_master/01_data/01_raw_data/01_sample/pfm_ne_villagescoping.csv")
#pfm1 <- read.csv("wellspring_01_master/01_data/03_final_data/pfm_ne_sample_final.csv")

vills <- readOGR(dsn = "/Users/BeatriceMontano/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/01_raw_data/02_publicdata/01_GIS/01_villages/Tanzania/TZvillages.shp")
roads <- readOGR(dsn = "/Users/BeatriceMontano/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/01_raw_data/02_publicdata/01_GIS/02_roads/TZroads.shp")
towns <- readOGR(dsn = "/Users/BeatriceMontano/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/01_raw_data/02_publicdata/01_GIS/03_openmap/gis.osm_places_free_1.shp")
alti <- raster("/Users/BeatriceMontano/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/01_raw_data/02_publicdata/01_GIS/04_altitude/TZalt.grd")
#vills <- readOGR(dsn = "wellspring_01_master/01_data/01_raw_data/02_publicdata/01_GIS/01_villages/Tanzania/TZvillages.shp")
#roads <- readOGR(dsn = "wellspring_01_master/01_data/01_raw_data/02_publicdata/01_GIS/02_roads/TZroads.shp")
#towns <- readOGR(dsn = "wellspring_01_master/01_data/01_raw_data/02_publicdata/01_GIS/03_openmap/gis.osm_places_free_1.shp")
#alti <- raster("wellspring_01_master/01_data/01_raw_data/02_publicdata/01_GIS/04_altitude/TZalt.grd")

# Set CRS -----------------------------------------------------------------
longlatcrs <- CRS("+init=epsg:4326 +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")
longlatcrs <- CRS("+proj=longlat +datum=WGS84")

newcrs <- CRS("+proj=utm +zone=37 +datum=WGS84 +units=km")
vills <- spTransform(vills, CRSobj=newcrs)

roads <- spTransform(roads, newcrs)
towns <- spTransform(towns, newcrs)

####################################################################################
#
# Subset Data --------------------------------------------------------------
#
####################################################################################

# Tanga and Pangani ----------------------------------------------------------------
vills <- vills[vills@data$Region_Nam == "Tanga",]
vills_pangani <- vills[vills@data$District_N=="Pangani",]

# Dissolve Pangani -----------------------------------------------------------------
district_pangani <- gUnaryUnion(vills_pangani)

# Only Main Roads ------------------------------------------------------------------
roads <- roads[roads@data$RTT_DESCRI == "Primary Route" | 
                 roads@data$RTT_DESCRI == "Secondary Route",]
roads_tanga <- roads[vills,]

# Only Cities and Towns ------------------------------------------------------------
towns <- towns[towns@data$fclass == "city"	| 
                 towns@data$fclass == "town",]

sp.na.omit <- function(x, margin=1) {
  if (!inherits(x, "SpatialPointsDataFrame") & !inherits(x, "SpatialPolygonsDataFrame")) 
    stop("MUST BE sp SpatialPointsDataFrame OR SpatialPolygonsDataFrame CLASS OBJECT") 
  na.index <- unique(as.data.frame(which(is.na(x@data),arr.ind=TRUE))[,margin])
  if(margin == 1) {  
    cat("DELETING ROWS: ", na.index, "\n") 
    return( x[-na.index,]  ) 
  }
  if(margin == 2) {  
    cat("DELETING COLUMNS: ", na.index, "\n") 
    return( x[,-na.index]  ) 
  }
}
towns <- sp.na.omit(towns)

# Towns only inside Tanga ------------------------------------------------------------
towns <- towns[vills,]

# Pangani ----------------------------------------------------------------------------
towns_pangani <- towns[towns@data$name == "Pangani",]
towns_korogwe <- towns[towns@data$name == "Korogwe"]

# Small version for plotting
vills_small <- vills[vills$s_dist_pfm < 100,]
roads_small <- roads[vills_small,]
towns_small <- towns[vills_small,]

# Centroids ---------------------------------------------------------------
centroids <- coordinates(vills)
vills.cent <- SpatialPointsDataFrame(centroids, vills@data, proj4string = newcrs)
vills_cent_longlat <- spTransform(vills.cent, CRSobj=longlatcrs)

vills@data$latitude <- vills_cent_longlat@coords[,2]
vills@data$longitude <- vills_cent_longlat@coords[,1]

# Coastline ---------------------------------------------------------------
vills.agg <- aggregate(vills)
vills.agg.line <- as(vills.agg,"SpatialLines")
boxpoints <- c(513.3837, -725.8809, 1, 493.8926, -721.3403, 2, 469.3638, -711.0124, 3, 458.6056, -592.6717, 4, 521.6692, -515.2019, 5, 533.0526, -528.9829, 6, 513.3837, -725.8809, 7)
mymatrix <- matrix(boxpoints, nrow=7, ncol=3, byrow=T, dimnames = list(1:7,c("x", "y", "p")))
boundpoints <- data.frame(mymatrix)
coordinates(boundpoints) = ~x+y
proj4string(boundpoints) <- newcrs
boundpoly <- as(boundpoints,"SpatialLines")
coast <- crop(vills.agg.line, boundpoly)

# Altitude ----------------------------------------------------------------
alti <- as(alti, "SpatialPointsDataFrame")
alti <- spTransform(alti, newcrs)
alti <- alti[vills,]

closestSiteVec <- vector(mode = "numeric",length = nrow(vills.cent))
minDistVec <- vector(mode = "numeric",length = nrow(vills.cent))

for (i in 1 : nrow(vills)){
  distVec <- spDistsN1(alti,vills.cent[i,],longlat = FALSE)
  minDistVec[i] <- min(distVec)
  closestSiteVec[i] <- which.min(distVec)
}

PointAssignAlts <- as(alti[closestSiteVec,]$TZA_alt,"numeric")
AltsTable <- data.frame(vills@data$OBJECTID,closestSiteVec,minDistVec,PointAssignAlts)

# New Variables -----------------------------------------------------------

# Distance from Pangani
vills@data$s_dist_pfm <- apply(gDistance(vills.cent, towns_pangani,byid=TRUE),2,min)

# Distance from Paved Road
vills@data$s_dist_road <- apply(gDistance(vills, roads,byid=TRUE),2,min)
vills@data$s_dist_road_cent <- apply(gDistance(vills.cent, roads,byid=TRUE),2,min)

# Distance from Towns
vills@data$s_dist_towns <- apply(gDistance(vills.cent, towns,byid=TRUE),2,min)

# Distance from Coast
vills@data$s_dist_coast <- apply(gDistance(vills.cent, coast,byid=TRUE),2,min)

# Area
dd = dim(vills) 
  for(i in 1:dd[1]){vills@data$area[i] <- gArea(vills[i,1]) }

# Altitude
if(all.equal(vills@data$OBJECTID,AltsTable$vills.data.OBJECTID)){
  vills@data$s_alt <- AltsTable$PointAssignAlts
}

# PFM 1
vills_pfm1 <- vills
vills_pfm1 <- merge(vills_pfm1, pfm1, by=c("District_N", "Ward_Name", "Vil_Mtaa_N"), stringsAsFactors = FALSE)
vills_pfm1 <- vills_pfm1[!is.na(vills_pfm1@data$q1_3_mainvillage_cell),]

# Scoping
vills_scoping <- vills
vills_scoping <- merge(vills_scoping, scoping, by=c("District_N", "Ward_Name", "Vil_Mtaa_N"), stringsAsFactors = FALSE)
vills_scoping <- vills_scoping[!is.na(vills_scoping@data$audio_consent),]
  
# Merge New Village Center Data -----------------------------------------------------------

# This data was generated in QGIS - Martin and Dylan located village centers via map
sp_vill_cent <- readOGR(dsn = "/Users/BeatriceMontano/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/01_raw_data/01_sample/pfm_as_vill_centers.shp")
#sp_vill_cent <- readOGR(dsn = "wellspring_01_master/01_data/01_raw_data/01_sample/pfm2_vill_centers.shp")

# Transform to standard CRS
sp_vill_cent <- spTransform(sp_vill_cent, newcrs)

# Clean
sp_vill_cent@data$villcent_long <- sp_vill_cent@data$Long
sp_vill_cent@data$villcent_lat <- sp_vill_cent@data$Lat
sp_vill_cent@data$district_c <- sp_vill_cent@data$dist_c
sp_vill_cent@data$ward_c <- sp_vill_cent@data$wrd_c
sp_vill_cent@data$village_c <- sp_vill_cent@data$vill_c
sp_vill_cent@data <- sp_vill_cent@data %>% select(-path, -Long, -Lat, dist_c, wrd_c, vill_c)

# Calculate Distances
sp_vill_cent@data$vill_dist_pfm <- apply(gDistance(sp_vill_cent, towns_pangani,byid=TRUE),2,min) # Distance from Pangani
sp_vill_cent@data$vill_dist_road <- apply(gDistance(sp_vill_cent, roads,byid=TRUE),2,min) # Distance from Road
sp_vill_cent@data$vill_dist_town <- apply(gDistance(sp_vill_cent, towns,byid=TRUE),2,min) # Distance from Towns


####################################################################################
#
# Sample Selection Standard --------------------------------------------------------
#
####################################################################################

# (1) Set Parameters
dist_pangani_min <- 70
dist_roads_min <- 0
dist_towns_min <- 8

# (2) Impost Constraints
sample <- vills[vills@data$s_dist_pfm < dist_pangani_min,]
sample <- sample[sample@data$s_dist_road > dist_roads_min,]
sample <- sample[sample@data$s_dist_towns > dist_towns_min,]
sample <- sample[sample@data$District_N != "Pangani",]

# (3) Remove villages we have used previously
sample <- sample - vills_scoping

# (4) Remove Townships
sample <- sample[sample$District_N != 'Handeni Township Authority',]
sample <- sample[sample$District_N != 'Korogwe Township Authority',]

# (5) Get Rid of Villages Tagged by Hand
#  We tagged some village centers are too larger or small in QGIS
df_sample <- sample@data # Convert to dataframe

df_sample <- merge(df_sample, sp_vill_cent, by.x = c("District_C", "Ward_Code", "Vil_Mtaa_C"),
                   by.y=c("district_c", "ward_c", "village_c"), stringsAsFactors = FALSE)

df_sample <- df_sample[df_sample$reject == "0",]

####################################################################################
#
# Sample Villages Within Wards 
#
####################################################################################

# (1) Generate Random Number
df_sample$random_1 <- runif(nrow(df_sample), min = 0, max = 1)

# (2) Identify largest random number in each ward
df_sample <- df_sample %>%
  group_by(District_C, District_N, Ward_Code, Ward_Name) %>%
  mutate(rank_random1 = order(random_1, decreasing = TRUE),
         max_random1 = max(random_1),
         ward_vills = n()) %>%
  ungroup()

# (3) Drop if ward has less 1 vill
df_sample <- df_sample[df_sample$ward_vills > 1,]

# (4) Tag villages with largest two random numbers
df_sample$select <- ifelse(df_sample$rank_random1 == 1 | df_sample$rank_random1 == 2, 1, 0)
df_sample <- df_sample[df_sample$select == 1,]

# (5) Merge with spatial data
sp_sample <- sp::merge(sample, df_sample, 
                       by=c('District_C', 'District_N', 'Ward_Code', 'Ward_Name', 
                            'OBJECTID', 'Region_Cod', 'Region_Nam', 'Vil_Mtaa_C'))

# Count selected
sum(sp_sample@data$select, na.rm = T)

####################################################################################
#
# Clean Data ---------------------------------------------------
#
####################################################################################

# Rename variables to more useful terms
sp_sample@data <- sp_sample@data %>%
  mutate(district_c = District_C, district_n = District_N,
         ward_c = Ward_Code, ward_n = Ward_Name,
         region_c = Region_Cod, region_n = Region_Nam,
         village_c = Vil_Mtaa_C, village_n = Vil_Mtaa_N.x,
         length = Shape_Leng.x, 
         dist_pfm = s_dist_pfm.x,
         dist_road = s_dist_road.x,
         dist_road_cent = s_dist_road_cent.x,
         dist_town = s_dist_towns.x,
         dist_coast = s_dist_coast.x,
         latitude = latitude.x,
         longitude = longitude.x,
         area = area.x)

# Keep Only some variables
sp_sample@data <- sp_sample@data %>%
  dplyr::select(select,
         region_c, region_n,
         district_c, district_n,
         ward_c, ward_n,
         village_c, village_n,
         length, area,
         latitude, longitude,
         dist_pfm, dist_road, dist_road_cent, dist_town, dist_coast,
         vill_dist_pfm, vill_dist_road, vill_dist_town,
         villcent_long, villcent_lat,
         ward_vills,
         random_1, rank_random1, select, reject)

####################################################################################
#
# Save Sample Data --------------------------------------------------------------
#
####################################################################################

# Write SHP File
maptools::writeSpatialShape(sp_sample, "/Users/BeatriceMontano/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/02_mid_data/pfm_as_sample.shp")
#maptools::writeSpatialShape(sp_sample, "wellspring_01_master/01_data/02_mid_data/pfm_as_sample.shp")

# Write CSV
write.csv(sp_sample@data, "/Users/BeatriceMontano/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/03_final_data/01_sample/pfm_as_sample.csv")
#write.csv(sp_sample@data, "wellspring_01_master/01_data/03_final_data/01_sample/pfm_as_sample.csv)
sum(sp_sample@data$select, na.rm = T)
