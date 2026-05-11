## Statistical analysis

One of the main goals in my project was to search for measures of bus access that have a relationship with vehicle use, or rather, the proportion of households [in an area] with less vehicles than workers. After that, I wanted to look for areas with a high proportion of households with less vehicles than workers despite having a relatively low measure for "bus access".

**3.0-statistics-numbers.qmd**

Data used: `final_bus_access_dataset_simple.csv`, `censusandcitysize.csv`, `mocobuses_all_trips_calendar_schedule.csv`, `bus_tracts_acs_summary.csv`

Before examining relationships between bus service and vehicles, I went through some basic details on percentages and totals for bus access and vehicle access.

**3.0-regression-analysis.qmd**

`final_bus_access_dataset_simple.csv`, `censusandcitysize.csv`, `buses_by_city.csv`

Here, I use multiple linear regression to examine correlation and relationships between variables measuring bus access/service and the variable `propEstHouseholds_LessVehiclesThanWorkers`, the proportion of [estimated] households with less vehicles than workers. I found that there are many bus access variables that have a relationship with this variable. Some notable variables that have a positive relationship with the target are bus routes per square mile, proportion of land 1/4 mile from a bus stop, and trips per person (total trips divided by census estimated population).

Regression with census tracts produced consistently weaker models than regression with census tracts grouped into cities/communities. This makes sense; most census tracts are very small, the median size of a census tract for this data being 0.85 square miles. When looking at a variable measuring something such as trips per person for a tract of that size, there may be a very small number of trips, yet at the same time a very high proportion of workers without vehicles, because of bus trips in neighboring tracts. Looking at census tracts alone does not account for that, but grouping census tracts into the cities/communities that they overlap with does.

The multiple linear regression model for census tracts had an adjusted R\^2 of 0.3964 and a p-value of \< 2.2e-16. The equation was $\hat{prophouseholds.lessvehicles} = 0.045348 + 0.001378(routes.per.sqmile) + 0.115716(prop.land.fourthmile.stop)$

The multiple linear regression model for cities/communities had an adjusted R\^2 of 0.7089 and a p-value of 1.178e-15. The equation was $\hat{prophouseholds.lessvehicles} = 0.0175730 + 0.0180655(routes.per.sqmile) + 0.0399738(propdwell.quarterm.stop) + 0.0006801(wkday.departures.per.route)$

After creating these models, I went on to select cities/communities with high residuals. All of the predictors used in both models have a positive relationship with the target, so I found areas with a high proportion of households with less vehicles than workers yet "low bus access" according to the predictor variables. I did this using the cities/communities regression model by selecting areas with large positive residuals, or residuals over the 75th quantile. This produced these cities: Woodbine, Hillandale, Silver Spring, Redland, Brighton, Northwest Park / Oakview, Long Branch, Gaithersburg, Boyds, Germantown, Bethesda, Brookeville, Spencerville, Upper Rock Creek, and Burtonsville. These are cities that have a higher proportion of households with less vehicles than workers than the model expects based on bus access variables. This implies that these may be areas where workers might lack a personal vehicle because they cannot have one (because of finances or some other reason). These are areas where bus service expansion may be especially likely to have a positive impact on the community, and where bus service expansion might have an especially large impact on the proportion of households with less vehicles than workers.
