#-----------------------------------------#
# Pangani FM Evaluation - Village Select  #
# Author: Dylan Groves                    #
# Last updated: August 18, 2020           #
#-----------------------------------------#

#--------------------------------------------------
#  Packages
#--------------------------------------------------
ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}
packages <- c("rgeos", "rgdal", "sp", "raster", "scales", "lubridate", "gdata", "data.table", "dplyr", "Matching", "rgenoud", "stringr", "MatchIt") 
ipak(packages)

#--------------------------------------------------
# Clear and set working directory
#--------------------------------------------------
rm(list=ls())
set.seed(122)
#--------------------------------------------------
# Load Data
#--------------------------------------------------
df <- read.csv("../Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/01_raw_data/01_sample/pfm_ne_villagescoping.csv")

#--------------------------------------------------
# Dataset
#--------------------------------------------------

# Covariates
df <- df %>%
  mutate(v.treat_cel = ifelse(q2_1_mainvillage_panganifm == 1, 1,                   # Treatment variable (cell)
                        ifelse(q2_1_mainvillage_panganifm == 2, -99, 
                               ifelse(q2_1_mainvillage_panganifm == 3, 0, NA))),
         v.treat_rad = ifelse(q2_3_mainvillage_panganifm == 1, 1,                   # Portable Radio Treament (to check overlap with cell)
                              ifelse(q2_3_mainvillage_panganifm == 2, -99,
                                     ifelse(q2_1_mainvillage_panganifm == 3, 0, NA))),
         cell = ifelse(q1_3_mainvillage_cell == 1, 1, 0),                           # Cell Phone Available (Chuck says to check)
         cell_bar = q1_3_mainvillage_cell_a,
         cell_bar = ifelse(is.na(q1_3_mainvillage_cell_a), 0, cell_bar),
         traveltime = q2_5a_transport_time,
         electricity = q2_6_electricity,
         rel_muslim = ifelse(q2_7_religiosity == 1 | q2_7_religiosity == 2, 1, 0),  # Religiosity (any Muslim)
         rel_mixed = ifelse(q2_7_religiosity == 2 | q2_7_religiosity == 3, 1, 0),   # Religiosity (Mixed vs not-mixed)
         rel_noworship = ifelse(q2_8_places_worship == 4, 1, 0),                    # No places of worship
         rel_mosques = q2_8a_mosque_num,   # Total Mosques
         rel_mosques = ifelse(is.na(rel_mosques), 0, rel_mosques),
         rel_churches = ifelse(is.na(q2_8a_church_num), 0, q2_8a_church_num),       # Total Churches
         rel_totworship = rel_mosques + rel_churches,                               # Total Places of Worship
         villexec = q3_1_vilexec_found,                                             # Village Exec Found
         dem_pop = q3_4_vilexec_pop,                                                # Total Population
         dem_subvil_tot = q3_5_vilexec_subvil,                                      # Total subvillages
         poplist = q3_6_vilexec_poplist,                                            # Is there a list?
         poplist_complete = ifelse(is.na(q3_6_vilexec_poplist_qual), 0,
                                   ifelse(q3_6_vilexec_poplist_qual== 1, 1, 0)),    # Is there a complete list?
         poplist_atleast = ifelse(poplist == 1 | q3_6_vilexec_poplist_poss == 1, 1, 0), # At least possible
         subvil_reach = q4_0_subvillage_arr,  
         subvil_reach = ifelse(is.na(subvil_reach), 1, subvil_reach),# Reachable Subvillages
         subvil_cell = q4_1_subvillage_cell,
         sv.treat_cel = ifelse(q5_1_subvillage_panganifm == 1, 1,                   # Treatment variable (cell)
                               ifelse(q5_1_subvillage_panganifm == 2,-99, 
                                      ifelse(q5_1_subvillage_panganifm == 3, 0, NA))), # Subvillage treatment
         sv.treat_rad = ifelse(q5_3_subvillage_panganifm == 1, 1,                   # Portable Radio Treament (to check overlap with cell)
                              ifelse(q5_3_subvillage_panganifm == 2, -99,
                                     ifelse(q5_3_subvillage_panganifm == 3, 0, NA))))

