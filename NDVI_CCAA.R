library(MODIStsp)
# library(rgeoboundaries)
library(sf)
library(raster)
library(here)
library(tidyverse)
library(viridis)
# library(rgdal)
library(mapSpain)

# dir_name <- "La_Palma/"
# dir_name <- "Santa Cruz de Tenerife/"
dir_name <- "Madrid/"
# dir_name <- "Vegas_Mad/"
# dir_name <- "Guadarrama/"

dir.create(dir_name)

# # Downloading the boundary of Mongolia
# map_boundary <- esp_get_prov()


map_boundary <- esp_get_munic(
  region = "Cataluña",
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


for (a_file in all_tiff) {
  
  NDVI_raster <- raster(here::here(paste0("C:/Users/user/Desktop/Trabajo/Escuela/Doctorado/Pavel/Tesis/2do paper/codigo/Paper 2 Classification/MODIS/VegetationData/spain/VI_16Days_1Km_v61/NDVI/", a_file)))
  
  NDVI_raster <- projectRaster(NDVI_raster, crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
  
  # Cropping the data
  NDVI_raster <- raster::mask(NDVI_raster, as_Spatial(map_boundary))
  
  # Dividing values by 10000 to have NDVI values between -1 and 1
  gain(NDVI_raster) <- 0.0001
  
  # Converting the raster object into a dataframe
  NDVI_df <- as.data.frame(NDVI_raster, xy = TRUE, na.rm = TRUE)
  rownames(NDVI_df) <- c()
  
  saveRDS(object = NDVI_df, file = paste0(dir_name, 
                                          str_replace(a_file, 
                                                      pattern = ".tif", 
                                                      replacement = ".Rds")))
  
}

# NDVI_raster <- raster(here::here("VegetationData/spain/VI_Monthly_1Km_v6/NDVI/MYD13A3_NDVI_2021_335.tif"))
# 
# # Transforming the data
# NDVI_raster <- projectRaster(NDVI_raster, crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
# 
# # Cropping the data
# NDVI_raster <- raster::mask(NDVI_raster, as_Spatial(map_boundary))
# 
# # Dividing values by 10000 to have NDVI values between -1 and 1
# gain(NDVI_raster) <- 0.0001
# 
# # Converting the raster object into a dataframe
# NDVI_df <- as.data.frame(NDVI_raster, xy = TRUE, na.rm = TRUE)
# rownames(NDVI_df) <- c()


# Visualising using ggplot2
all_rds <- list.files(dir_name)

for (a_file in all_rds) {
  
  NDVI_df <- readRDS(paste0(dir_name, a_file))
  
  p <- ggplot() +
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
  
  # print(p)
  
  ggsave(p, filename = paste0(dir_name, 
                              str_replace(string = a_file, 
                                          pattern = ".Rds",
                                          replacement = ".png")),
        width = 7, height = 7)
  
}



