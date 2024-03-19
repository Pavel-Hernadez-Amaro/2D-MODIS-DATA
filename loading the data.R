# remotes::install_github("wmgeolab/rgeoboundaries")
# install.packages("sf")

library(MODIStsp)
library(rgeoboundaries)
library(sf)
library(raster)
library(here)
library(ggplot2)
library(viridis)
library(rgdal)

# MODIStsp_get_prodlayers("M*D13Q1")

# Downloading the country boundary of Spain
map_boundary <- geoboundaries("Spain")

# Defining filepath to save downloaded spatial file
spatial_filepath <- "VegetationData/spain.shp"

# Saving downloaded spatial file on to our computer
st_write(map_boundary, paste0(spatial_filepath))

MODIStsp(
  gui = FALSE,
  out_folder = "VegetationData",
  out_folder_mod = "VegetationData",
  selprod = "Vegetation_Indexes_16Days_1Km (M*D13A2)",
  bandsel = "NDVI",
  user = "Pavel_Hernandez_Amaro",
  password = "*967Bapu967*",
  start_date = "2005.05.01",
  end_date = "2005.05.01",
  verbose = FALSE,
  spatmeth = "file",
  spafile = spatial_filepath,
  out_format = "GTiff"
)

NDVI_raster <- raster(here::here("C:/Users/user/Desktop/Trabajo/Escuela/Doctorado/Pavel/Tesis/2do paper/codigo/Paper 2 Classification/MODIS/VegetationData/spain/VI_16Days_1Km_v61/NDVI/.tif"))

# Transforming the data
NDVI_raster <- projectRaster(NDVI_raster, crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

# Cropping the data
NDVI_raster <- raster::mask(NDVI_raster, as_Spatial(map_boundary))

# Dividing values by 10000 to have NDVI values between -1 and 1
gain(NDVI_raster) <- 0.0001

# Converting the raster object into a dataframe
NDVI_df <- as.data.frame(NDVI_raster, xy = TRUE, na.rm = TRUE)
rownames(NDVI_df) <- c()

# Visualising using ggplot2
ggplot() +
  geom_raster(
    data = NDVI_df,
    aes(x = x, y = y, fill = MYD13A2_NDVI_2020_153)
  ) +
  geom_sf(data = map_boundary, inherit.aes = FALSE, fill = NA) +
  scale_fill_viridis(name = "NDVI") +
  labs(
    title = "NDVI (Normalized Difference Vegetation Index) in Mongolia",
    subtitle = "01-03-2024",
    x = "Longitude",
    y = "Latitude"
  ) +
  theme_minimal()

