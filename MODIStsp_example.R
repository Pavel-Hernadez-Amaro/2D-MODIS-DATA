# install.packages("MODIStsp")
install.packages("remotes")
library(remotes)
install_github("ropensci/MODIStsp")

library(MODIStsp)
MODIStsp_get_prodlayers("M*D13A3")


# remotes::install_github("wmgeolab/rgeoboundaries")
# install.packages("sf")
library(rgeoboundaries)
library(sf)

# Downloading the country boundary of Mongolia
map_boundary <- geoboundaries("Spain")

# bound_mat <- map_boundary[["geometry"]]

# Defining filepath to save downloaded spatial file
spatial_filepath <- "VegetationData/spain.shp"

# Saving downloaded spatial file on to our computer
st_write(map_boundary, paste0(spatial_filepath))



# MODIStsp(
#   gui = FALSE,
#   out_folder = "VegetationData",
#   out_folder_mod = "VegetationData",
#   selprod = "Vegetation_Indexes_Monthly_1Km (M*D13A3)",
#   bandsel = "NDVI",
#   user = "hahernan",
#   password = "5AB,*+u9gpYM%/$",
#   start_date = "2021.01.01",
#   end_date = "2021.12.31",
#   verbose = FALSE,
#   spatmeth = "file",
#   spafile = spatial_filepath,
#   out_format = "GTiff"
# )



# VIsualize ---------------------------------------------------------------

# remotes::install_github("wmgeolab/rgeoboundaries")
# install.packages(c("sf, "raster", "here", "ggplot2", "viridis", "rgdal"))
library(rgeoboundaries)
library(sf)
library(raster)
library(here)
library(ggplot2)
library(viridis)
library(rgdal)
# 
# # Downloading the boundary of Mongolia
map_boundary <- geoboundaries("Spain", adm_lvl = "2")

# Reading in the downloaded NDVI raster data
NDVI_raster <- raster(here::here("VegetationData/spain/VI_Monthly_1Km_v6/NDVI/MOD13A3_NDVI_2021_001.tif"))

# Transforming the data
NDVI_raster <- projectRaster(NDVI_raster, crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

# Cropping the data
NDVI_raster <- raster::mask(NDVI_raster, as_Spatial(map_boundary))

# Dividing values by 10000 to have NDVI values between -1 and 1
gain(NDVI_raster) <- 0.0001

# Converting the raster object into a dataframe
NDVI_df <- as.data.frame(NDVI_raster, xy = TRUE, na.rm = TRUE)
rownames(NDVI_df) <- c()

colnames(NDVI_df)[3]

# Visualising using ggplot2
ggplot() +
  geom_tile(
    data = NDVI_df,
    aes_string(x = "x", y = "y", fill = colnames(NDVI_df)[3])
  ) +
  geom_sf(data = map_boundary, inherit.aes = FALSE, fill = NA) +
  scale_fill_viridis(name = "NDVI") +
  labs(
    title = "NDVI (Normalized Difference Vegetation Index) in Spain",
    subtitle = "01-06-2020",
    x = "Longitude",
    y = "Latitude"
  ) +
  theme_minimal()
