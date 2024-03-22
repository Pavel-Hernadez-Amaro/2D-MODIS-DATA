library(MODIStsp)
# library(rgeoboundaries)
library(sf)
library(raster)
library(here)
library(tidyverse)
library(viridis)
# library(rgdal)
library(mapSpain)
library(climaemet)
library(plotly)
library(splines)
library(VDPO)
library(SOP)
library(ks)

# Get daily climate data for station "9434" (Madrid, for example)
daily_data <- aemet_daily_clim(station = "all", start = "2022-01-01" , end ="2022-01-01" )

prov_aemet=c(sort(unique(daily_data$provincia)))
prov_aemet=prov_aemet[-c(9,17,27,30,36,43,47)] # REMOVING THE ISLANDS AND CEUTA AND MELILLA

prov_index=sapply(X = prov_aemet,FUN = function(x) which(daily_data$provincia==x))

# sum(sum(sapply(prov_index, function(x) length(x))),
# length(which(daily_data$provincia=="STA. CRUZ DE TENERIFE")),
# length(which(daily_data$provincia=="ILLES BALEARS")),
# length(which(daily_data$provincia=="SANTA CRUZ DE TENERIFE")),
# length(which(daily_data$provincia=="MELILLA")),
# length(which(daily_data$provincia=="CEUTA")),
# length(which(daily_data$provincia=="LAS PALMAS")),
# length(which(daily_data$provincia=="BALEARES")))==length(daily_data$tmed)

aux=sapply(seq_along(prov_index), function(x) mean(daily_data$tmed[prov_index[[x]]],na.rm=TRUE))
mean_temp=data.frame(Temperature=aux, Province=prov_aemet)
mean_temp=mean_temp[order(mean_temp$Province),]


# Get shp

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
# all_tiff <- list.files("C:/Users/user/Desktop/Trabajo/Escuela/Doctorado/Pavel/Tesis/2do paper/codigo/Paper 2 Classification/MODIS/VegetationData/spain/VI_16Days_1Km_v61/NDVI/")

all_tiff <- list.files("C:/Users/user/Desktop/Trabajo/Escuela/Doctorado/Pavel/Tesis/2do paper/codigo/Paper 2 Classification/MODIS/Spain provinces/MODIStsp/spain_provinces/VI_Monthly_1Km_v61/NDVI/")

NDVI_raster <- raster(here::here(paste0("C:/Users/user/Desktop/Trabajo/Escuela/Doctorado/Pavel/Tesis/2do paper/codigo/Paper 2 Classification/MODIS/Spain provinces/MODIStsp/spain_provinces/VI_Monthly_1Km_v61/NDVI/", all_tiff[1])))

NDVI_raster <- projectRaster(NDVI_raster, crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

# Cropping the data
NDVI_raster <- raster::mask(NDVI_raster, as_Spatial(map_boundary))

# Dividing values by 10000 to have NDVI values between -1 and 1
gain(NDVI_raster) <- 0.0001

# Converting the raster object into a dataframe
NDVI_df <- as.data.frame(NDVI_raster, xy = TRUE, na.rm = TRUE)
rownames(NDVI_df) <- c()


# ggplot() +
#   geom_tile(
#     data = NDVI_df,
#     aes_string(x = "x", y = "y", fill = colnames(NDVI_df)[3])
#   ) +
#   geom_sf(data = map_boundary, inherit.aes = FALSE, fill = NA) +
#   # scale_fill_viridis(name = "NDVI", limits = c(-1, 1)) +
#   scale_fill_gradientn(
#     name = "NDVI",
#     colors = terrain.colors(5, rev = T),
#     limits = c(-1, 1)
#   ) +
#   labs(
#     title = paste("NDVI", map_boundary$name), 
#     subtitle = str_remove(string = a_file, 
#                           pattern = ".Rds"),
#     x = "Longitude",
#     y = "Latitude"
#   ) +
#   theme_bw()


df_sf <- st_as_sf(NDVI_df, coords = c("x", "y"), crs = 4326)

ndvi_sf <- st_transform(df_sf, crs = st_crs(map_boundary))

df_with_provinces <- st_join(ndvi_sf, map_boundary)

df_final <- as.data.frame(df_with_provinces)

data_NDVI=data.frame(NDVI=df_final$MOD13A3_NDVI_2022_001)
data_NDVI[["longitude"]]=NDVI_df$x
data_NDVI[["latitude"]]=NDVI_df$y
data_NDVI[["province"]]=df_final$prov.shortname.es
data_NDVI=data_NDVI[-which(is.na(data_NDVI$province)),]

data_NDVI=data_NDVI[-which(data_NDVI$province=="Melilla"),]
data_NDVI=data_NDVI[-which(data_NDVI$province=="Ceuta"),]
data_NDVI=data_NDVI[-which(data_NDVI$province=="Baleares"),]

data_NDVI_ordered=data_NDVI[order(data_NDVI$province),]

prov_name=list(unique(data_NDVI_ordered$province))

data_prov=data_NDVI_ordered[which(data_NDVI_ordered$province=="Lugo"),]

# "LUGO" 114X171

# THIS CHECKS FOR DUPLICATES IN THE COORDINATES, NO DUPLICATES EXPECTED   

# aux=lapply(unique(data_NDVI[["province"]]), function(x) which(duplicated(data_NDVI[which(data_NDVI$province==as.character(x)),2:3])==TRUE))
# 
# all.equal(sum(sapply(aux, function(x) is_empty(x))),length(aux))