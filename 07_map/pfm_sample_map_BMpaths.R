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
ne_sample <- read.csv("/Users/BeatriceMontano/Boxcryptor/Box Sync/08_PanganiFM/PanganiFM/2 - Data and Analysis/2 - Final Data/genmatch sample_2018.02.17_west.csv")
uzi_sample <- read.csv("/Users/BeatriceMontano/Boxcryptor/Box Sync/08_PanganiFM/PanganiFM/2 - Data and Analysis/2 - Final Data/uzikwasa_survey_2021.02.23.csv")
as_sample <- read.dta13("/Users/BeatriceMontano/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Audio Screening/01 Data/pfm2_randomized_vills.dta")

vills <- readOGR(dsn = "/Users/BeatriceMontano/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/01_raw_data/02_publicdata/01_GIS/01_villages/Tanzania/TZvillages.shp")



# clean shapefiles for ggmap --------------------------------------------
#sp_vills <- spTransform(vills, CRS("+proj=longlat +datum=WGS84 +units=km"))
sp.projarea <- vills[vills@data$Region_Nam == "Tanga",]



# NE sample
df.ne_IDsample <- ne_sample$OBJECTID

sp.ne_vills <- sp.projarea[sp.projarea@data$OBJECTID %in% df.ne_IDsample,]
sp.ne_vills@data$id <- rownames(sp.ne_vills@data)
sp.ne_vills@data <- join(sp.ne_vills@data, ne_sample, by="OBJECTID")
df.ne_vills <- fortify(sp.ne_vills)
df.ne_vills <- join(df.ne_vills,sp.ne_vills@data, by="id")
write.csv(df.ne_vills, "X:/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/02_mid_data/ne_sample_villages_latlong.csv")

sp.ne_villstreat <- sp.projarea[sp.projarea@data$OBJECTID %in% df.ne_IDsample[ne_sample$v.treat == 1],]
df.ne_villstreat <- fortify(sp.ne_villstreat)
sp.ne_villscontrol <- sp.projarea[sp.projarea@data$OBJECTID %in% df.ne_IDsample[ne_sample$v.treat == 0],]
df.ne_villscontrol <- fortify(sp.ne_villscontrol)


# Uzi Sample
df.uzi_IDsample <- uzi_sample$OBJECTID

sp.uzi_vills <- sp.projarea[sp.projarea@data$OBJECTID %in% df.uzi_IDsample,]
sp.uzi_vills@data$id <- rownames(sp.uzi_vills@data)
sp.uzi_vills@data <- join(sp.uzi_vills@data, uzi_sample, by="OBJECTID")
df.uzi_vills <- fortify(sp.uzi_vills)
df.uzi_vills <- join(df.uzi_vills,sp.uzi_vills@data, by="id")
write.csv(df.uzi_vills, "X:/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/02_mid_data/uzi_sample_villages_latlong.csv")

sp.uzi_villstreat <- sp.projarea[sp.projarea@data$OBJECTID %in% df.uzi_IDsample[uzi_sample$Selection == 1],]
df.uzi_villstreat <- fortify(sp.uzi_villstreat)


# AS sample
merge <- merge(sp.projarea, as_sample, by.x = c("District_N", "Ward_Name", "Vil_Mtaa_N"), by.y = c("district_n", "ward_n", "village_n"))
merge <- merge[!is.na(merge$region_n),]
as_sample_treat <- merge[merge$treat==1,]
as_sample_treat <- fortify(as_sample_treat)
as_sample_control <- merge[merge$treat==0,]
as_sample_control <- fortify(as_sample_control)
sp.as_vills <- merge[merge$treat==1 | merge$treat==0,]
df.as_vills <- fortify(sp.as_vills)

sp.as_villstreat <- merge[merge$treat==1,]
sp.as_villscontrol <- merge[merge$treat==0,]

# Set colors ---------------------------------------------------------------

col_as_T <- "#007AC1"
col_as_C <- "#002D62"
col_ne_T <- "#EF3B24"
col_ne_C <- "#FFC72C" 
col_uzi_t <- "#1D428A"

# Map ---------------------------------------------------------------------
ggmap::register_google(key = "AIzaSyAzh5EMvmLELIQXvFJhbmD9pCD4vM_XPXA")

map_main <- ggmap(get_googlemap(center = c(lon = 38.8482, lat = -5.2),
                                zoom = 9, scale = 2, color = "bw")) +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank())



## Uzikwasa areas
map_uzi_areas <- map_main + 
  geom_polygon(data=sp.uzi_villstreat, aes(x=long, y=lat, group=group), fill="#1D428A", size=.2, color="#1D428A", alpha=0.5) +
  geom_polygon(data=sp.ne_villscontrol, aes(x=long, y=lat, group=group), fill="#FFC72C", size=.2, color="#FFC72C", alpha=0.5) +
  ylab("") +
  xlab("")

