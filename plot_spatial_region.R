library(ggplot2)

df=data.frame(X=X[[j]], X_hat=X_hat[[j]], lat=Data_obs[[2]][[j]], lon=Data_obs[[1]][[j]])

ggplot(df, aes(x = lon, y = lat, color = X)) +
  geom_point() +
  scale_color_viridis_c() +  # Escoge una paleta de colores
  labs(title = "Mapa de NDVI")

ggplot(df, aes(x = lon, y = lat, color = X_hat)) +
  geom_point() +
  scale_color_viridis_c() +  # Escoge una paleta de colores
  labs(title = "Mapa de NDVI")

df=data.frame(X=beta, lat=obs_Beta$y_obs_Beta, lon=obs_Beta$x_obs_Beta)

ggplot(df, aes(x = lon, y = lat, color = X)) +
  geom_point() +
  scale_color_viridis_c() +  # Escoge una paleta de colores
  labs(title = "Mapa de NDVI")
