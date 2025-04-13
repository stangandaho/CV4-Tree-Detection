library(sf)
library(terra)

## Import tree canopy feature
path_drone_img  <- "Données nécessaires/Images drones des parcelles/"
path_annotation <- "Données nécessaires/Contours des cimes d_arbres/annotations_cimes.shp"

canopy <- sf::read_sf(path_annotation) %>%
  tidyr::drop_na() %>% 
  dplyr::mutate(image_name = paste0("Ortho_", Placette))

plot_name <- sub("Deali", "Dealy", unique(canopy$image_name))

## Select image relavant
all_images <- list()
## Import drone images
image_files <- list.files(path = path_drone_img,
                          recursive = TRUE, pattern = ".tif$", 
                          full.names = TRUE)
for (img in 1:length(image_files)) {
  rst <- terra::rast(image_files[img])
  ## create file_name
  image_name <- strsplit(basename(terra::sources(rst)), split = "\\.")[[1]][1]
  all_images[[image_name]] <- rst
}
all_images <- all_images[names(all_images) %in% plot_name]

## Loop through parcelle name to select relavant image and crop parcelle and rasterize (to perform a mask)
for (img in 1:length(all_images)) {
  parcelle_sf <- canopy %>% 
    dplyr::filter(image_name == plot_name[img]) %>% 
    sf::st_make_valid() %>% 
    dplyr::filter(sf::st_is_valid(.))
  img_relevant <- all_images[[plot_name[img]]]
  ## Create extend
  ext_ploygon <- terra::as.polygons(terra::ext(img_relevant)) %>%
    sf::st_as_sf() %>% 
    sf::st_set_crs(value = 4326)
  
  ext_grid <- sf::st_make_grid(x = ext_ploygon) %>% 
    sf::st_as_sf() %>% 
    dplyr::mutate(grid_name = paste0("grid_",plot_name[img], "_", 1:nrow(.)))
  
  for (cell in 1:nrow(ext_grid)) {
    # Loop to crop image with grid cell
    message(paste0("On image ", img, "/", length(all_images), " and grid ", cell, "/", nrow(ext_grid)))
    single_cell <- ext_grid[cell, ] %>% 
      sf::st_transform(crs = 4326) %>% 
      sf::st_make_valid()
    clip_parcelle <- sf::st_intersection(parcelle_sf, single_cell) %>% 
      sf::st_as_sf() 
    if (nrow(clip_parcelle) == 0) {
      next
    }
    
    croped <- terra::crop(x = img_relevant, y = single_cell)
    grid_rast <- terra::rasterize(x = clip_parcelle, y = croped, field = 1)
    
    terra::writeRaster(grid_rast, filename = paste0("mask/", unique(clip_parcelle[["grid_name"]]), ".tif"))
  }
  
}
