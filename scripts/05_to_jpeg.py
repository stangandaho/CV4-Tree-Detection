# Load library
import cv2 as cv
import rasterio as rio
import numpy as np
from pathlib import Path


# Ceate a directory to store image in true color into jpeg from instead of tif
Path("images").mkdir(exist_ok=True)

# Apply for loop to convert each tif file and save inti jpeg format
img_list = [f"cropped/{img.name}" for img in Path("cropped").glob("*.tif")]
img_list
for img in img_list:
    img_path = Path(img)
    jpeg_file = f"images/{img_path.stem}.jpeg"

    with rio.open(img) as rst:
        band1 = rst.read(3)
        band2 = rst.read(2)
        band3 = rst.read(1)

        new_img = np.array([band1, band2, band3])
        new_img = np.transpose(new_img, (1, 2, 0))
        new_img = new_img.astype(np.uint8)
        cv.imwrite(jpeg_file, new_img)
    