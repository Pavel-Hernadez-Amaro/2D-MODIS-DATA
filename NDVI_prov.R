# remotes::install_github("wmgeolab/rgeoboundaries")
# install.packages("sf")
## install.packages("climaemet")
# install.packages(c("leaflet", "shiny","shinydashboard","shinyFiles",
#                    "shinyalert", "rappdirs","shinyjs",
#                    "leafem", "mapedit", "magrittr"))
# install.packages("climaemet", repos = c("https://ropenspain.r-universe.dev", "https://cloud.r-project.org"))

library(remotes)
library(mapSpain)
library(MODIStsp)
library(rgeoboundaries)
library(sf)
library(raster)
library(here)
library(ggplot2)
library(viridis)
library(rgdal)
library(climaemet)

## Get api key from AEMET
########### browseURL("https://opendata.aemet.es/centrodedescargas/obtencionAPIKey")

## Use this function to register your API Key temporarly or permanently
######### aemet_api_key("eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJwYWhlcm5hbkBlc3QtZWNvbi51YzNtLmVzIiwianRpIjoiYzBlNzhiYjAtM2IzZi00OWEzLTg5M2MtOTAyZGQwMjEwMjg1IiwiaXNzIjoiQUVNRVQiLCJpYXQiOjE3MTAwNzkyMjgsInVzZXJJZCI6ImMwZTc4YmIwLTNiM2YtNDlhMy04OTNjLTkwMmRkMDIxMDI4NSIsInJvbGUiOiIifQ.EhVa2vrRSA04yJI2tTumLWdVl2MwVwma6ooBQHKEDlk",install = TRUE)

aux=aemet_stations()

prov=c("BARCELONA","GIRONA", "LLEIDA","TARRAGONA")

id_prov=lapply(prov, function(x) aux$indicativo[which(aux$provincia==x)])

id_prov=unlist(id_prov)


# # Get Spain's province boundaries
# spain_provinces <- geoboundaries(country = "ESP", adm_lvl = "2")
# 
# # spain_provinces=esp_get_prov()
# 
# # Specify the output file path
# output_file <- "C:/Users/user/Desktop/Trabajo/Escuela/Doctorado/Pavel/Tesis/2do paper/codigo/Paper 2 Classification/MODIS/Spain provinces/spain_provinces.shp"
# 
# # Write the shapefile
# sf::st_write(spain_provinces, output_file,append = FALSE)
# 
# # Check if the shapefile was successfully created
# file.exists(output_file)

# Load shapefile for Spain provinces
# spain_provinces <- read_sf("C:/Users/user/Desktop/Trabajo/Escuela/Doctorado/Pavel/Tesis/2do paper/codigo/Paper 2 Classification/MODIS/Spain provinces/spain_provinces.shp")
spain_provinces <- st_read("C:/Users/user/Desktop/Trabajo/Escuela/Doctorado/Pavel/Tesis/2do paper/codigo/Paper 2 Classification/MODIS/Spain provinces/spain_provinces.shp")

# Run MODIStsp with specified options
MODIStsp(gui = FALSE,
         out_folder = "C:/Users/user/Desktop/Trabajo/Escuela/Doctorado/Pavel/Tesis/2do paper/codigo/Paper 2 Classification/MODIS/Spain provinces",  # Specify your desired output folder
         selprod = "Vegetation_Indexes_Monthly_1Km (M*D13A3)",
         bandsel = "NDVI",
         user = "Pavel_Hernandez_Amaro",
         password = "*967Bapu967*",
         start_date = "2022.01.01",
         end_date = "2022.12.31",
         verbose = TRUE,
         spatmeth = "file",
         spafile = "C:/Users/user/Desktop/Trabajo/Escuela/Doctorado/Pavel/Tesis/2do paper/codigo/Paper 2 Classification/MODIS/Spain provinces/spain_provinces.shp",
         out_format = "GTiff")

# Read 12 NDVI raster files
ndvi_files <- list.files(path = "C:/Users/user/Desktop/Trabajo/Escuela/Doctorado/Pavel/Tesis/2do paper/codigo/Paper 2 Classification/MODIS/Spain provinces/MODIStsp/spain_provinces/VI_Monthly_1Km_v61/NDVI", pattern = "\\.tif$", full.names = TRUE)
ndvi_stack <- stack(ndvi_files)

ndvi_points <- rasterToPoints(ndvi_stack, spatial = TRUE)

# Convert ndvi_points to an sf object
ndvi_sf <- st_as_sf(ndvi_points)

spain_provinces <- st_transform(spain_provinces, crs = crs(ndvi_sf))


# ndvi_points_with_provinces <- st_join(ndvi_sf, spain_provinces)


ndvi_sf <- st_transform(ndvi_sf, crs = crs(map_boundary))
ndvi_points_with_provinces <- st_join(ndvi_sf, map_boundary)
ndvi_df <- as.data.frame(ndvi_points_with_provinces)

# Perform intersection
intersected_data <- st_intersection(ndvi_sf, map_boundary)


NDVI_raster <- raster(here::here("C:/Users/user/Desktop/Trabajo/Escuela/Doctorado/Pavel/Tesis/2do paper/codigo/Paper 2 Classification/MODIS/VegetationData/spain/VI_Monthly_1Km_v61/NDVI/.tif"))

# # Perform spatial intersection
# intersected_data <- st_intersection(catalonia_municipalities_2, NDVI_raster)
