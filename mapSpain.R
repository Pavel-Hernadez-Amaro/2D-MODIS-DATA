
library(mapSpain)
library(ggplot2)

country <- esp_get_country()
lines <- esp_get_can_box()

ggplot(country) +
  geom_sf(fill = "cornsilk", color = "#887e6a") +
  labs(title = "Map of Spain") +
  theme(
    panel.background = element_rect(fill = "#fffff3"),
    panel.border = element_rect(
      colour = "#887e6a",
      fill = NA,
    ),
    text = element_text(
      family = "serif",
      face = "bold"
    )
  )


# Plot provinces

Madrid <- esp_get_prov("Madrid")

ggplot(Madrid) +
  geom_sf(fill = "darkred", color = "white") +
  theme_bw()




# Plot municipalities

Euskadi_CCAA <- esp_get_ccaa("Euskadi")
Euskadi <- esp_get_munic(region = "Euskadi")

# Use dictionary

Euskadi$name_eu <- esp_dict_translate(Euskadi$ine.prov.name, lang = "eu")

ggplot(Euskadi_CCAA) +
  geom_sf(fill = "grey50") +
  geom_sf(data = Euskadi, aes(fill = name_eu)) +
  scale_fill_manual(values = c("red2", "darkgreen", "ivory2")) +
  labs(
    fill = "",
    title = "Euskal Autonomia Erkidegoko",
    subtitle = "Probintziak"
  ) +
  theme_void() +
  theme(
    plot.title = element_text(face = "bold"),
    plot.subtitle = element_text(face = "italic")
  )


# Census Women ------------------------------------------------------------



census <- mapSpain::pobmun19

# Extract CCAA from base dataset

codelist <- mapSpain::esp_codelist

census <-
  unique(merge(census, codelist[, c("cpro", "codauto")], all.x = TRUE))

# Summarize by CCAA
census_ccaa <-
  aggregate(cbind(pob19, men, women) ~ codauto, data = census, sum)

census_ccaa$porc_women <- census_ccaa$women / census_ccaa$pob19
census_ccaa$porc_women_lab <-
  paste0(round(100 * census_ccaa$porc_women, 2), "%")

# Merge into spatial data

CCAA_sf <- esp_get_ccaa()
CCAA_sf <- merge(CCAA_sf, census_ccaa)
Can <- esp_get_can_box()

ggplot(CCAA_sf) +
  geom_sf(aes(fill = porc_women),
          color = "grey70",
          lwd = .3
  ) +
  geom_sf(data = Can, color = "grey70") +
  geom_sf_label(aes(label = porc_women_lab),
                fill = "white", alpha = 0.5,
                size = 3,
                label.size = 0
  ) +
  scale_fill_gradientn(
    colors = hcl.colors(10, "Blues", rev = TRUE),
    n.breaks = 10,
    labels = function(x) {
      sprintf("%1.1f%%", 100 * x)
    },
    guide = guide_legend(title = "Porc. women")
  ) +
  theme_void() +
  theme(legend.position = c(0.1, 0.6))



# NDVI --------------------------------------------------------------------

library(rgeoboundaries)
library(sf)
library(raster)
library(here)
library(ggplot2)
library(viridis)
library(rgdal)
# 
# # Downloading the boundary of Mongolia
map_boundary <- esp_get_prov("Madrid")

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

