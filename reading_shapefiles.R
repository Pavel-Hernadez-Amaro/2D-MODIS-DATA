library(tidyverse)
library(raster)

library(rgdal) # para importar archivos shapefiles
library(broom) # Para transformar los archivos shapefiles 

shapefile_ccaa <- shapefile("Comunidades_Autonomas_ETRS89_30N.shp")

data_ccaa <- tidy(shapefile_ccaa)


nombres_ccaa <- tibble(shapefile_ccaa$Texto) %>% 
  mutate(id = as.character(seq(0, nrow(.)-1)))

data_ccaa_mapa <- data_ccaa %>% 
  left_join(nombres_ccaa, by = "id") %>% 
  rename(ccaa = `shapefile_ccaa$Texto`)


data_ccaa_mapa %>%
  filter(ccaa == "Comunidad de Madrid") %>% 
  ggplot() +
  geom_polygon(aes( x= long, y = lat, group = group),
               fill = "black", alpha = 0.8, size = 0.05 ) +
  theme_void() +
  theme(panel.background = element_rect(size= 0.5, color = "white", fill = "white")) +
  labs(title = "CCAA", subtitle = "España") 


shapefile_provincias <- shapefile("Provincias_ETRS89_30N.shp")

data_provincias <- tidy(shapefile_provincias)

nombres_provincias <- tibble(provincias = shapefile_provincias$Texto) %>% 
  mutate(id = as.character(seq(0, nrow(.)-1)))

data_provincias_mapa <- data_provincias %>% 
  left_join(nombres_provincias, by = "id")

unique(data_provincias_mapa$provincias)

data_provincias_mapa %>%
  filter(provincias == "Madrid") %>% 
  ggplot() +
  geom_polygon(aes( x= long, y = lat, group = group),
               fill = "black", alpha = 0.8, linewidth = 0.05 ) +
  theme_void() +
  theme(panel.background = element_rect(linewidth = 0.5, color = "white", fill = "white")) +
  labs(title = "Provincias", subtitle = "España") 


mydf <- structure(list(longitude = data_provincias_mapa %>%
                         filter(provincias == "Madrid") %>% 
                         dplyr::select(long) %>% 
                         as.vector(), 
                       latitude = data_provincias_mapa %>%
                         filter(provincias == "Madrid") %>% 
                         dplyr::select(lat)%>% 
                         as.vector()), 
                  .Names = c("longitude", 
                             "latitude"), class = "data.frame", row.names = c(NA, -1174L))


### Get long and lat from your data.frame. Make sure that the order is in lon/lat.

xy <- mydf[,c(1,2)]

spdf <- SpatialPointsDataFrame(coords = xy, data = mydf,
                               proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
