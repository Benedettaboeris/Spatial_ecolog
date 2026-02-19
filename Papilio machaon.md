# Spatial patterns of occurrence of Papilio machaon in relation to altitude in Italy
Author: Benedetta Boeris


## Research question
Do occurrence patterns of Papilio machaon show a preference for specific altitudinal ranges?
## Introduction 
<img width="257" height="196" alt="image" src="https://github.com/user-attachments/assets/27794e64-127a-4ee8-8ce8-7ee2a3adb8b5" />

Understanding species’ spatial distributions is a central goal of spatial ecology, as it helps reveal patterns
associated with environmental gradients and ecological preferences. Papilio machaon is a widely
distributed butterfly in Europe, occurring across a broad range of habitats and elevations. Italy,
characterized by strong altitudinal and climatic heterogeneity, provides an ideal context for exploring how species occurrences vary across space and along elevation gradients. 
In this project, the spatial distribution and altitudinal patterns of P. machaon across Italy are examined using occurrence records from the Global Biodiversity Information Facility (GBIF) and elevation data derived from a digital elevation model (DEM).
Spatial mapping and kernel density estimation are used to identify geographic patterns and areas of higher occurrence density, while elevation extraction allows the assessment of altitudinal distributions.
## Data sources
Species occurrence data for Papilio machaon were obtained from the Global Biodiversity Information Facility (GBIF).

Elevation data were derived from the WorldClim digital elevation model.

Administrative boundaries for Italy were obtained from the Natural Earth dataset.

## R packages used
```
library(rgbif) #Downloading species occurrence data from GBIF
library(sf) #Handling and manipulating vector spatial data (simple features)
library(rnaturalearth) #Downloading country boundaries and other natural Earth vector data
library(ggplot2) #Creating publication-quality plots and maps
library(viridis) #Provided color scales designed to be read by everyone, including color blind people.
library(dplyr) #Data manipulation (selecting variables, filtering, piping)
library(terra) #Working with raster data and performing spatial analyses
library(spatstat) #Spatial point pattern analysis
```
## Data acquisition and Study area
Occurrence records of Papilio machaon with geographic coordinates were retrieved from GBIF for Italy and converted into a spatial (sf) object using the WGS84 coordinate system.
The boundary of Italy was obtained from the Natural Earth database and used as the study area for spatial analyses.
```
#Download occurrence data from GBIF
occ_data <- occ_search(scientificName = "Papilio machaon", country = "IT", hasCoordinate = TRUE)
#Convert the occurrence data into a standard data frame
occ_df <- data.frame(occ_data$data)
#Select only the longitude and latitude columns for spatial analysis
occ_df <- occ_df %>% select(decimalLongitude, decimalLatitude)
#Convert the data frame into a spatial object (sf) with WGS84 coordinates
occ_sf <- st_as_sf(occ_df, coords = c("decimalLongitude", "decimalLatitude"), crs = 4326)

#Download Italy's country boundary from the Natural Earth dataset
italy <- ne_countries(country = "Italy", scale = "medium", returnclass = "sf")

```
## Kernel Density Estimation
A kernel density analysis was performed on the unique occurrence points of Papilio machaon within Italy to identify areas of higher concentration.
The resulting density raster was clipped to the Italian boundary, converted to a data frame, and visualized as a heatmap.
```
#Define the study window for the density analysis using the bounding box of Italy
it_owin <- as.owin(st_bbox(italy))
#Extract the coordinates of the occurrence points
coords <- st_coordinates(occ_sf)
#Remove duplicated coordinates to avoid overcounting points
coords_unique <- unique(coords)
#Create a point pattern object (ppp) for spatial analysis
pontos <- ppp(x = coords_unique[,1], y = coords_unique[,2], window = it_owin)
#Compute the kernel density estimation of the point pattern
densidade <- density(pontos, sigma = 0.5) 
#Convert the density result into a raster object 
dens_rast <- rast(as.im(densidade))
#Assign the coordinate reference system (WGS84) to the raster
crs(dens_rast) <- "EPSG:4326"
#Convert the sf object to a terra SpatVector for raster masking operations
italy_vect <- vect(italy)
#Clip the density raster to the boundary of Italy
dens_rast_clipped <- mask(dens_rast, italy_vect)
#Convert the raster to a data frame for plotting
dens_final <- as.data.frame(dens_rast_clipped, xy = TRUE, na.rm = TRUE)
colnames(dens_final) <- c("X", "Y", "densidade")

#Plot the density map
ggplot() +
  geom_sf(data = italy, fill = "grey95", color = "grey80") +
  geom_tile(data = dens_final, aes(x = X, y = Y, fill = densidade), alpha = 0.9) + 
  scale_fill_viridis_c(option = "magma", direction = -1) +
  coord_sf() +
  theme_minimal() +
  labs(
    title = "Spatial density of Papilio machaon",
    x = "Longitude", y = "Latitude",
    fill = "Density"
  )

```
<img width="1012" height="550" alt="Rplot27" src="https://github.com/user-attachments/assets/78abab7d-ff13-4ad8-8e0f-61209a3bbdcf" />

