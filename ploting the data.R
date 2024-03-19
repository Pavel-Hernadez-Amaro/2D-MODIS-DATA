library(MODIStsp)
# library(rgeoboundaries)
library(sf)
library(raster)
library(here)
library(tidyverse)
library(viridis)
# library(rgdal)
library(mapSpain)


map_boundary <- esp_get_prov(
  # region = "Madrid"
  # region = "Santa Cruz de Tenerife",
  # comarca = "Isla de la Palma"
  # comarca = "sierra"
  # comarca = "Guadarrama"
  # comarca = "Vegas"
  # comarca = "Campiña"
  # comarca = "Area Metropolitana de Madrid"
  # comarca = "Sur Occidental"
)


ggplot(map_boundary) +
  geom_sf() +
  labs(title = map_boundary$name) +
  theme_bw()

# Reading in the downloaded NDVI raster data
all_tiff <- list.files("C:/Users/user/Desktop/Trabajo/Escuela/Doctorado/Pavel/Tesis/2do paper/codigo/Paper 2 Classification/MODIS/VegetationData/spain/VI_16Days_1Km_v61/NDVI/")

NDVI_raster <- raster(here::here(paste0("C:/Users/user/Desktop/Trabajo/Escuela/Doctorado/Pavel/Tesis/2do paper/codigo/Paper 2 Classification/MODIS/VegetationData/spain/VI_16Days_1Km_v61/NDVI/", all_tiff[1])))

NDVI_raster <- projectRaster(NDVI_raster, crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

# Cropping the data
NDVI_raster <- raster::mask(NDVI_raster, as_Spatial(map_boundary))

# Dividing values by 10000 to have NDVI values between -1 and 1
gain(NDVI_raster) <- 0.0001

# Converting the raster object into a dataframe
NDVI_df <- as.data.frame(NDVI_raster, xy = TRUE, na.rm = TRUE)
rownames(NDVI_df) <- c()


ggplot() +
  geom_tile(
    data = NDVI_df,
    aes_string(x = "x", y = "y", fill = colnames(NDVI_df)[3])
  ) +
  geom_sf(data = map_boundary, inherit.aes = FALSE, fill = NA) +
  # scale_fill_viridis(name = "NDVI", limits = c(-1, 1)) +
  scale_fill_gradientn(
    name = "NDVI",
    colors = terrain.colors(5, rev = T),
    limits = c(-1, 1)
  ) +
  labs(
    title = paste("NDVI", map_boundary$name), 
    subtitle = str_remove(string = a_file, 
                          pattern = ".Rds"),
    x = "Longitude",
    y = "Latitude"
  ) +
  theme_bw()