map_uzi_areas

ggsave("X:/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Uzikwasa/03_tables and figures/pfm_uzi_map.png", 
       plot = map_uzi_areas, width = 12, height = 8, units = "in")


# NE areas Treat/Control

map_main_alt <- ggmap(get_googlemap(center = c(lon = 38.65, lat = -5.1),
                                zoom = 10, scale = 2, color = "bw")) +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank())
  
map_ne_areas <- map_main_alt + 
  geom_polygon(data=sp.ne_villstreat, aes(x=long, y=lat, group=group), fill="#1D428A", size=.2, color="#1D428A", alpha=0.5) +
  geom_polygon(data=sp.ne_villscontrol, aes(x=long, y=lat, group=group), fill="#FFC72C", size=.2, color="#FFC72C", alpha=0.5) +
  ylab("") +
  xlab("")

map_ne_areas

ggsave("X:/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Uzikwasa/03_tables and figures/pfm_ne_map.png", 
       plot = map_ne_areas, width = 12, height = 8, units = "in")


# Both AS and NE villages as dots
map_asne <- map_main + 
  geom_point(data = ne_sample, colour = "dodgerblue3", aes(x = q1_2_geopoint.Longitude, y = q1_2_geopoint.Latitude)) +
  geom_point(data = as_sample, colour = "darkorange3", aes(x = longitude, y = latitude)) +
  ylab("") +
  xlab("")
ggsave("/Users/BeatriceMontano/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/02_outputs/pfm_sample_map_asne.png", 
       plot = map_asne, width = 12, height = 8, units = "in")


# Both AS and NE villages as areas
map_asne_areas <- map_main +
  geom_polygon(data=sp.ne_vills, aes(x=long, y=lat, group=group), fill="dodgerblue3", size=.2, color="dodgerblue3", alpha=0.5) +
  geom_polygon(data=sp.as_vills, aes(x=long, y=lat, group=group), fill="darkorange3", size=.2, color="darkorange3", alpha=0.5) +
  ylab("") +
  xlab("")
ggsave("/Users/BeatriceMontano/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/02_outputs/pfm_sample_map_asne_areas.png", 
         plot = map_asne_areas, width = 12, height = 8, units = "in")
  


# NE T/C and UZI 
map_treatment <- map + 
  geom_point(data = ne_sample[ne_sample$v.treat==1, ], color = col_ne_T, aes(x = q1_2_geopoint.Longitude, y = q1_2_geopoint.Latitude)) + 
  geom_point(data = ne_sample[ne_sample$v.treat==0, ], color = col_ne_C, aes(x = q1_2_geopoint.Longitude, y = q1_2_geopoint.Latitude)) + 
  geom_point(data = uzi_sample[uzi_sample$Sampled==1, ], color = col_as_T, aes(x = longitude, y = latitude)) +
  #+ theme(legend.position = c(0.95, 0.95), legend.justification = c("right", "top"))
  
  ggsave("X:/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/02_outputs/pfm_sample_map_treatment.png", 
         plot = map_treatment, width = 12, height = 8, units = "in")


# Both AS and NE villages as areas, with differences for T and C
map_asne_treat_areas <- map_main +
  geom_polygon(data=sp.ne_villstreat, aes(x=long, y=lat, group=group), fill=col_ne_T, size=.2, color=col_ne_T, alpha=0.5) +
  geom_polygon(data=sp.ne_villscontrol, aes(x=long, y=lat, group=group), fill=col_ne_C, size=.2, color=col_ne_C, alpha=0.5) +
  geom_polygon(data=sp.as_villstreat, aes(x=long, y=lat, group=group), fill=col_as_T, size=.2, color=col_as_T, alpha=0.5) +
  geom_polygon(data=sp.as_villscontrol, aes(x=long, y=lat, group=group), fill=col_as_C, size=.2, color=col_as_C, alpha=0.5) +
  ylab("") +
  xlab("")



# Not sure?
map_treatment_areas

ggsave("X:/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Uzikwasa/03_tables and figures/pfm_sample_map_treatment_areas.png", 
       plot = map_treatment_areas, width = 12, height = 8, units = "in")


+
  geom_polygon(data=sp.as_vills, aes(x=long, y=lat, group=group), fill="#FFC72C", size=.2, color="#FFC72C", alpha=0.5)


map_treatment_areas

+ 
  geom_polygon(data=as_sample_treat, aes(x=long, y=lat, group=group), fill=col_as_T, size=.2, color=col_as_T, alpha=0.5) +
  geom_polygon(data=as_sample_control, aes(x=long, y=lat, group=group), fill=col_as_C, size=.2, color=col_as_T, alpha=0.5) 

ggsave("X:/Dropbox/Wellspring Tanzania Papers/wellspring_01_master/02_outputs/pfm_sample_map_treatment_areas.png", 
       plot = map_treatment_areas, width = 12, height = 8, units = "in")



