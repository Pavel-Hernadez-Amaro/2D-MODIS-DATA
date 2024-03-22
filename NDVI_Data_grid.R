prov_name=unique(data_NDVI_ordered$province)

Data_grid=vector(mode = "list")

Data_obs=vector(mode = "list", length = 2)
Data_obs[[1]]=vector(mode = "list")
Data_obs[[2]]=vector(mode = "list")

for (ind in prov_name) {
  
  data_prov=data_NDVI_ordered[which(data_NDVI_ordered$province==ind),]
  
  # Get unique longitude and latitude values
  unique_longitudes <- sort(unique(data_prov$longitude))
  unique_latitudes <- sort(unique(data_prov$latitude))
  # SE PUEDEN ORDENAR PORQUE NO HAY UN PAR DE COORDENADAS REPETIDAS

  Data_obs[[1]][[ind]]=unique_longitudes
  Data_obs[[2]][[ind]]=unique_latitudes
  
  # Create an empty matrix with dimensions based on unique values
  data_matrix <- matrix(NA, nrow = length(unique_longitudes), ncol = length(unique_latitudes))
  
  # Fill in the matrix with NDVI values
  for (i in 1:nrow(data_matrix)) {
    row_idx <- which(unique_longitudes == data_prov$longitude[i])
    col_idx <- which(unique_latitudes == data_prov$latitude[i])
    data_matrix[row_idx, col_idx] <- data_prov$NDVI[i]
  }
  
  Data_grid[[ind]] = data_matrix 
  
}

missing_points <- miss_points <- vector(mode = "list", length = length(Data_grid) )

for (j in seq_along(missing_points)) {

  col_index=floor(which(is.na(Data_grid[[j]]))/nrow(Data_grid[[j]]))+1
  col_index[which(which(is.na(Data_grid[[j]]))%%nrow(Data_grid[[j]])==0)]=col_index[which(which(is.na(Data_grid[[j]]))%%nrow(Data_grid[[j]])==0)]-1
  row_index=which(is.na(Data_grid[[j]]))-(nrow(Data_grid[[j]])*(col_index-1))
  row_index[which(row_index==0)]=nrow(Data_grid[[j]])
  
  missing_points[[j]] <- cbind(row_index,col_index)
  
  miss_points[[j]] <- vector(mode = "list", length = ncol(Data_grid[[j]]))
  for (i in 1:ncol(Data_grid[[j]])) {
    miss_spots <- NULL
    for (j_row in 1:nrow(Data_grid[[j]])) {
      if (is.na(Data_grid[[j]][j_row, i])) {
        miss_spots <- c(miss_spots, j_row)
      }
    }
    if (!is.null(miss_spots)) {
      miss_points[[j]][[i]] <- miss_spots
    }
  }
}

case="Madrid" # "Madrid" "Málaga" 

plot_ly(z=Data_grid[[case]], type="surface")

## THIS ARE THE DIMENSIONS OF THE B-spline FOR THE BETA THAT IS GENERAL TO ALL THE PROVINCES
max(sapply(Data_grid, function(x) nrow(x))) # nrow

max(sapply(Data_grid, function(x) ncol(x))) # ncol

obs_Beta=list(x_obs_Beta=sort(unique(data_NDVI_ordered$longitude)),
              y_obs_Beta=sort(unique(data_NDVI_ordered$latitude))
)

X=Data_grid

des=ffpo_2d_2(X, Data_obs, obs_Beta, miss_points, missing_points, nbasis = rep(25, 4), bdeg = rep(3, 4))
