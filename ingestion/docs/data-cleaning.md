# Data cleaning overview

A lot of this project involves cleaning and formatting data and creating summaries. I created several crucial variables in ArcGIS using spatial joins, selects, and other tools.

## Cleaning and variable creation in ArcGIS

**1. Census tracts**\
I used TIGER/Line Shapefiles from 2024 census tracts in Maryland. I selected only those in Montgomery County.
- Calculated size of each tract in US survey miles\^2

**2. Bus routes and stops**\
I used the Ride On GTFS files with the GTFS Shapes to Features geoprocessing tool to map bus lines; GTFS Stops to Features to map bus stops
- Selected Metrobus lines and stops (from shapefiles) that intersect with Montgomery County; joined these to bus lines and bus stops from Ride On
- Joined bus routes to census tracts using a one-to-many spatial join

**3. Residential buildings**\
I selected residential buildings from the property polygons dataset using the first 16 land use codes from the data dictionary linked on the [data overview](https://data-mcplanning.hub.arcgis.com/datasets/MCPlanning::property-polygons-file-geodatabase/about). These were codes 111, 116, 114, 115, 118, 119, 112, 113, 117, 140, 121, 122, 123, 124, 125, and 126. As a note, this includes religious quarters, boarding houses, membership lodgings, and nursing homes.\
- Made four subsets using select by location:\
- (1) Residential homes 0.5 and (2) 0.25 **US survey miles** from a bus route\
- (3) Residential homes 0.5 and (4) 0.25 **US survey miles** from a bus stop\
- (5) Residential homes 0.5 and (6) 0.25 **US survey miles** from a Bus Rapid Transit (BRT) bus route\
- These distances do **not** account for sidewalks or obstacles. They are completely direct.\

**4. Cities**\
I used a map of Montgomery County Communities to assign cities to census tracts using select by location.\

## Cleaning in R

Many of these scripts and documents create datasets used in one another. They are listed in order. The first document creates a dataset used in the second and fourth.\

### Ride On + Metrobus departures and ridership

Note: I am not including my code for accessing the WMATA API, or the data I accessed from the API before I cleaned and summarized it. You can find this data on the [WMATA API website](https://developer.wmata.com/) by creating an account and subscribing to get an API key; the WMATA GTFS files are in the same format as Ride On GTFS, so the code is exactly the same, with one adjustment: `service_id` codes are different for Metrobus. **I used the `service_id` for Monday, Tuesday, and Thursday as "weekdays".**

**1.0-bus-service-ridership.qmd**\

Data used: `rideon_stop_times.txt`, `rideon_trips.txt`, `rideon_routes.txt`, `rideon_calendar.txt`, `Feb2026RideOnAvgDailyRidership.csv`, `Feb26WMATAAvgDailyRidership.csv`, and `wmata_all_calendar_trips.csv` (not included in GitHub repository)\

This document creates a summary of departures and ridership for both Metrobus and RideOn\
- Mutated Ride On GTFS files to create a summary of departures per day (weekday, Saturday, Sunday) per route\
- Created a summary of ridership per day; joined to GTFS summary\

Dataset created: `metrobus_rideon_all_trips_calendar_schedule.csv`\

### Initial data cleaning

**1.0-data-cleaning.qmd**\

Data used: `HouseholdSizeVehicles.csv`, `NumberOfWorkersVehicles.csv`, `DemographicsHousing.csv` , `metrobus_rideon_all_trips_calendar_schedule.csv`, `MetroandRideOnRoutes_CensusTracts.csv`, `MontgomeryCounty_Cities_Tracts.csv`, `census_tracts_square_miles.csv`\

This notebook contains data cleaning to make datasets with general purposes in this project.\
- Cleaned American Community Survey (ACS) data (column names)\
- Combined bus ridership & departure summary with bus routes per census tracts to create a departure per census tract summary (number of buses passing through daily), as well as mean daily riders for all routes intersecting with the tract\
- Created a dataset of the square miles and cities that each census tract represents (combined and slightly cleaned)\

Datasets created: `all_american_community_survey.csv`, `mocobuses_all_trips_calendar_schedule.csv`, `buses_by_city.csv`, `censusandcitysize.csv`, `censustract_buses_ridership_calendar.csv`\

### Residential homes

**1.0-clean-residential-homes.R**\

Data used: `homes_with_tracts.csv`, `halfmile_from_bus_route.csv`, `quartermile_from_bus_route.csv`, `quartermile_from_bus_stop.csv`, `halfmile_from_bus_stop.csv`\

This script joins the subsets of residential buildings 0.5 and 0.25 miles from existing bus route/stops made in ArcGIS, to create variables usable in R for analysis.\
- Cleaned datasets of residential buildings (subsets at different distances) to be able to incorporate into one dataset\
- Used subsets to create binary variables in the overall residential buildings dataset, indicating if each building is 1/2, 1/4, miles from a stop or a route\
- Accomplished this by joining binary columns from subsets to the overall dataset and filling empty rows with 0\

Dataset created: `residentialbuildings_distances_census.csv` (not included in GitHub repository; `residentialbuilidings_BRT_distance_census_tracts.csv` from BRT cleaning is instead, it is the same dataset but with several more columns)\

### BRT distances and summary

**1.5-data-cleaning-BRT.qmd**\

Data used: `BRT_stops_all_with_census_tracts.csv`, `halfmile_from_planned_brt_stop.csv`, `quartermile_from_planned_brt_stop.csv`, `residentialbuildings_distances_census.csv`\

This document does the same thing as the script for residential buildings and existing bus routes, and more\
- Created binary variables for distance from BRT stops in the updated all residential buildings dataset\
- Created summary of BRT stops in each census tract\
- Created variable for number of BRT stops in each tract\

Datasets created: `residentialbuilidings_BRT_distance_census_tracts.csv`, `brt_stop_statistics.csv`

### Analysis data cleaning

**2.0-data-cleaning-for-analysis.qmd**\

Data used: `censustract_buses_ridership_calendar.csv`, `all_american_community_survey.csv`, `residentialbuilidings_BRT_distance_census_tracts.csv`, `censusandcitysize.csv`, `brt_stop_statistics.csv`, `tracts_with_sqmiles_land_near_bus_stops.csv`, `bus_stops_in_tracts.csv`

This notebook contains data cleaning to make datasets with specific purposes in analysis.\
- Created variables for number and proportion of residential buildings and dwellings (homes & units) in each tract, for the total numbers, and various distances to routes and stops\
- Created a ridership and departure summary for total number and average riders of routes and departures per tract for different days\
- Created variables for total number and proportion of households with different characteristics based on ACS estimates; more people than vehicles, more workers than vehicles, 0 vehicles, etc\
- Added BRT variables\

Dataset created: `bus_tracts_acs_summary.csv`, `final_bus_access_dataset_simple.csv`\
# Data cleaning overview

A lot of this project involves cleaning and formatting data and creating summaries. I created several crucial variables in ArcGIS using spatial joins, selects, and other tools.

## Cleaning and variable creation in ArcGIS

**1. Census tracts**\
I used TIGER/Line Shapefiles from 2024 census tracts in Maryland. I selected only those in Montgomery County.\
- Calculated size of each tract in US survey miles\^2\

**2. Bus routes and stops**\
I used the RideOn GTFS files with the GTFS Shapes to Features geoprocessing tool to map bus lines; GTFS Stops to Features to map bus stops\
- Selected Metrobus lines (from shapefile) that intersect with Montgomery County; joined these to bus lines and bus stops from RideOn\
- Joined bus routes to census tracts using a one-to-many spatial join\

**3. Residential buildings**\
I selected residential buildings from the property polygons dataset using the first 16 land use codes from the data dictionary linked on the [data overview](https://data-mcplanning.hub.arcgis.com/datasets/MCPlanning::property-polygons-file-geodatabase/about). These were codes 111, 116, 114, 115, 118, 119, 112, 113, 117, 140, 121, 122, 123, 124, 125, and 126. As a note, this includes religious quarters, boarding houses, membership lodgings, and nursing homes.\
- Made four subsets using select by location:\
- (1) Residential homes 0.5 and (2) 0.25 **US survey miles** from a bus route\
- (3) Residential homes 0.5 and (4) 0.25 **US survey miles** from a bus stop\
- (5) Residential homes 0.5 and (6) 0.25 **US survey miles** from a Bus Rapid Transit (BRT) bus route\

**4. Cities**\
I used a map of Montgomery County Communities to assign cities to census tracts. This was mostly for reference while working with data in R.\

## Cleaning in R

Many of these scripts and documents create datasets used in one another. They are listed in order; the first document creates a dataset used in the second and fourth.\

### RideOn + Metrobus departures and ridership

Note: I am not including my code for accessing the WMATA API, or the data I accessed from the API before I cleaned and summarized it. You can find this data on the [WMATA API website](https://developer.wmata.com/) by creating an account and subscribing to get an API key; the WMATA GTFS files are in the same format as RideOn GTFS, so the code is exactly the same (with one adjustment: `service_id` codes are different for Metrobus. I used the `service_id` for Monday, Tuesday, and Thursday for weekdays).

**1.0-bus-service-ridership.qmd**\

Data used: `rideon_stop_times.txt`, `rideon_trips.txt`, `rideon_routes.txt`, `rideon_calendar.txt`, `Feb2026RideOnAvgDailyRidership.csv`, `Feb26WMATAAvgDailyRidership.csv`, and `wmata_all_calendar_trips.csv` (not included in GitHub repository)\

This document creates a summary of departures and ridership for both Metrobus and RideOn\
- Mutated RideOn GTFS files to create a summary of departures per day (weekday, Saturday, Sunday) per route\
- Created a summary of ridership per day; joined to GTFS summary\

Dataset created: `metrobus_rideon_all_trips_calendar_schedule.csv`\

### Initial data cleaning

**1.0-data-cleaning.qmd**\

Data used: `metrobus_rideon_all_trips_calendar_schedule.csv`, `HouseholdSizeVehicles.csv`, `NumberOfWorkersVehicles.csv`, `DemographicsHousing.csv` , `MetroandRideOnRoutes_CensusTracts.csv`, `MontgomeryCounty_Cities_Tracts.csv`, `census_tracts_square_miles.csv`\

This notebook contains data cleaning to make datasets with general purposes in this project.\
- Cleaned American Community Survey (ACS) data (column names)\
- Combined bus ridership & departure summary with bus routes per census tracts to create a departure per census tract summary (number of buses passing through daily), as well as mean daily riders for all routes intersecting with the tract\
- Created a dataset of the square miles and cities that each census tract represents (combined and slightly cleaned)\

Datasets created: `censusandcitysize.csv`, `censustract_buses_ridership_calendar.csv`, `mocobuses_all_trips_calendar_schedule.csv`, `all_american_community_survey.csv`\

### Residential homes

**1.0-clean-residential-homes.R**\

Data used: `censustracts_rideonbusroutes.csv`, `residential_homes_with_census_tracts.csv`, `halfmile_to_rdmetro_ROUTE_homes.csv`, `quartermile_to_rdmetro_ROUTE_homes.csv`, `quartermile_to_rdmetro_Stop_homes.csv`, `halfmile_to_rdmetro_Stop_homes.csv`\

This script joins the subsets of residential buildings 0.5 and 0.25 miles from existing bus route/stops made in ArcGIS, to create variables usable in R for analysis.\
- Cleaned datasets of residential buildings (subsets at different distances) to be able to incorporate into one dataset\
- Used subsets to create binary variables in the overall residential buildings dataset, indicating if each building is 1/2, 1/4, miles from a stop or a route\
- Accomplished this by joining binary columns from subsets to the overall dataset and filling empty rows with 0\

Dataset created: `residentialbuildings_distances_census.csv`\

### BRT distances and summary

**1.5-data-cleaning-BRT.qmd**\

Data used: `BRT_routes_censustracts.csv`, `BRT_stops_all_with_census_tracts.csv`, `halfmile_BRT_ROUTE_homes.csv`, `quartermile_BRT_ROUTE_homes.csv`, `residentialbuildings_distances_census.csv`\

This document does the same thing as the script for residential buildings and existing bus routes, and more\
- Created binary variables for distance from BRT routes in the updated all residential buildings dataset\
- Created summary of BRT routes and stop in each census tract\
- Created variable for number of BRT routes and stops in each tract\

Datasets created: `residentialbuilidings_BRT_distance_census_tracts.csv`, `distinct_brt_stops_vs_routes.csv`, `brt_stop_route_statistics.csv`

### Analysis data cleaning

**2.0-data-cleaning-for-analysis.qmd**\

Data used: `censustract_buses_ridership_calendar.csv`, `all_american_community_survey.csv`, `residentialbuilidings_BRT_distance_census_tracts.csv`, `censusandcitysize.csv`, `brt_stop_route_statistics.csv`

This notebook contains data cleaning to make datasets with specific purposes in analysis.\
- Created variables for number and proportion of residential buildings and dwellings (homes & units) in each tract, for the total numbers, and various distances to routes and stops\
- Created a ridership and departure summary for total number and average riders of routes and departures per tract for different days\
- Created variables for total number and proportion of households with different characteristics based on ACS estimates; more people than vehicles, more workers than vehicles, 0 vehicles, etc\
- Added BRT variables\

Dataset created: `bus_tracts_acs_summary.csv`, `final_bus_access_dataset_simple.csv`\
