# 1. Load libraries 
library(googleCloudStorageR) # Earth Engine with Python
library(rgee) # Earth Engine with Python
library(mapedit) # Interactive editing map :)
library(tmap) # Load world countries dataset

set.seed(10) # Define a RNG in R

# 2. Initialize Earth Engine
ee_Initialize("csaybar", gcs = TRUE)

# 3. Get Austria Geometry (as a simple feaure), and convert it into a EE object
data("World")
austria <- World[World$name == "Austria",][["geometry"]] %>% 
  sf_as_ee()

# 4. Filter S2 dataset by date and space (Austria)
s2_sr <- ee$ImageCollection("COPERNICUS/S2_SR") %>% 
  ee$ImageCollection$filterDate("2020-01-01", "2020-01-31") %>% 
  ee$ImageCollection$filterBounds(austria) %>% 
  ee_get(sample(273,1)) %>% # Select a random image
  ee$ImageCollection$first() %>% 
  ee$Image$select(c("B4", "B2", "B1"))
ee_as_stars(s2_sr, dsn = "demo/s2_demo.tif")

# 5. Create a Folder in GCS
params <- "-of COG -co TILING_SCHEME=GoogleMapsCompatible"
system(
  sprintf("gdalwarp demo/s2_demo.tif demo/s2_COGdemo.tif %s", params)
)

# 6. Upload an image and make it public
# https://console.cloud.google.com/storage/browser/rgee_dev
googleCloudStorageR::gcs_upload(
  file = "demo/s2_COGdemo.tif",
  name = "stac_demo/s2_COGdemo.tif",
  bucket = "rgee_dev"
)

# 7. Read COG in GEE
dd <- ee$Image$loadGeoTIFF("gs://rgee_dev/stac_demo/s2_COGdemo.tif")