df_uzikwasa <- df %>%
  dplyr::select(Region_Nam, Ward_Name, Vil_Mtaa_N, q1_2_geopoint.Latitude, q1_2_geopoint.Longitude, v.treat_cel, v.treat_rad, sv.treat_cel, sv.treat_rad)

#write.csv(df_uzikwasa, '2 - Final Data/2_Baseline/panganifm_total coverage_2018.04.19.csv')

# Radio Availability
df$v.rad_tot <- str_count(df$q2_2_mainvillage_otherradio, " ") + 1 + str_count(df$q5_2a_subvillage_otherradio_oth, ".")
df$sv.rad_tot <- str_count(df$q5_2_subvillage_otherradio, " ") + 1 + str_count(df$q5_4a_subvillage_otherradio_oth, ".")

#--------------------------------------------------
# Define Treatment
#--------------------------------------------------

# Define treatment as full coverage in village
df <- df %>% 
  mutate(v.treat = ifelse(v.treat_cel == 1 & v.treat_rad == 1, 1,
                          ifelse(v.treat_cel == -99 | v.treat_rad == -99, NA, 0)))
df.all <- df

df.t <- filter(df.all, v.treat == 1 | v.treat == 0)

#--------------------------------------------------
# Select Only Within East and West Boundaries of Treatment
#--------------------------------------------------

# cut_west <- min(df.t$q1_2_geopoint.Longitude[df.t$v.treat == 1])
cut_east <- max(df.t$q1_2_geopoint.Longitude[df.t$v.treat == 1])
#  
df.all <- filter(df.all, q1_2_geopoint.Longitude <= cut_east)
df.t <- filter(df.t, q1_2_geopoint.Longitude <= cut_east)

#--------------------------------------------------
# Sekhon GenMatch
#--------------------------------------------------

attach(df.t)

X <- cbind(Shape_Area, q1_2_geopoint.Longitude, q1_2_geopoint.Latitude,
           cell, cell_bar, traveltime, electricity,         
           rel_muslim, rel_mixed, rel_noworship, rel_mosques, rel_churches, rel_totworship,
           villexec, 
           dem_pop, dem_subvil_tot, poplist, subvil_reach, 
           v.rad_tot, sv.rad_tot)

test <- GenMatch(v.treat, X, BalanceMatrix=X, estimand="ATT", M=1, weights=NULL, # Run the GenMatch algorithm. Runs without replacement
         pop.size = 1000, max.generations=1000,
         wait.generations=4, hard.generation.limit=FALSE,
         starting.values=rep(1,ncol(X)),
         fit.func="pvals",
         MemoryMatrix=TRUE,
         exact=NULL, caliper=NULL, replace=FALSE, ties=TRUE,
         CommonSupport=FALSE, nboots=0, ks=TRUE, verbose=FALSE,
         distance.tolerance=1e-05,
         tolerance=sqrt(.Machine$double.eps),
         min.weight=0, max.weight=1000,
         Domains=NULL, print.level=2,
         project.path=NULL,
         paired=TRUE, loss=1,
         data.type.integer=FALSE,
         restrict=NULL,
         cluster=FALSE, balance=TRUE)

df.matches <- as.data.frame(test$matches)
colnames(df.matches) <- c("treat", "control", "weight", "treat2", "control2")

df.treat <- df.t[df.matches$treat,] # Extract treatment matches
df.treat$match <- df.matches$control # Store control match from matches DF
df.control <- df.t[df.matches$control,] # Extract control matches
df.control$match <- df.matches$treat # Store match from matches DF

df.sample <- rbind(df.treat, df.control) # Bind together treatment group and others

#write.csv(df.sample, "../Dropbox/Wellspring Tanzania Papers/wellspring_01_master/01_data/03_final_data/01_sample/pfm_ne_sample_final.csv")


