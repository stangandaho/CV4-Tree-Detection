# Load packages
library(terra) # for raster data manupulation
library(sf) # for vector/feature data manipulation
library(dplyr) # for data manipulation

## Import drone images
path_drone_img  <- "Données nécessaires/Images drones des parcelles/"
path_annotation <- "Données nécessaires/Contours des cimes d_arbres/annotations_cimes.shp"
image_files <- list.files(path = path_drone_img,
                          recursive = TRUE, pattern = ".tif$", full.names = TRUE)
all_images <- lapply(image_files, terra::rast)

## Import tree canopy feature
canopy <- sf::read_sf(path_annotation) %>%
  tidyr::drop_na() %>% 
  dplyr::mutate(image_name = paste0("Ortho_", Placette))
plot_name <- sub("Deali", "Dealy", unique(canopy$image_name))

## Select image relavant
all_images <- list()
## Import drone images
image_files <- list.files(path = "Données nécessaires/Images drones des parcelles/",
                          recursive = TRUE, pattern = ".tif$", full.names = TRUE)
for (img in 1:length(image_files)) {
  rst <- terra::rast(image_files[img])
  ## create file_name
  image_name <- strsplit(basename(terra::sources(rst)), split = "\\.")[[1]][1]
  all_images[[image_name]] <- rst
}
all_images <- all_images[names(all_images) %in% plot_name]


### Loop to cropped all images with their relvant grid
for (img in 1:length(all_images)) {
  ## Create extend
  ext_ploygon <- terra::as.polygons(terra::ext(all_images[[img]])) %>%
    sf::st_as_sf() %>% 
    sf::st_set_crs(value = 4326)
  print(st_perimeter(ext_ploygon)/4)
  ## create file_name
  image_name <- strsplit(basename(terra::sources(all_images[[img]])), 
  split = "\\.")[[1]][1]

  ext_grid <- sf::st_make_grid(x = ext_ploygon) %>% 
    sf::st_as_sf() %>% 
    sf::st_transform(crs = 4326) %>% 
    dplyr::mutate(grid_name = paste0("grid_",image_name, "_", 1:nrow(.)))
  
  for (cell in 1:nrow(ext_grid)) {
    # Loop to crop image with grid cell
    message(paste0("On image ", img, "/", length(all_images), 
    " and grid ", cell, "/", nrow(ext_grid)))
    single_cell <- ext_grid[cell, ]

    croped <- terra::crop(x = all_images[[img]], y = single_cell)
    terra::writeRaster(x = croped, filename = paste0("cropped/", 
    single_cell[["grid_name"]], ".tif"))
    
  }
}
