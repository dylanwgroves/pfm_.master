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
ne_sample <- read.csv("/Volumes/Secomba/BeatriceMontano/Boxcryptor/Box Sync/08_PanganiFM/PanganiFM/2 - Data and Analysis/2 - Final Data/genmatch sample_2018.02.17_west.csv")
as_sample <- read.dta13("/Users/BeatriceMontano/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Audio Screening/01 Data/pfm2_randomized_vills.dta")

vills <- readOGR(dsn = "/Users/BeatriceMontano/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/01_raw_data/02_publicdata/01_GIS/01_villages/Tanzania/TZvillages.shp")

# clean shapefiles for ggmap --------------------------------------------
#sp_vills <- spTransform(vills, CRS("+proj=longlat +datum=WGS84 +units=km"))
sp.projarea <- vills[vills@data$Region_Nam == "Tanga",]

df.ne_IDsample <- ne_sample$OBJECTID

# export lat and long for ne sample
sp.ne_vills <- sp.projarea[sp.projarea@data$OBJECTID %in% df.ne_IDsample,]
sp.ne_vills@data$id <- rownames(sp.ne_vills@data)
sp.ne_vills@data <- join(sp.ne_vills@data, ne_sample, by="OBJECTID")
df.ne_vills <- fortify(sp.ne_vills)
df.ne_vills <- join(df.ne_vills,sp.ne_vills@data, by="id")
write.csv(df.ne_vills, "/Users/BeatriceMontano/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/02_mid_data/ne_sample_villages_latlong.csv")


# NE sample
sp.ne_villstreat <- sp.projarea[sp.projarea@data$OBJECTID %in% df.ne_IDsample[ne_sample$v.treat == 1],]
df.ne_villstreat <- fortify(sp.ne_villstreat)
sp.ne_villscontrol <- sp.projarea[sp.projarea@data$OBJECTID %in% df.ne_IDsample[ne_sample$v.treat == 0],]
df.ne_villscontrol <- fortify(sp.ne_villscontrol)


# AS sample
merge <- merge(projarea, as_sample, by.x = c("District_N", "Ward_Name", "Vil_Mtaa_N"), by.y = c("district_n", "ward_n", "village_n"))
merge <- merge[!is.na(merge$region_n),]
as_sample_treat <- merge[merge$treat==1,]
as_sample_treat <- fortify(sp.as_sample_treat)
as_sample_control <- merge[merge$treat==0,]
as_sample_control <- fortify(sp.as_sample_control)

# Set colors ---------------------------------------------------------------
col_as_T <- "#007AC1"
col_as_C <- "#002D62"
col_ne_T <- "#FDBB30"
col_ne_C <- "#EF3B24"

# Map ---------------------------------------------------------------------
map <- ggmap(get_googlemap(center = c(lon = 38.8482, lat = -5.2),
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

map_treatment_areas <- map + 
  geom_polygon(data=ne_villstreat, aes(x=long, y=lat, group=group), fill=col_ne_T, size=.2, color="orangered4", alpha=0.5) +
  geom_polygon(data=ne_villscontrol, aes(x=long, y=lat, group=group), fill=col_ne_C, size=.2, color="orangered4", alpha=0.5) + 
  geom_polygon(data=as_sample_treat, aes(x=long, y=lat, group=group), fill=col_as_T, size=.2, color=col_as_T, alpha=0.5) +
  geom_polygon(data=as_sample_control, aes(x=long, y=lat, group=group), fill=col_as_C, size=.2, color=col_as_T, alpha=0.5) 
ggsave("/Users/BeatriceMontano/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/02_outputs/pfm_sample_map_treatment_areas.png", 
       plot = map_treatment_areas, width = 12, height = 8, units = "in")





