#-------------------------------------------#
# Pangani FM  - Sample Plotting             #
#-------------------------------------------#

# Libraries ---------------------------------------------------------------

pacman::p_load(data.table,
               dismos,
               plyr,
               dplyr,
               geojsonio,
               ggmap,
               ggrepel,
               ggplot2,
               lubridate,
               rgeos,
               rgdal,
               RColorBrewer,
               sf,
               sp,
               spData,
               tidyverse,
               foreign,
               readstata13)


# Clear -------------------------------------------------------------------
rm(list=ls())

#Set your API Key ---------------------------------------------------------
ggmap::register_google(key = "AIzaSyAzh5EMvmLELIQXvFJhbmD9pCD4vM_XPXA")

# Working Directory -------------------------------------------------------
#setwd("X:/")
setwd("~/")

# Load Data ---------------------------------------------------------------
ne_sample <- readOGR(dsn = "Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/03_final_data/ne_sample_villages.shp")  
uzi_sample <- readOGR(dsn = "Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/03_final_data/uzi_sample_villages.shp")  
as_sample <- readOGR(dsn = "Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/03_final_data/as_sample_villages.shp")  
as2_sample <- readOGR(dsn = "Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/03_final_data/as2_sample_final.shp")

# Set colors ---------------------------------------------------------------
col_uzi <- "#007AC1"
col_as <- "#002D62"
col_as2 <- "#EF3B24"
col_ne <- "#FFC72C" 

# Map ---------------------------------------------------------------------
map_main <- ggmap(get_googlemap(center = c(lon = 38.8482, lat = -5.2),
                                zoom = 9, scale = 2, color = "bw")) +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank())

## Uzikwasa 
map_areas <- map_main + 
  geom_polygon(data=ne_sample, aes(x=long, y=lat, group=group), fill=col_ne, size=.2, color=col_ne, alpha=0.5) +
  geom_polygon(data=uzi_sample, aes(x=long, y=lat, group=group), fill=col_uzi, size=.2, color= col_uzi, alpha=0.5) +
  geom_polygon(data=as_sample, aes(x=long, y=lat, group=group), fill=col_as, size=.2, color= col_as, alpha=0.5) +
  geom_polygon(data=as2_sample, aes(x=long, y=lat, group=group), fill=col_as2, size=.2, color= col_as2, alpha=0.5)
  

## AS1+AS2
map_areas_as1as2 <- map_main + 
  geom_polygon(data=as_sample, aes(x=long, y=lat, group=group), fill=col_as, size=.2, color= col_as, alpha=0.5) +
  geom_polygon(data=as2_sample, aes(x=long, y=lat, group=group), fill=col_as2, size=.2, color= col_as2, alpha=0.5)
ggsave("Dropbox/Apps/Overleaf/BM - Socialization/00_tabfig/pfm_as1as2_map.png", 
       plot = map_areas_as1as2, width = 12, height = 8, units = "in")

map_areas_socialization <- map_main + 
  geom_polygon(data=as_sample, aes(x=long, y=lat, group=group), fill=col_as, size=.2, color= col_as, alpha=0.5) +
  geom_polygon(data=as2_sample, aes(x=long, y=lat, group=group), fill=col_as, size=.2, color= col_as, alpha=0.5)
ggsave("Dropbox/Apps/Overleaf/BM - Socialization/00_tabfig/pfm_soc_map.png", 
       plot = map_areas_socialization, width = 12, height = 8, units = "in")