## Spatial and Elevational Analysis
Species occurrences of Papilio machaon in Italy were first mapped to visualize their spatial distribution.
Each point was coloured according to elevation, allowing an initial assessment of altitudinal patterns across the study area.
```
#Load the elevation raster (DEM) from WorldClim
elev_raster <- rast("C:\\Users\\Asus\\Downloads\\wc2.1_10m_elev.tif")
#Crop the elevation raster to the extent of Italy
elev_italy <- crop(elev_raster, italy_vect)%>% mask(italy_vect)
#Extract elevation values for each occurrence point
extract_val <- extract(elev_italy, vect(occ_sf))
#Add the extracted elevation values to the spatial points data frame
occ_sf$elev_m <- extract_val[, 2]
#Remove points without elevation data
occ_sf <- occ_sf[!is.na(occ_sf$elev_m), ]

#Plot occurrence points colored by elevation
ggplot() +
  geom_sf(data = italy, fill = "grey90", color = "darkgrey") + # Italy boundary
  geom_sf(data = occ_sf, aes(color = elev_m), size = 1.3, alpha = 0.8) + 
  scale_color_viridis_c(option = "magma", name = "Elevation (m)") +
  theme_minimal() +
  labs(
    title = "Distribution of Papilio machaon in relation to elevation in Italy",
    subtitle = "Occurrence data from GBIF and elevation data from WorldClim (DEM)",
    x = "Longitude",
    y = "Latitude"
  )

```
<img width="1012" height="550" alt="Rplot new" src="https://github.com/user-attachments/assets/b19eabbe-295a-4387-8813-19a1b8014134" />


## Elevational Distribution
To better understand the altitudinal preferences of Papilio machaon, elevation values were plotted as a histogram,
highlighting the frequency of occurrences across different elevation ranges.

```
#Convert sf spatial object to data frame for plotting
occ_df_clean <- st_drop_geometry(occ_sf)

#Histogram of elevational distribution of occurrences
ggplot(occ_df_clean, aes(x = elev_m)) +
  geom_histogram(binwidth = 100, fill = "pink", color = "black") +
  theme_minimal() +
  labs(title = "Altitudinal distribution of Papilio machaon in Italy",
       x = "Elevation (m)", y = "Number of occurrences")

```
<img width="1012" height="550" alt="hist" src="https://github.com/user-attachments/assets/3fb29a81-e62f-4227-9547-a4e34c0af9e1" />

## Result and Discussion
The spatial distribution of Papilio machaon in Italy shows clear patterns across the country. The kernel density map highlights areas with higher concentrations of occurrences,
showing where the species has been most frequently recorded, without reference to elevation. The occurrence point map then adds an elevation layer, showing that most points are located
in low to medium elevation areas, while very few occurrences are found at high altitudes. The histogram of altitudinal distribution confirms this trend, with the majority of records clustered 
at lower elevations and gradually decreasing at higher elevations. It is important to note that this pattern may partly reflect a sampling bias, as observers are more likely to record sightings at lower and more accessible elevations.
Overall, these three analyses provide a descriptive overview of the species’ spatial and altitudinal distribution: P. machaon 
is predominantly observed in low- to mid-elevation areas, while high-altitude regions have very few occurrences. Combining density mapping, occurrence mapping, and altitudinal analysis allows for 
a clear visualization of distribution patterns across Italy.

## Conclusion
This study shows that Papilio machaon in Italy is most commonly recorded at low to medium elevations, with few occurrences at high altitudes. The density map highlights areas with higher numbers of occurrences, 
providing a descriptive overview of where the species is most frequently observed.











