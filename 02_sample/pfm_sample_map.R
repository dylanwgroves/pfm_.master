#-------------------------------------------#
# Pangani FM  - Sample Plotting             #
#-------------------------------------------#

# Libraries ---------------------------------------------------------------
library(data.table)
library(dismo)
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
# Dylan
# ggmap::register_google(key = "AIzaSyAzh5EMvmLELIQXvFJhbmD9pCD4vM_XPXA")

# Bea
ggmap::register_google(key = "AIzaSyBB5SbUdwqScXZBcrHfI2EU2aQqpza4RuE")

# Load Data ---------------------------------------------------------------
ne_sample <- read.csv("/Volumes/Secomba/BeatriceMontano/Boxcryptor/Box Sync/08_PanganiFM/PanganiFM/2 - Data and Analysis/2 - Final Data/genmatch sample_2018.02.17_west.csv")
as_sample <- read.dta13("/Users/BeatriceMontano/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Audio Screening/01 Data/pfm2_randomized_vills.dta")

vills <- readOGR(dsn = "/Users/BeatriceMontano/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/01_raw_data/02_publicdata/01_GIS/01_villages/Tanzania/TZvillages.shp")

# Adjust shapefile for ggplot2 --------------------------------------------
vills <- spTransform(vills, CRS("+proj=longlat +datum=WGS84 +units=km"))
projarea <- vills[vills@data$Region_Nam == "Tanga",]

ne_IDsample <- ne_sample$OBJECTID
ne_villstreat <- projarea[projarea@data$OBJECTID %in% ne_IDsample[ne_sample$v.treat == 1],]
ne_villstreat <- fortify(ne_villstreat)
ne_villscontrol <- projarea[projarea@data$OBJECTID %in% ne_IDsample[ne_sample$v.treat == 0],]
ne_villscontrol <- fortify(ne_villscontrol)
ne_villspanganifm <- projarea[projarea@data$OBJECTID %in% ne_IDsample[ne_sample$OBJECTID == 14937 | ne_sample$OBJECTID == 14550],]
ne_villspanganifm <- fortify(ne_villspanganifm)

# add code for as_sample areas -> hinges on pfm_as_sample.r

# Set colors ---------------------------------------------------------------
col_as_T <- "#007AC1"
col_as_C <- "#002D62"
col_ne_T <- "#FDBB30"
col_ne_C <- "#EF3B24"

# Map ---------------------------------------------------------------------
map <- ggmap(get_googlemap(center = c(lon = 38.8482, lat = -5.2565),
                         zoom = 10, scale = 2,
                         maptype ='terrain',
                         color = "bw")) 

map_overall <- map + 
  geom_point(data = ne_sample, colour = "dodgerblue3", aes(x = q1_2_geopoint.Longitude, y = q1_2_geopoint.Latitude)) + 
  geom_point(data = as_sample, colour = "darkorange3", aes(x = longitude, y = latitude)) 
ggsave("/Users/BeatriceMontano/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/02_outputs/pfm_sample_map_overall.png", 
       plot = map_overall, width = 12, height = 8, units = "in")

map_treatment <- map + 
  geom_point(data = ne_sample[ne_sample$v.treat==1, ], color = col_ne_T, aes(x = q1_2_geopoint.Longitude, y = q1_2_geopoint.Latitude)) + 
  geom_point(data = ne_sample[ne_sample$v.treat==0, ], color = col_ne_C, aes(x = q1_2_geopoint.Longitude, y = q1_2_geopoint.Latitude)) + 
  geom_point(data = as_sample[as_sample$treat==1, ], color = col_as_T, aes(x = longitude, y = latitude)) +
  geom_point(data = as_sample[as_sample$treat==0, ], color = col_as_C, aes(x = longitude, y = latitude))
  #+ theme(legend.position = c(0.95, 0.95), legend.justification = c("right", "top"))
ggsave("/Users/BeatriceMontano/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/02_outputs/pfm_sample_map_treatment.png", 
       plot = map_treatment, width = 12, height = 8, units = "in")

map + 
  geom_polygon(data=ne_villstreat, aes(x=long, y=lat, group=group), fill=col_ne_T, size=.2, color=col_as_T, alpha=0.5) +
  geom_polygon(data=ne_villscontrol, aes(x=long, y=lat, group=group), fill=col_ne_C, size=.2, color=col_as_C, alpha=0.5) 




