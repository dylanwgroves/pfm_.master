#-------------------------------------------#
# Pangani FM  - Sample Plotting             #
#-------------------------------------------#

# Libraries ---------------------------------------------------------------

  library(data.table)
  library(dismo)
  library(plyr)      
  library(dplyr)
  library(geojsonio)
  library(ggmap)
  library(ggrepel)
  library(ggplot2)
  library(lubridate)
  library(rgeos)
  library(rgdal)
  library(RColorBrewer)
  library(sf)
  library(sp)
  library(spData)
  library(tidyverse)
  library(foreign)
  library(readstata13)

# Clear -------------------------------------------------------------------

  rm(list=ls())


#Set your API Key ---------------------------------------------------------
  ggmap::register_google(key = "")


# Load Data ---------------------------------------------------------------
  
  sp.ne_sample <- readOGR(dsn = "X:/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/03_final_data/ne_sample_villages.shp")
  sp.ne_sample@data$sample <- "ne"
  df.ne_sample <- read.csv("X:/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/02_mid_data/ne_sample_villages_latlong.csv")
  
  sp.uzi_sample <- readOGR(dsn = "X:/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/03_final_data/uzi_sample_villages.shp")
  sp.uzi_sample@data$sample <- "uzi"
  df.uzi_sample <- read.csv("X:/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/02_mid_data/uzi_sample_villages_latlong.csv")
  
  sp.as_sample <- readOGR(dsn = "X:/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/03_final_data/as_sample_villages.shp")
  sp.as_sample@data$sample <- "as"  
  df.as_sample <- read.csv("X:/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/02_mid_data/as_sample_villages_latlong.csv")
  
  sp.bbc_sample <- readOGR(dsn = "X:/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - BBC/bbc_tanga_mediamapping.shp")
  
  sp.vills <- readOGR(dsn = "X:/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/03_final_data/villages_tanga.shp")
  df.vills <- fortify(sp.vills)

  sp.roads <- readOGR(dsn = "X:/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/01_raw_data/02_publicdata/01_GIS/02_roads/TZroads.shp")
  sp.towns <- readOGR(dsn = "X:/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/01_raw_data/02_publicdata/01_GIS/03_openmap/gis.osm_places_free_1.shp")


# Set CRS -----------------------------------------------------------------

  longlatcrs <- CRS("+init=epsg:4326 +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")

  sp.roads <- spTransform(sp.roads, longlatcrs)
  sp.towns <- spTransform(sp.towns, longlatcrs)
  sp.vills <- spTransform(sp.vills, longlatcrs)
  sp.ne_sample <- spTransform(sp.ne_sample, longlatcrs)
  sp.uzi_sample <- spTransform(sp.uzi_sample, longlatcrs)
  sp.as_sample <- spTransform(sp.as_sample, longlatcrs)
  
  
# Roads -------------------------------------------------------------------

  # sp.roads <- sp.roads[sp.roads@data$RTT_DESCRI == "Primary Route" | 
  #                  sp.roads@data$RTT_DESCRI == "Secondary Route",]
  sp.roads_tanga <- sp.roads[sp.vills,]
  
  

# Villages ----------------------------------------------------------------

  sp.towns <- sp.towns[sp.towns@data$fclass == "city"	| 
                         sp.towns@data$fclass == "town",]
  sp.towns_tanga <- sp.towns[sp.vills,]
  

# Pangani -----------------------------------------------------------------

  sp.pangani <- sp.towns_tanga[sp.towns_tanga@data$name == "Pangani",]

  
# Remove Townships --------------------------------------------------------

  sp.sample <- sp.vills[sp.vills$District_N != 'Handeni Township Authority',]
  sp.sample <- sp.sample[sp.sample$District_N != 'Korogwe Township Authority',]
  
  
# Remove Existing Samples -------------------------------------------------
  
  sp.sample <- sp.sample - sp.as_sample
  sp.sample <- sp.sample - sp.ne_sample
  sp.sample <- sp.sample - sp.uzi_sample
  #sp.sample <- sp.sample - sp.bbc_sample



# Remove Roads ------------------------------------------------------------

  sp.sample@data$dist_road <- 100*apply(gDistance(sp.sample, sp.roads_tanga, byid=TRUE), 2, min)
  sp.sample <- sp.sample[sp.sample@data$dist_road > 0,]  
  
  sp.sample@data$dist_towns <- 100*apply(gDistance(sp.sample, sp.towns_tanga, byid=TRUE), 2, min)
  sp.sample <- sp.sample[sp.sample@data$dist_towns > 7,]    


# Remove Pangani ----------------------------------------------------------

  sp.sample@data$dist_pangani <- 100*apply(gDistance(sp.sample, sp.pangani, byid=TRUE), 2, min)
  sp.sample <- sp.sample[sp.sample@data$dist_road > 70,]    

# Export ------------------------------------------------------------------

  writeOGR(sp.sample, 
           layer = "main",
           "X:/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/03_final_data/as2_sample.shp",
           driver="ESRI Shapefile", overwrite_layer=TRUE)


