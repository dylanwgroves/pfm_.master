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

# Load Data --------------------------------------------------------------------
ne_sample <- readOGR(dsn = "Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/03_final_data/ne_sample_villages.shp")  
uzi_sample <- readOGR(dsn = "Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/03_final_data/uzi_sample_villages.shp")  
as_sample <- readOGR(dsn = "Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/03_final_data/as_sample_villages.shp")  
as2_sample <- readOGR(dsn = "Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/03_final_data/as2_sample_final.shp")

# Set colors -------------------------------------------------------------------
col_uzi <- "#007AC1"
col_as <- "#002D62"
col_as2 <- "#EF3B24"
col_ne <- "#FFC72C" 

# Start-up map -----------------------------------------------------------------
map_main <- ggmap(get_googlemap(center = c(lon = 38.8482, lat = -5.2),
                                zoom = 9, scale = 2, color = "bw")) +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank())

# Selection --------------------------------------------------------------------

## All areas 
map_areas <- map_main + 
  geom_polygon(data=ne_sample, aes(x=long, y=lat, group=group), fill=col_ne, size=.2, color=col_ne, alpha=0.5) +
  geom_polygon(data=uzi_sample, aes(x=long, y=lat, group=group), fill=col_uzi, size=.2, color= col_uzi, alpha=0.5) +
  geom_polygon(data=as_sample, aes(x=long, y=lat, group=group), fill=col_as, size=.2, color= col_as, alpha=0.5) +
  geom_polygon(data=as2_sample, aes(x=long, y=lat, group=group), fill=col_as2, size=.2, color= col_as2, alpha=0.5)
ggsave("Dropbox/(*) Beatrice/Research/Agenda/pfm_all_map.png", 
       plot = map_areas, width = 12, height = 8, units = "in") 

## AS2
map_areas_as2 <- map_main + 
  geom_polygon(data=as2_sample, aes(x=long, y=lat, group=group), fill=col_as2, size=.2, color= col_as2, alpha=0.5)
ggsave("Dropbox/Apps/Overleaf/Tanzania - Audio Screening (bodabora)/02_Figures/pfm_as2_map.png", 
       plot = map_areas_as2, width = 12, height = 8, units = "in")



# BM maps ----------------------------------------------------------------------

col_pi_em      <-  "#008080"
col_pi_gbvenv  <-  "#C54B8C"

## Pluralistic Ignorance EM Experiment: AS1 + NE 
map_areas_pi_em <- map_main + 
  geom_polygon(data=as_sample, aes(x=long, y=lat, group=group), fill=col_pi_em, size=.2, color= col_pi_em, alpha=0.5) +
  geom_polygon(data=ne_sample, aes(x=long, y=lat, group=group), fill=col_pi_em, size=.2, color=col_pi_em, alpha=0.5) 
ggsave("Dropbox/Apps/Overleaf/BM - Pluralistic Ignorance/Figures/2025/map_pi_em.png", 
       plot = map_areas_pi_em, width = 12, height = 8, units = "in")

## Pluralistic Ignorance GBV / ENV Experiment: AS2 + CM 
map_areas_pi_gbvenv <- map_main + 
  geom_polygon(data=as2_sample, aes(x=long, y=lat, group=group), fill=col_pi_gbvenv, size=.2, color= col_pi_gbvenv, alpha=0.5) +
  geom_polygon(data=uzi_sample, aes(x=long, y=lat, group=group), fill=col_pi_gbvenv, size=.2, color= col_pi_gbvenv, alpha=0.5) 
ggsave("Dropbox/Apps/Overleaf/BM - Pluralistic Ignorance/Figures/2025/map_pi_gbvenv.png", 
       plot = map_areas_pi_gbvenv, width = 12, height = 8, units = "in")

## Pluralistic Ignorance everything
map_areas_pi_gbvenv <- map_main + 
  geom_polygon(data=as_sample, aes(x=long, y=lat, group=group), fill=col_pi_em, size=.2, color= col_pi_em, alpha=0.5) +
  geom_polygon(data=ne_sample, aes(x=long, y=lat, group=group), fill=col_pi_em, size=.2, color=col_pi_em, alpha=0.5) +
  geom_polygon(data=as2_sample, aes(x=long, y=lat, group=group), fill=col_pi_gbvenv, size=.2, color= col_pi_gbvenv, alpha=0.5) +
  geom_polygon(data=uzi_sample, aes(x=long, y=lat, group=group), fill=col_pi_gbvenv, size=.2, color= col_pi_gbvenv, alpha=0.5) 
ggsave("Dropbox/Apps/Overleaf/BM - Pluralistic Ignorance/Figures/2025/map_pi_all.png", 
       plot = map_areas_pi_gbvenv, width = 12, height = 8, units = "in")



## Socialization: AS1 + AS2
map_areas_socialization <- map_main + 
  geom_polygon(data=as_sample, aes(x=long, y=lat, group=group), fill=col_as, size=.2, color= col_as, alpha=0.5) +
  geom_polygon(data=as2_sample, aes(x=long, y=lat, group=group), fill=col_as, size=.2, color= col_as, alpha=0.5)
ggsave("Dropbox/Apps/Overleaf/BM - Socialization/00_tabfig/map_soc.png", 
       plot = map_areas_socialization, width = 12, height = 8, units = "in")



