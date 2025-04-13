from ultralytics import YOLO
import rasterio as rio
import numpy as np

# Load model
mdl = YOLO("best.pt")
# Validate the model (allow to access model metrics).
mdl.val()
# Predict on directory that contains jpeg/png... files
result = mdl.predict(source= "new_images", save= True, show_labels = False, 
                     show_boxes = False, show_conf = False)


# Predict on TIF image
tif_path = "cropped/grid_Ortho_Dounde_200m_66.tif"
with rio.open(tif_path) as rst:
    band1 = rst.read(3)
    band2 = rst.read(2)
    band3 = rst.read(1)

    new_img = np.array([band1, band2, band3])
    new_img = np.transpose(new_img, (1, 2, 0))
    new_img = new_img.astype(np.uint8)
    new_img = np.ascontiguousarray(new_img)

    result = mdl.predict(source=new_img,
                        save=True)


# Predict on single image (jpeg/png)
result = mdl.predict(source= "path/to/image", save= True)

