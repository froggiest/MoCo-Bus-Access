# libraries and datasets
library(tidyverse)
# Residential buildings with census tracts:
residentialhomes_censustracts <- read_csv("homes_with_tracts.csv")
# Residential buildings: Bus routes (RideOn + Metrobus)
residential_halfmile_route <- read_csv("halfmile_from_bus_route.csv") # half mile from a bus route
residential_quartermile_route <- read_csv("quartermile_from_bus_route.csv") # quarte rmile from a bus route
# Residential buildings: Bus stops (RideOn + Metrobus)
residential_halfmile_stop <- read_csv("halfmile_from_bus_stop.csv") # quarter mile from a bus stop
residential_quartermile_stop <- read_csv("quartermile_from_bus_stop.csv") # half mile from a bus stop

# remove columns that cause "problems"
residentialhomes_censustracts <- residentialhomes_censustracts %>% select(-CLERK_PLAT)
residential_halfmile_route <- residential_halfmile_route %>% select(-CONDO_UNIT, -CLERK_PLAT)
residential_quartermile_route <- residential_quartermile_route %>% select(-CONDO_UNIT, -CLERK_PLAT)
residential_quartermile_stop <- residential_quartermile_stop %>% select(-CONDO_UNIT, -CLERK_PLAT)
residential_halfmile_stop <- residential_halfmile_stop %>% select(-CONDO_UNIT, -CLERK_PLAT)


# cleaning before joining

acctsummary <- residentialhomes_censustracts %>% 
  group_by(ACCT) %>% 
  summarise(count = n()) %>% 
  filter(count > 1)
# I'm going to join by this column, and there are 13 duplicate rows within it out of 250,000 total rows, so I will remove their duplicates to avoid any possible join issues  
residentialhomes_censustracts <- residentialhomes_censustracts %>% 
  distinct(ACCT, .keep_all = TRUE)
residential_halfmile_route <- residential_halfmile_route %>% 
  distinct(ACCT, .keep_all = TRUE)
residential_quartermile_route <- residential_quartermile_route %>% 
  distinct(ACCT, .keep_all = TRUE)
residential_quartermile_stop <- residential_quartermile_stop %>% 
  distinct(ACCT, .keep_all = TRUE)
residential_halfmile_stop <- residential_halfmile_stop %>% 
  distinct(ACCT, .keep_all = TRUE)

# homes + census tracts

# the census tract datasets are separated into 4 subsets - bus route/stop in 1/2 mile and bus route/stop in 1/4 mile. I want to join them together into one while still indicating distance to stop and route.

residentialhomes_censustracts_dist <- residentialhomes_censustracts %>% 
  select(-PARCEL_NO) # causes problems later

# routes
residential_halfmile_route_dist <- residential_halfmile_route %>% 
  mutate(
    halfmile_route = 1
  ) %>% 
  select(-PARCEL_NO)
residential_quartermile_route_dist <- residential_quartermile_route %>% 
  mutate(
    quartermile_route = 1
  ) %>% 
  select(-PARCEL_NO)

# stops
residential_halfmile_stop_dist <- residential_halfmile_stop %>% 
  mutate(
    halfmile_stop = 1
  ) %>% 
  select(-PARCEL_NO)
residential_quartermile_stop_dist <- residential_quartermile_stop %>% 
  mutate(
    quartermile_stop = 1
  ) %>% 
  select(-PARCEL_NO)

# start joining the distance columns to the main dataframe and filling in new blank rows with NA

residential <- left_join(residentialhomes_censustracts_dist, 
                         residential_halfmile_route_dist %>% select(ACCT, halfmile_route))
# replace NA with 0 in the new, blank columns:
residential$halfmile_route[is.na(residential$halfmile_route)] <- 0
# join again
residential_qr <- left_join(residential, residential_quartermile_route_dist %>% 
                              select(ACCT, quartermile_route))
# replace NA with 0
residential_qr$quartermile_route[is.na(residential_qr$quartermile_route)] <- 0
# join again
residential_qr_hs <- left_join(residential_qr, residential_halfmile_stop_dist %>% 
                                 select(ACCT, halfmile_stop))
residential_qr_hs$halfmile_stop[is.na(residential_qr_hs$halfmile_stop)] <- 0
# join again
residential_qr_hs_qs <- left_join(residential_qr_hs, residential_quartermile_stop_dist %>% 
                                    select(ACCT, quartermile_stop))
residential_qr_hs_qs$quartermile_stop[is.na(residential_qr_hs_qs$quartermile_stop)] <- 0

residential_qr_hs_qs <- residential_qr_hs_qs %>% 
  rename_at("GEOIDFQ",~"Geography")


# make sure everything is correct by checking sums against subset lengths
nrow(residential_halfmile_route)
sum(residential_qr_hs_qs$halfmile_route)

nrow(residential_halfmile_stop)
sum(residential_qr_hs_qs$halfmile_stop)

nrow(residential_quartermile_route)
sum(residential_qr_hs_qs$quartermile_route)

nrow(residential_quartermile_stop)
sum(residential_qr_hs_qs$quartermile_stop)

# save as csv
# write_csv(residential_qr_hs_qs, "residentialbuildings_distances_census.csv")
