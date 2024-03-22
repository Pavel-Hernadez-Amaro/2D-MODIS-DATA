prov_name=unique(data_NDVI_ordered$province)

Data_array=vector(mode = "list")

Data_obs=vector(mode = "list", length = 2)
Data_obs[[1]]=vector(mode = "list")
Data_obs[[2]]=vector(mode = "list")

for (ind in prov_name) {
  
  data_prov=data_NDVI_ordered[which(data_NDVI_ordered$province==ind),]
  
  # Get unique longitude and latitude values
  longitudes <- data_prov$longitude
  latitudes <- data_prov$latitude
  # SE PUEDEN ORDENAR PORQUE NO HAY UN PAR DE COORDENADAS REPETIDAS
  
  Data_obs[[1]][[ind]]=longitudes
  Data_obs[[2]][[ind]]=latitudes
  
  Data_array[[ind]] = data_prov$NDVI
  
}

obs_Beta=list(x_obs_Beta=data_NDVI_ordered$longitude,
              y_obs_Beta=data_NDVI_ordered$latitude
)

X = Data_array
y=mean_temp[,1]

des=ffpo_2d_spatial(X, Data_obs, obs_Beta, miss_points, missing_points, nbasis = rep(30, 4), bdeg = rep(3, 4))

aux=B2XZG_2d(B = des$B_ffpo2d, c = c(30,30))

res=XZG2theta(X = aux$X, Z = aux$Z, G = aux$G, TMatrix = aux$TMatrix, y = y, family = gaussian())

beta=des$Phi_ffpo2d %*% res$theta

res$fit$fitted.values

des$Phi_ffpo2d %*% res$theta

# formula <- mean_temp ~ ffpo_2d_spatial(X, Data_obs, obs_Beta, miss_points, missing_points, nbasis = rep(25, 4), bdeg = rep(3, 4))
# res <- VDPO(formula = formula, data = data, family = stats::gaussian())
